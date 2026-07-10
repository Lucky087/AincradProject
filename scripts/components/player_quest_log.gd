class_name PlayerQuestLog
extends Node

## Stores one player's runtime quest state and objective progress.
##
## Quest content comes from QuestDefinition resources. This component owns
## only player-specific state and rewards completed quests through an explicit
## PlayerProgression reference supplied at turn-in time.

signal quest_state_changed(
	quest_id: StringName,
	previous_state: int,
	current_state: int
)
signal quest_progress_changed(
	quest_id: StringName,
	current_progress: int,
	target_progress: int
)
signal quest_reward_granted(
	quest_id: StringName,
	requested_experience: int,
	applied_experience: int
)

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
			"PlayerQuestLog rejected invalid quest definition: %s"
			% definition.resource_path
		)
		return false

	if _definitions_by_id.has(definition.quest_id):
		push_warning(
			"PlayerQuestLog already contains quest '%s'."
			% definition.quest_id
		)
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
	quest_progress_changed.emit(
		quest_id,
		0,
		get_objective_target(quest_id)
	)
	print("Quest accepted: %s" % quest_id)
	return true


## Applies one objective event to every matching active quest.
## Returns the total amount of progress applied across those quests.
func record_objective_progress(
	objective_id: StringName,
	amount: int = 1
) -> int:
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
		var new_progress: int = mini(
			previous_progress + amount,
			definition.objective_target
		)
		var applied_progress: int = new_progress - previous_progress
		if applied_progress <= 0:
			continue

		_progress_by_id[quest_id] = new_progress
		total_applied_progress += applied_progress
		quest_progress_changed.emit(
			quest_id,
			new_progress,
			definition.objective_target
		)

		if new_progress >= definition.objective_target:
			_set_quest_state(quest_id, QuestState.READY_TO_TURN_IN)

	return total_applied_progress


## Completes a ready quest and grants its XP reward exactly once.
func turn_in_quest(
	quest_id: StringName,
	progression: PlayerProgression
) -> bool:
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
			(
				"PlayerQuestLog cannot turn in quest '%s' without "
				+ "PlayerProgression."
			) % quest_id
		)
		return false

	var definition: QuestDefinition = get_quest_definition(quest_id)
	if definition == null:
		return false

	# Close the reward gate before calling another component. This prevents
	# duplicate rewards even if later code reacts to the emitted XP signals.
	_reward_granted_by_id[quest_id] = true
	var applied_experience: int = progression.add_experience(
		definition.experience_reward
	)
	_set_quest_state(quest_id, QuestState.COMPLETED)
	quest_reward_granted.emit(
		quest_id,
		definition.experience_reward,
		applied_experience
	)
	print(
		"Quest completed: %s. Requested reward: %d XP; applied: %d XP."
		% [
			quest_id,
			definition.experience_reward,
			applied_experience,
		]
	)
	return true


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
