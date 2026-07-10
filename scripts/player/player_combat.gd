class_name PlayerCombat
extends Node3D

## Handles one basic player sword attack.
##
## A ShapeCast3D follows the player's facing direction and detects dedicated
## hurtbox areas. Damage is applied through reusable HealthComponent nodes.

signal attack_started
signal attack_hit(target: HealthComponent, damage_amount: float)
signal attack_finished

const ATTACK_ACTION: StringName = &"player_attack_primary"

@export_category("Attack")
@export_range(0.1, 1000.0, 0.1) var attack_damage: float = 25.0
@export_range(0.05, 2.0, 0.01) var swing_duration_seconds: float = 0.16
@export_range(0.05, 2.0, 0.01) var recovery_duration_seconds: float = 0.18
@export_range(0.0, 2.0, 0.01) var cooldown_seconds: float = 0.18
@export_range(1.0, 120.0, 1.0) var windup_angle_degrees: float = 55.0
@export_range(1.0, 160.0, 1.0) var swing_angle_degrees: float = 70.0

@export_category("Required Nodes")
@export var attack_shape_cast_path: NodePath
@export var sword_pivot_path: NodePath
@export var health_component_path: NodePath

var _attack_shape_cast: ShapeCast3D = null
var _sword_pivot: Node3D = null
var _health_component: HealthComponent = null
var _sword_rest_rotation: Vector3 = Vector3.ZERO
var _attack_tween: Tween = null
var _is_attacking: bool = false
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	_setup_is_valid = _validate_input_action() and _setup_is_valid

	if not _setup_is_valid:
		set_process_unhandled_input(false)
		return

	_sword_rest_rotation = _sword_pivot.rotation


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(ATTACK_ACTION):
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	_try_start_attack()
	get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if _attack_tween != null and _attack_tween.is_valid():
		_attack_tween.kill()


func _try_start_attack() -> void:
	if _is_attacking or not _setup_is_valid:
		return

	if _health_component != null and not _health_component.is_alive():
		return

	_is_attacking = true
	attack_started.emit()

	if _attack_tween != null and _attack_tween.is_valid():
		_attack_tween.kill()

	_sword_pivot.rotation = _sword_rest_rotation
	_sword_pivot.rotation.y += deg_to_rad(windup_angle_degrees)

	_attack_tween = create_tween()
	_attack_tween.set_trans(Tween.TRANS_QUAD)
	_attack_tween.set_ease(Tween.EASE_OUT)
	_attack_tween.tween_property(
		_sword_pivot,
		"rotation:y",
		_sword_rest_rotation.y - deg_to_rad(swing_angle_degrees),
		swing_duration_seconds
	)
	_attack_tween.tween_callback(Callable(self, "_apply_attack_damage"))
	_attack_tween.tween_property(
		_sword_pivot,
		"rotation:y",
		_sword_rest_rotation.y,
		recovery_duration_seconds
	)
	_attack_tween.tween_interval(cooldown_seconds)
	_attack_tween.tween_callback(Callable(self, "_finish_attack"))


func _apply_attack_damage() -> void:
	if _attack_shape_cast == null:
		return

	_attack_shape_cast.force_shapecast_update()

	var damaged_instance_ids: Dictionary[int, bool] = {}
	var collision_count: int = _attack_shape_cast.get_collision_count()

	for collision_index: int in range(collision_count):
		var collider: Object = _attack_shape_cast.get_collider(collision_index)
		if not collider is Node:
			continue

		var target_health: HealthComponent = _find_health_component(
			collider as Node
		)
		if target_health == null or target_health == _health_component:
			continue

		var target_instance_id: int = target_health.get_instance_id()
		if damaged_instance_ids.has(target_instance_id):
			continue

		damaged_instance_ids[target_instance_id] = true
		var applied_damage: float = target_health.apply_damage(
			attack_damage,
			get_parent()
		)

		if applied_damage > 0.0:
			attack_hit.emit(target_health, applied_damage)


func _finish_attack() -> void:
	if _sword_pivot != null:
		_sword_pivot.rotation = _sword_rest_rotation

	_is_attacking = false
	attack_finished.emit()


func _find_health_component(start_node: Node) -> HealthComponent:
	var current_node: Node = start_node

	while current_node != null:
		if current_node is HealthComponent:
			return current_node as HealthComponent

		for child_node: Node in current_node.get_children():
			if child_node is HealthComponent:
				return child_node as HealthComponent

		if current_node == get_tree().current_scene:
			break

		current_node = current_node.get_parent()

	return null


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var shape_cast_node: Node = get_node_or_null(attack_shape_cast_path)
	if shape_cast_node is ShapeCast3D:
		_attack_shape_cast = shape_cast_node as ShapeCast3D
	else:
		push_error(
			"PlayerCombat could not find a ShapeCast3D at: %s"
			% attack_shape_cast_path
		)
		is_valid = false

	var sword_pivot_node: Node = get_node_or_null(sword_pivot_path)
	if sword_pivot_node is Node3D:
		_sword_pivot = sword_pivot_node as Node3D
	else:
		push_error(
			"PlayerCombat could not find a Node3D sword pivot at: %s"
			% sword_pivot_path
		)
		is_valid = false

	var health_node: Node = get_node_or_null(health_component_path)
	if health_node is HealthComponent:
		_health_component = health_node as HealthComponent
	else:
		push_error(
			"PlayerCombat could not find a HealthComponent at: %s"
			% health_component_path
		)
		is_valid = false

	return is_valid


func _validate_input_action() -> bool:
	if InputMap.has_action(ATTACK_ACTION):
		return true

	push_error("Missing Input Map action: %s" % ATTACK_ACTION)
	return false
