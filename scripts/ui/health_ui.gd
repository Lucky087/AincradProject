class_name HealthUI
extends CanvasLayer

## Displays one HealthComponent as a simple reusable HUD bar.

@export var health_component_path: NodePath

var _health_component: HealthComponent = null
var _health_bar: ProgressBar = null
var _health_label: Label = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_health_component.health_changed.connect(_on_health_changed)
	_update_display(
		_health_component.get_current_health(),
		_health_component.get_maximum_health()
	)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	if health_component_path.is_empty():
		push_error("HealthUI has no health_component_path assigned.")
		is_valid = false
	else:
		var health_node: Node = get_node_or_null(health_component_path)
		if health_node is HealthComponent:
			_health_component = health_node as HealthComponent
		else:
			push_error(
				"HealthUI could not find a HealthComponent at: %s"
				% health_component_path
			)
			is_valid = false

	var health_bar_node: Node = get_node_or_null("%HealthBar")
	if health_bar_node is ProgressBar:
		_health_bar = health_bar_node as ProgressBar
	else:
		push_error("HealthUI is missing HealthBar.")
		is_valid = false

	var health_label_node: Node = get_node_or_null("%HealthLabel")
	if health_label_node is Label:
		_health_label = health_label_node as Label
	else:
		push_error("HealthUI is missing HealthLabel.")
		is_valid = false

	return is_valid


func _update_display(current_health: float, maximum_health: float) -> void:
	if _health_bar == null or _health_label == null:
		return

	_health_bar.max_value = maximum_health
	_health_bar.value = current_health
	_health_label.text = "HP: %d / %d" % [
		roundi(current_health),
		roundi(maximum_health),
	]


func _on_health_changed(
	_previous_health: float,
	current_health: float,
	maximum_health: float
) -> void:
	_update_display(current_health, maximum_health)
