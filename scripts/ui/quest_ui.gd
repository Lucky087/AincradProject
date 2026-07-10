class_name QuestUI
extends CanvasLayer

## Displays one tracked quest from a PlayerQuestLog using signals only.

@export_category("Quest")
@export var quest_log_path: NodePath
@export var tracked_quest_id: StringName = &"boar_hunt"

@export_category("Presentation")
@export_range(0.5, 10.0, 0.1) var completion_message_seconds: float = 2.5

var _quest_log: PlayerQuestLog = null
var _quest_panel: Control = null
var _title_label: Label = null
var _objective_label: Label = null
var _completion_timer: Timer = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_quest_log.quest_state_changed.connect(_on_quest_state_changed)
	_quest_log.quest_progress_changed.connect(_on_quest_progress_changed)
	_quest_log.quest_data_loaded.connect(_on_quest_data_loaded)
	_completion_timer.timeout.connect(_on_completion_timer_timeout)
	_update_display()


func _update_display() -> void:
	if not _setup_is_valid:
		return

	var definition: QuestDefinition = _quest_log.get_quest_definition(tracked_quest_id)
	if definition == null:
		_quest_panel.visible = false
		return

	var state: int = _quest_log.get_quest_state(tracked_quest_id)
	match state:
		PlayerQuestLog.QuestState.NOT_STARTED:
			_quest_panel.visible = false
		PlayerQuestLog.QuestState.ACTIVE:
			_quest_panel.visible = true
			_title_label.text = definition.title
			_objective_label.text = definition.get_objective_text(
				_quest_log.get_objective_progress(tracked_quest_id)
			)
		PlayerQuestLog.QuestState.READY_TO_TURN_IN:
			_quest_panel.visible = true
			_title_label.text = definition.title
			_objective_label.text = "Return to the quest giver"
		PlayerQuestLog.QuestState.COMPLETED:
			_quest_panel.visible = false
		_:
			_quest_panel.visible = false


func _show_completion_message() -> void:
	var definition: QuestDefinition = _quest_log.get_quest_definition(tracked_quest_id)
	if definition == null:
		return

	_title_label.text = definition.title
	_objective_label.text = "Quest complete!"
	_quest_panel.visible = true
	_completion_timer.start(completion_message_seconds)


func _on_quest_state_changed(
	quest_id: StringName, _previous_state: int, current_state: int
) -> void:
	if quest_id != tracked_quest_id:
		return

	if current_state == PlayerQuestLog.QuestState.COMPLETED:
		_show_completion_message()
		return

	_update_display()


func _on_quest_progress_changed(
	quest_id: StringName, _current_progress: int, _target_progress: int
) -> void:
	if quest_id == tracked_quest_id:
		_update_display()


func _on_quest_data_loaded() -> void:
	_completion_timer.stop()
	_update_display()


func _on_completion_timer_timeout() -> void:
	_update_display()


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var quest_log_node: Node = get_node_or_null(quest_log_path)
	if quest_log_node is PlayerQuestLog:
		_quest_log = quest_log_node as PlayerQuestLog
	else:
		push_error("QuestUI could not find PlayerQuestLog at: %s" % quest_log_path)
		is_valid = false

	var panel_node: Node = get_node_or_null("QuestPanel")
	if panel_node is Control:
		_quest_panel = panel_node as Control
	else:
		push_error("QuestUI is missing QuestPanel.")
		is_valid = false

	var title_node: Node = get_node_or_null("QuestPanel/MarginContainer/VBoxContainer/TitleLabel")
	if title_node is Label:
		_title_label = title_node as Label
	else:
		push_error("QuestUI is missing TitleLabel.")
		is_valid = false

	var objective_node: Node = get_node_or_null(
		"QuestPanel/MarginContainer/VBoxContainer/ObjectiveLabel"
	)
	if objective_node is Label:
		_objective_label = objective_node as Label
	else:
		push_error("QuestUI is missing ObjectiveLabel.")
		is_valid = false

	var timer_node: Node = get_node_or_null("CompletionTimer")
	if timer_node is Timer:
		_completion_timer = timer_node as Timer
	else:
		push_error("QuestUI is missing CompletionTimer.")
		is_valid = false

	return is_valid
