class_name TrainingDummy
extends StaticBody3D

## Repeatable primitive target used to test health and sword damage.

@export_category("Training Dummy")
@export_range(0.5, 10.0, 0.1) var reset_delay_seconds: float = 3.0

@export_category("Required Nodes")
@export var health_component_path: NodePath = NodePath("HealthComponent")
@export var visual_root_path: NodePath = NodePath("VisualRoot")
@export var hurtbox_path: NodePath = NodePath("Hurtbox")
@export var status_label_path: NodePath = NodePath("StatusLabel")
@export var reset_timer_path: NodePath = NodePath("ResetTimer")

var _health_component: HealthComponent = null
var _visual_root: Node3D = null
var _hurtbox: Area3D = null
var _status_label: Label3D = null
var _reset_timer: Timer = null
var _feedback_tween: Tween = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_health_component.health_changed.connect(_on_health_changed)
	_health_component.damage_taken.connect(_on_damage_taken)
	_health_component.died.connect(_on_died)
	_reset_timer.timeout.connect(_on_reset_timer_timeout)
	_update_status_label(
		_health_component.get_current_health(),
		_health_component.get_maximum_health()
	)


func _exit_tree() -> void:
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var health_node: Node = get_node_or_null(health_component_path)
	if health_node is HealthComponent:
		_health_component = health_node as HealthComponent
	else:
		push_error("TrainingDummy is missing its HealthComponent.")
		is_valid = false

	var visual_node: Node = get_node_or_null(visual_root_path)
	if visual_node is Node3D:
		_visual_root = visual_node as Node3D
	else:
		push_error("TrainingDummy is missing VisualRoot.")
		is_valid = false

	var hurtbox_node: Node = get_node_or_null(hurtbox_path)
	if hurtbox_node is Area3D:
		_hurtbox = hurtbox_node as Area3D
	else:
		push_error("TrainingDummy is missing its Hurtbox Area3D.")
		is_valid = false

	var label_node: Node = get_node_or_null(status_label_path)
	if label_node is Label3D:
		_status_label = label_node as Label3D
	else:
		push_error("TrainingDummy is missing StatusLabel.")
		is_valid = false

	var timer_node: Node = get_node_or_null(reset_timer_path)
	if timer_node is Timer:
		_reset_timer = timer_node as Timer
	else:
		push_error("TrainingDummy is missing ResetTimer.")
		is_valid = false

	return is_valid


func _update_status_label(current_health: float, maximum_health: float) -> void:
	if _status_label == null:
		return

	_status_label.text = "Training Dummy\nHP: %d / %d" % [
		roundi(current_health),
		roundi(maximum_health),
	]


func _play_hit_feedback() -> void:
	if _visual_root == null:
		return

	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()

	_visual_root.scale = Vector3.ONE
	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_QUAD)
	_feedback_tween.set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(
		_visual_root,
		"scale",
		Vector3(1.08, 0.92, 1.08),
		0.06
	)
	_feedback_tween.tween_property(
		_visual_root,
		"scale",
		Vector3.ONE,
		0.12
	)


func _play_defeat_feedback() -> void:
	if _visual_root == null:
		return

	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()

	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_QUAD)
	_feedback_tween.set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(
		_visual_root,
		"rotation:z",
		deg_to_rad(12.0),
		0.2
	)


func _on_health_changed(
	_previous_health: float,
	current_health: float,
	maximum_health: float
) -> void:
	_update_status_label(current_health, maximum_health)


func _on_damage_taken(_amount: float, _source: Node) -> void:
	_play_hit_feedback()


func _on_died(_source: Node) -> void:
	if _hurtbox != null:
		_hurtbox.monitorable = false

	if _status_label != null:
		_status_label.text = "Training Dummy\nDefeated - resetting..."

	_play_defeat_feedback()
	_reset_timer.start(reset_delay_seconds)


func _on_reset_timer_timeout() -> void:
	if not _setup_is_valid:
		return

	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()

	_visual_root.scale = Vector3.ONE
	_visual_root.rotation = Vector3.ZERO
	_hurtbox.monitorable = true
	_health_component.reset_health()
