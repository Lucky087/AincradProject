class_name InteractionUI
extends CanvasLayer

## Displays the current interaction prompt and short interaction messages.

@export_range(0.5, 10.0, 0.1) var message_duration_seconds: float = 3.0

var _prompt_panel: Control = null
var _prompt_label: Label = null
var _message_panel: Control = null
var _message_label: Label = null
var _message_timer: Timer = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()

	if _setup_is_valid:
		hide_prompt()
		_hide_message()


func show_prompt(prompt_text: String) -> void:
	if not _setup_is_valid:
		return

	_prompt_label.text = prompt_text
	_prompt_panel.visible = true


func hide_prompt() -> void:
	if not _setup_is_valid:
		return

	_prompt_panel.visible = false


func show_message(message_text: String) -> void:
	if not _setup_is_valid or message_text.is_empty():
		return

	_message_label.text = message_text
	_message_panel.visible = true
	_message_timer.start(message_duration_seconds)


func _hide_message() -> void:
	if not _setup_is_valid:
		return

	_message_panel.visible = false


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var prompt_panel_node: Node = get_node_or_null("%InteractionPromptPanel")
	if prompt_panel_node is Control:
		_prompt_panel = prompt_panel_node as Control
	else:
		push_error("InteractionUI is missing InteractionPromptPanel.")
		is_valid = false

	var prompt_label_node: Node = get_node_or_null("%PromptLabel")
	if prompt_label_node is Label:
		_prompt_label = prompt_label_node as Label
	else:
		push_error("InteractionUI is missing PromptLabel.")
		is_valid = false

	var message_panel_node: Node = get_node_or_null("%MessagePanel")
	if message_panel_node is Control:
		_message_panel = message_panel_node as Control
	else:
		push_error("InteractionUI is missing MessagePanel.")
		is_valid = false

	var message_label_node: Node = get_node_or_null("%MessageLabel")
	if message_label_node is Label:
		_message_label = message_label_node as Label
	else:
		push_error("InteractionUI is missing MessageLabel.")
		is_valid = false

	var message_timer_node: Node = get_node_or_null("%MessageTimer")
	if message_timer_node is Timer:
		_message_timer = message_timer_node as Timer
	else:
		push_error("InteractionUI is missing MessageTimer.")
		is_valid = false

	return is_valid


func _on_message_timer_timeout() -> void:
	_hide_message()
