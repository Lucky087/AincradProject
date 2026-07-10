class_name SaveStatusUI
extends CanvasLayer

## Shows short save/load notifications emitted by SaveManager.

@export_category("Save Manager")
@export var save_manager_path: NodePath = NodePath("/root/SaveManager")

@export_category("Presentation")
@export_range(0.5, 10.0, 0.1) var message_duration_seconds: float = 2.0

var _save_manager: SaveManagerService = null
var _status_panel: Control = null
var _message_label: Label = null
var _status_timer: Timer = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_save_manager.status_message_requested.connect(_on_status_message_requested)
	_status_timer.timeout.connect(_on_status_timer_timeout)
	_status_panel.visible = false


## Displays a message immediately and restarts the hide timer.
func show_status(message: String) -> void:
	if not _setup_is_valid or message.strip_edges().is_empty():
		return

	_message_label.text = message
	_status_panel.visible = true
	_status_timer.start(message_duration_seconds)


func _on_status_message_requested(message: String) -> void:
	show_status(message)


func _on_status_timer_timeout() -> void:
	if _status_panel != null:
		_status_panel.visible = false


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var save_manager_node: Node = get_node_or_null(save_manager_path)
	if save_manager_node is SaveManagerService:
		_save_manager = save_manager_node as SaveManagerService
	else:
		push_error("SaveStatusUI could not find SaveManager at: %s" % save_manager_path)
		is_valid = false

	var panel_node: Node = get_node_or_null("StatusPanel")
	if panel_node is Control:
		_status_panel = panel_node as Control
	else:
		push_error("SaveStatusUI is missing StatusPanel.")
		is_valid = false

	var label_node: Node = get_node_or_null("StatusPanel/MarginContainer/MessageLabel")
	if label_node is Label:
		_message_label = label_node as Label
	else:
		push_error("SaveStatusUI is missing MessageLabel.")
		is_valid = false

	var timer_node: Node = get_node_or_null("StatusTimer")
	if timer_node is Timer:
		_status_timer = timer_node as Timer
	else:
		push_error("SaveStatusUI is missing StatusTimer.")
		is_valid = false

	return is_valid
