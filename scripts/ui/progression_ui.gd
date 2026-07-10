class_name ProgressionUI
extends CanvasLayer

## Displays one PlayerProgression component without owning progression logic.

@export_category("Required Nodes")
@export var progression_component_path: NodePath

@export_category("Presentation")
@export_range(0.1, 10.0, 0.1) var level_up_message_duration_seconds: float = 1.6

var _progression_component: PlayerProgression = null
var _level_label: Label = null
var _experience_label: Label = null
var _experience_bar: ProgressBar = null
var _level_up_label: Label = null
var _level_up_timer: Timer = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_progression_component.experience_changed.connect(
		_on_experience_changed
	)
	_progression_component.levelled_up.connect(_on_levelled_up)
	_level_up_timer.timeout.connect(_on_level_up_timer_timeout)

	_level_up_label.visible = false
	_update_display()


func _update_display() -> void:
	if not _setup_is_valid:
		return

	var current_level: int = _progression_component.get_current_level()
	var current_experience: int = (
		_progression_component.get_current_experience()
	)
	var required_experience: int = (
		_progression_component.get_experience_required_for_next_level()
	)

	_level_label.text = "Level %d" % current_level

	if _progression_component.is_at_maximum_level():
		_experience_label.text = "XP: MAX LEVEL"
		_experience_bar.min_value = 0.0
		_experience_bar.max_value = 1.0
		_experience_bar.value = 1.0
		return

	_experience_label.text = "XP: %d / %d" % [
		current_experience,
		required_experience,
	]
	_experience_bar.min_value = 0.0
	_experience_bar.max_value = float(maxi(required_experience, 1))
	_experience_bar.value = float(current_experience)


func _on_experience_changed(
	_current_experience: int,
	_experience_required_for_next_level: int,
	_current_level: int
) -> void:
	_update_display()


func _on_levelled_up(_previous_level: int, _current_level: int) -> void:
	_update_display()
	_level_up_label.text = "Level Up!"
	_level_up_label.visible = true
	_level_up_timer.start(level_up_message_duration_seconds)


func _on_level_up_timer_timeout() -> void:
	if _level_up_label != null:
		_level_up_label.visible = false


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var progression_node: Node = get_node_or_null(progression_component_path)
	if progression_node is PlayerProgression:
		_progression_component = progression_node as PlayerProgression
	else:
		push_error(
			"ProgressionUI could not find PlayerProgression at: %s"
			% progression_component_path
		)
		is_valid = false

	var level_node: Node = get_node_or_null(
		"ProgressionPanel/MarginContainer/VBoxContainer/LevelLabel"
	)
	if level_node is Label:
		_level_label = level_node as Label
	else:
		push_error("ProgressionUI is missing LevelLabel.")
		is_valid = false

	var experience_node: Node = get_node_or_null(
		"ProgressionPanel/MarginContainer/VBoxContainer/ExperienceLabel"
	)
	if experience_node is Label:
		_experience_label = experience_node as Label
	else:
		push_error("ProgressionUI is missing ExperienceLabel.")
		is_valid = false

	var bar_node: Node = get_node_or_null(
		"ProgressionPanel/MarginContainer/VBoxContainer/ExperienceBar"
	)
	if bar_node is ProgressBar:
		_experience_bar = bar_node as ProgressBar
	else:
		push_error("ProgressionUI is missing ExperienceBar.")
		is_valid = false

	var level_up_node: Node = get_node_or_null(
		"ProgressionPanel/MarginContainer/VBoxContainer/LevelUpLabel"
	)
	if level_up_node is Label:
		_level_up_label = level_up_node as Label
	else:
		push_error("ProgressionUI is missing LevelUpLabel.")
		is_valid = false

	var timer_node: Node = get_node_or_null("LevelUpTimer")
	if timer_node is Timer:
		_level_up_timer = timer_node as Timer
	else:
		push_error("ProgressionUI is missing LevelUpTimer.")
		is_valid = false

	return is_valid
