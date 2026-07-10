class_name QuestNpc
extends Interactable

## Offers, reports, and turns in one quest through the existing interaction UI.

@export_category("Quest")
@export var quest_id: StringName = &"boar_hunt"
@export var player_group: StringName = &"players"

@export_category("Dialogue")
@export var speaker_name: String = "Road Warden"
@export_multiline var not_started_dialogue: String = (
	"The boars outside the city are becoming dangerous. "
	+ "Can you defeat three of them?"
)
@export_multiline var ready_dialogue: String = (
	"You did it. The road is safer now."
)
@export_multiline var completed_dialogue: String = (
	"Thank you again for your help."
)

var _pending_offer_player_ids: Dictionary[int, bool] = {}


func is_interaction_available(interactor: Node3D) -> bool:
	return _find_player_quest_log(interactor) != null


func get_interaction_prompt(interactor: Node3D) -> String:
	var player_root: Node = _find_player_root(interactor)
	var quest_log: PlayerQuestLog = _find_player_quest_log(interactor)
	if player_root == null or quest_log == null:
		return "Quest unavailable"

	var prompt_text: String = interaction_prompt
	var state: int = quest_log.get_quest_state(quest_id)
	match state:
		PlayerQuestLog.QuestState.NOT_STARTED:
			if _pending_offer_player_ids.has(player_root.get_instance_id()):
				prompt_text = "Press E to accept Boar Hunt"
			else:
				prompt_text = "Press E to hear quest"
		PlayerQuestLog.QuestState.ACTIVE:
			prompt_text = "Press E to check Boar Hunt"
		PlayerQuestLog.QuestState.READY_TO_TURN_IN:
			prompt_text = "Press E to turn in Boar Hunt"
		PlayerQuestLog.QuestState.COMPLETED:
			prompt_text = "Press E to talk"

	return prompt_text


func interact(interactor: Node3D) -> String:
	var player_root: Node = _find_player_root(interactor)
	var quest_log: PlayerQuestLog = _find_player_quest_log(interactor)
	if player_root == null or quest_log == null:
		push_error("QuestNpc could not resolve the interacting player's quest log.")
		return "%s: I cannot discuss the quest right now." % speaker_name

	var definition: QuestDefinition = quest_log.get_quest_definition(quest_id)
	if definition == null:
		push_error("QuestNpc could not find quest '%s'." % quest_id)
		return "%s: This quest is unavailable." % speaker_name

	var dialogue_text: String = (
		"%s: I am not sure what happened to that quest." % speaker_name
	)
	var state: int = quest_log.get_quest_state(quest_id)
	match state:
		PlayerQuestLog.QuestState.NOT_STARTED:
			dialogue_text = _handle_not_started(
				player_root,
				quest_log,
				definition
			)
		PlayerQuestLog.QuestState.ACTIVE:
			dialogue_text = _get_active_dialogue(quest_log, definition)
		PlayerQuestLog.QuestState.READY_TO_TURN_IN:
			dialogue_text = _handle_turn_in(
				player_root,
				quest_log,
				definition
			)
		PlayerQuestLog.QuestState.COMPLETED:
			dialogue_text = "%s: %s" % [speaker_name, completed_dialogue]

	return dialogue_text


func _handle_not_started(
	player_root: Node,
	quest_log: PlayerQuestLog,
	definition: QuestDefinition
) -> String:
	var player_instance_id: int = player_root.get_instance_id()
	if not _pending_offer_player_ids.has(player_instance_id):
		_pending_offer_player_ids[player_instance_id] = true
		return (
			"%s: %s\n\n%s\n%s\nObjective: %s\nReward: %d XP\n"
			+ "Press E again to accept."
		) % [
			speaker_name,
			not_started_dialogue,
			definition.title,
			definition.description,
			definition.get_objective_text(0),
			definition.experience_reward,
		]

	_pending_offer_player_ids.erase(player_instance_id)
	if not quest_log.accept_quest(quest_id):
		return "%s: The quest could not be accepted." % speaker_name

	return (
		"%s: Quest accepted. Defeat three wild boars and return to me."
		% speaker_name
	)


func _get_active_dialogue(
	quest_log: PlayerQuestLog,
	definition: QuestDefinition
) -> String:
	var current_progress: int = quest_log.get_objective_progress(quest_id)
	return "%s: You have defeated %d of %d boars." % [
		speaker_name,
		current_progress,
		definition.objective_target,
	]


func _handle_turn_in(
	player_root: Node,
	quest_log: PlayerQuestLog,
	definition: QuestDefinition
) -> String:
	var progression: PlayerProgression = _find_direct_progression(player_root)
	if progression == null:
		push_error("QuestNpc could not find PlayerProgression on the player.")
		return "%s: I cannot give your reward right now." % speaker_name

	if not quest_log.turn_in_quest(quest_id, progression):
		return "%s: The quest could not be completed." % speaker_name

	return "%s: %s\nQuest complete. Reward: %d XP." % [
		speaker_name,
		ready_dialogue,
		definition.experience_reward,
	]


func _find_player_quest_log(interactor: Node3D) -> PlayerQuestLog:
	var player_root: Node = _find_player_root(interactor)
	if player_root == null:
		return null

	for child_node: Node in player_root.get_children():
		if child_node is PlayerQuestLog:
			return child_node as PlayerQuestLog

	return null


func _find_direct_progression(player_root: Node) -> PlayerProgression:
	for child_node: Node in player_root.get_children():
		if child_node is PlayerProgression:
			return child_node as PlayerProgression

	return null


func _find_player_root(start_node: Node) -> Node:
	var current_node: Node = start_node
	while current_node != null:
		if current_node.is_in_group(player_group):
			return current_node
		current_node = current_node.get_parent()

	return null
