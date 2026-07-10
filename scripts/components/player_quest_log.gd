class_name PlayerQuestLog
extends Node

## Stores one player's runtime quest state and objective progress.
##
## Quest content comes from QuestDefinition resources. This component owns
## only player-specific state and rewards completed quests through an explicit
## PlayerProgression reference supplied at turn-in time.

signal quest_state_changed(quest_id: StringName, previous_state: int, current_state: int)
signal quest_progress_changed(quest_id: StringName, current_progress: int, target_progress: int)
signal quest_reward_granted(
	quest_id: StringName, requested_experience: int, applied_experience: int
)

signal quest_data_loaded

enum QuestState {
	NOT_STARTED,
	ACTIVE,
	READY_TO_TURN_IN,
	COMPLETED,
}

@export_category("Initial Quests")
@export var initial_quest_definition: QuestDefinition

var _definitions_by_id: Dictionary[StringName, QuestDefinition] = {}
var _states_by_id: Dictionary[StringName, int] = {}
var _progress_by_id: Dictionary[StringName, int] = {}
var _reward_granted_by_id: Dictionary[StringName, bool] = {}


func _ready() -> void:
	if initial_quest_definition == null:
		push_warning("PlayerQuestLog has no initial quest definition assigned.")
		return

	register_quest(initial_quest_definition)


## Registers quest content so it can receive runtime state later.
func register_quest(definition: QuestDefinition) -> bool:
	if definition == null:
		push_error("PlayerQuestLog cannot register a null QuestDefinition.")
		return false

	if not definition.is_valid_definition():
		push_error(
			"PlayerQuestLog rejected invalid quest definition: %s" % definition.resource_path
		)
		return false

	if _definitions_by_id.has(definition.quest_id):
		push_warning("PlayerQuestLog already contains quest '%s'." % definition.quest_id)
		return false

	_definitions_by_id[definition.quest_id] = definition
	_states_by_id[definition.quest_id] = QuestState.NOT_STARTED
	_progress_by_id[definition.quest_id] = 0
	_reward_granted_by_id[definition.quest_id] = false
	return true


## Returns true when the quest definition is registered.
func has_quest(quest_id: StringName) -> bool:
	return _definitions_by_id.has(quest_id)


## Returns the registered definition or null when the ID is unknown.
func get_quest_definition(quest_id: StringName) -> QuestDefinition:
	return _definitions_by_id.get(quest_id) as QuestDefinition


## Returns the current QuestState value for a registered quest.
func get_quest_state(quest_id: StringName) -> int:
	if not has_quest(quest_id):
		return QuestState.NOT_STARTED

	return int(_states_by_id.get(quest_id, QuestState.NOT_STARTED))


## Returns current objective progress for a registered quest.
func get_objective_progress(quest_id: StringName) -> int:
	return int(_progress_by_id.get(quest_id, 0))


## Returns the objective target, or zero when the quest is unknown.
func get_objective_target(quest_id: StringName) -> int:
	var definition: QuestDefinition = get_quest_definition(quest_id)
	if definition == null:
		return 0

	return definition.objective_target


## Moves a quest from Not Started to Active.
func accept_quest(quest_id: StringName) -> bool:
	if not has_quest(quest_id):
		push_warning("Cannot accept unknown quest '%s'." % quest_id)
		return false

	if get_quest_state(quest_id) != QuestState.NOT_STARTED:
		return false

	_progress_by_id[quest_id] = 0
	_set_quest_state(quest_id, QuestState.ACTIVE)
	quest_progress_changed.emit(quest_id, 0, get_objective_target(quest_id))
	print("Quest accepted: %s" % quest_id)
	return true


## Applies one objective event to every matching active quest.
## Returns the total amount of progress applied across those quests.
func record_objective_progress(objective_id: StringName, amount: int = 1) -> int:
	if objective_id.is_empty() or amount <= 0:
		return 0

	var total_applied_progress: int = 0

	for quest_id: StringName in _definitions_by_id:
		if get_quest_state(quest_id) != QuestState.ACTIVE:
			continue

		var definition: QuestDefinition = _definitions_by_id[quest_id]
		if definition.objective_id != objective_id:
			continue

		var previous_progress: int = get_objective_progress(quest_id)
		var new_progress: int = mini(previous_progress + amount, definition.objective_target)
		var applied_progress: int = new_progress - previous_progress
		if applied_progress <= 0:
			continue

		_progress_by_id[quest_id] = new_progress
		total_applied_progress += applied_progress
		quest_progress_changed.emit(quest_id, new_progress, definition.objective_target)

		if new_progress >= definition.objective_target:
			_set_quest_state(quest_id, QuestState.READY_TO_TURN_IN)

	return total_applied_progress


## Completes a ready quest and grants its XP reward exactly once.
func turn_in_quest(quest_id: StringName, progression: PlayerProgression) -> bool:
	if not has_quest(quest_id):
		push_warning("Cannot turn in unknown quest '%s'." % quest_id)
		return false

	if get_quest_state(quest_id) != QuestState.READY_TO_TURN_IN:
		return false

	if bool(_reward_granted_by_id.get(quest_id, false)):
		push_warning("Quest '%s' reward was already granted." % quest_id)
		return false

	if progression == null:
		push_error(
			("PlayerQuestLog cannot turn in quest '%s' without " + "PlayerProgression.") % quest_id
		)
		return false

	var definition: QuestDefinition = get_quest_definition(quest_id)
	if definition == null:
		return false

	# Close the reward gate before calling another component. This prevents
	# duplicate rewards even if later code reacts to the emitted XP signals.
	_reward_granted_by_id[quest_id] = true
	var applied_experience: int = progression.add_experience(definition.experience_reward)
	_set_quest_state(quest_id, QuestState.COMPLETED)
	quest_reward_granted.emit(quest_id, definition.experience_reward, applied_experience)
	print(
		(
			"Quest completed: %s. Requested reward: %d XP; applied: %d XP."
			% [
				quest_id,
				definition.experience_reward,
				applied_experience,
			]
		)
	)
	return true


## Returns persistent state for every registered quest using stable quest IDs.
func get_save_data() -> Dictionary:
	var saved_quests: Dictionary = {}

	for quest_id: StringName in _definitions_by_id:
		saved_quests[String(quest_id)] = {
			"state": _quest_state_to_save_name(get_quest_state(quest_id)),
			"progress": get_objective_progress(quest_id),
			"reward_claimed": bool(_reward_granted_by_id.get(quest_id, false)),
		}

	return saved_quests


## Restores registered quest state and refreshes signal-driven UI.
##
## Unknown saved quest IDs are ignored. Completed state and reward ownership
## are normalized together so a completed quest can never pay its reward again.
func load_save_data(data: Dictionary) -> void:
	if data.is_empty():
		push_warning("PlayerQuestLog received empty save data; current values remain.")
		_emit_all_quest_updates()
		return

	for saved_key: Variant in data.keys():
		var quest_id: StringName = StringName(String(saved_key))
		if not has_quest(quest_id):
			push_warning("PlayerQuestLog skipped unknown saved quest ID '%s'." % quest_id)
			continue

		var saved_entry_value: Variant = data[saved_key]
		if not saved_entry_value is Dictionary:
			push_warning("PlayerQuestLog expected saved quest '%s' to be a Dictionary." % quest_id)
			continue

		var saved_entry: Dictionary = saved_entry_value
		_load_quest_entry(quest_id, saved_entry)

	_emit_all_quest_updates()


func _load_quest_entry(quest_id: StringName, saved_entry: Dictionary) -> void:
	var definition: QuestDefinition = get_quest_definition(quest_id)
	if definition == null:
		return

	var current_state: int = get_quest_state(quest_id)
	var current_progress: int = get_objective_progress(quest_id)
	var current_reward_claimed: bool = bool(_reward_granted_by_id.get(quest_id, false))

	var loaded_state: int = _read_saved_state(saved_entry, "state", current_state, quest_id)
	var loaded_progress: int = clampi(
		_read_saved_int(saved_entry, "progress", current_progress, quest_id),
		0,
		definition.objective_target
	)
	var loaded_reward_claimed: bool = _read_saved_bool(
		saved_entry, "reward_claimed", current_reward_claimed, quest_id
	)

	# The reward gate is authoritative for duplicate protection. A claimed reward
	# always means the quest is completed, and a completed quest always closes
	# the reward gate even if an older or manually edited save omitted the flag.
	if loaded_reward_claimed or loaded_state == QuestState.COMPLETED:
		loaded_state = QuestState.COMPLETED
		loaded_progress = definition.objective_target
		loaded_reward_claimed = true
	else:
		match loaded_state:
			QuestState.NOT_STARTED:
				loaded_progress = 0
				loaded_reward_claimed = false
			QuestState.ACTIVE:
				if loaded_progress >= definition.objective_target:
					loaded_state = QuestState.READY_TO_TURN_IN
			QuestState.READY_TO_TURN_IN:
				loaded_progress = definition.objective_target
			_:
				loaded_state = QuestState.NOT_STARTED
				loaded_progress = 0
				loaded_reward_claimed = false

	_states_by_id[quest_id] = loaded_state
	_progress_by_id[quest_id] = loaded_progress
	_reward_granted_by_id[quest_id] = loaded_reward_claimed


func _emit_all_quest_updates() -> void:
	quest_data_loaded.emit()


func _quest_state_to_save_name(state: int) -> String:
	match state:
		QuestState.NOT_STARTED:
			return "not_started"
		QuestState.ACTIVE:
			return "active"
		QuestState.READY_TO_TURN_IN:
			return "ready_to_turn_in"
		QuestState.COMPLETED:
			return "completed"
		_:
			return "not_started"


func _read_saved_state(data: Dictionary, key: String, fallback: int, quest_id: StringName) -> int:
	var loaded_state: int = fallback

	if not data.has(key):
		push_warning(
			(
				"Saved quest '%s' has no state; keeping %s."
				% [quest_id, _quest_state_to_save_name(fallback)]
			)
		)
	else:
		var value: Variant = data[key]
		if value is String:
			match String(value):
				"not_started":
					loaded_state = QuestState.NOT_STARTED
				"active":
					loaded_state = QuestState.ACTIVE
				"ready_to_turn_in":
					loaded_state = QuestState.READY_TO_TURN_IN
				"completed":
					loaded_state = QuestState.COMPLETED
				_:
					push_warning(
						(
							"Saved quest '%s' has an unknown state name; keeping %s."
							% [
								quest_id,
								_quest_state_to_save_name(fallback),
							]
						)
					)
		elif value is int or value is float:
			loaded_state = clampi(int(value), QuestState.NOT_STARTED, QuestState.COMPLETED)
		else:
			push_warning(
				(
					"Saved quest '%s' has an invalid state; keeping %s."
					% [quest_id, _quest_state_to_save_name(fallback)]
				)
			)

	return loaded_state


func _read_saved_int(data: Dictionary, key: String, fallback: int, quest_id: StringName) -> int:
	if not data.has(key):
		push_warning("Saved quest '%s' has no '%s'; using %d." % [quest_id, key, fallback])
		return fallback

	var value: Variant = data[key]
	if value is int or value is float:
		return int(value)

	push_warning(
		"Saved quest '%s' expected '%s' to be numeric; using %d." % [quest_id, key, fallback]
	)
	return fallback


func _read_saved_bool(data: Dictionary, key: String, fallback: bool, quest_id: StringName) -> bool:
	if not data.has(key):
		push_warning("Saved quest '%s' has no '%s'; using %s." % [quest_id, key, fallback])
		return fallback

	var value: Variant = data[key]
	if value is bool:
		return bool(value)

	push_warning("Saved quest '%s' expected '%s' to be bool; using %s." % [quest_id, key, fallback])
	return fallback


## Returns a readable state name for debugging and UI fallbacks.
func get_quest_state_display_name(quest_id: StringName) -> String:
	match get_quest_state(quest_id):
		QuestState.NOT_STARTED:
			return "Not started"
		QuestState.ACTIVE:
			return "Active"
		QuestState.READY_TO_TURN_IN:
			return "Ready to turn in"
		QuestState.COMPLETED:
			return "Completed"
		_:
			return "Unknown"


func _set_quest_state(quest_id: StringName, new_state: int) -> void:
	var previous_state: int = get_quest_state(quest_id)
	if previous_state == new_state:
		return

	_states_by_id[quest_id] = new_state
	quest_state_changed.emit(quest_id, previous_state, new_state)
