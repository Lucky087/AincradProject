class_name PlayerController
extends CharacterBody3D

## Controls the local third-person greybox player.
##
## This script intentionally handles only movement, jumping, gravity,
## sprinting, visual facing, camera rotation, and mouse capture.

const REQUIRED_INPUT_ACTIONS: Array[StringName] = [
	&"player_move_forward",
	&"player_move_backward",
	&"player_move_left",
	&"player_move_right",
	&"player_jump",
	&"player_sprint",
	&"player_toggle_mouse_capture",
]

@export_category("Movement")
@export_range(0.1, 20.0, 0.1) var walk_speed: float = 5.0
@export_range(0.1, 30.0, 0.1) var sprint_speed: float = 8.5
@export_range(0.1, 50.0, 0.1) var ground_acceleration: float = 24.0
@export_range(0.1, 50.0, 0.1) var air_acceleration: float = 8.0
@export_range(0.1, 20.0, 0.1) var jump_velocity: float = 6.5
@export_range(0.1, 30.0, 0.1) var visual_rotation_speed: float = 12.0

@export_category("Camera")
@export_range(0.0005, 0.02, 0.0005) var mouse_sensitivity: float = 0.003
@export_range(-89.0, -1.0, 1.0) var minimum_camera_pitch_degrees: float = -65.0
@export_range(1.0, 89.0, 1.0) var maximum_camera_pitch_degrees: float = 55.0

var _gravity_strength: float = 9.8

@onready var _visual_root: Node3D = %VisualRoot
@onready var _camera_yaw: Node3D = %CameraYaw
@onready var _camera_pitch: Node3D = %CameraPitch


func _ready() -> void:
	_validate_input_actions()
	_gravity_strength = float(
		ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_toggle_mouse_capture"):
		_toggle_mouse_capture()
		get_viewport().set_input_as_handled()
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		_rotate_camera(mouse_motion.relative)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()

	var input_vector: Vector2 = Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_forward",
		"player_move_backward"
	)
	var movement_direction: Vector3 = _get_camera_relative_direction(input_vector)

	_apply_horizontal_movement(movement_direction, delta)
	_rotate_visual_toward(movement_direction, delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity_strength * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0


func _handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("player_jump"):
		velocity.y = jump_velocity


func _get_camera_relative_direction(input_vector: Vector2) -> Vector3:
	if input_vector.length_squared() < 0.0001:
		return Vector3.ZERO

	var camera_basis: Basis = _camera_yaw.global_transform.basis
	var camera_right: Vector3 = camera_basis.x
	var camera_forward: Vector3 = -camera_basis.z

	camera_right.y = 0.0
	camera_forward.y = 0.0
	camera_right = camera_right.normalized()
	camera_forward = camera_forward.normalized()

	return (
		camera_right * input_vector.x
		+ camera_forward * -input_vector.y
	).normalized()


func _apply_horizontal_movement(
	movement_direction: Vector3,
	delta: float
) -> void:
	var target_speed: float = walk_speed
	if Input.is_action_pressed("player_sprint"):
		target_speed = sprint_speed

	var target_velocity: Vector3 = movement_direction * target_speed
	var acceleration: float = ground_acceleration
	if not is_on_floor():
		acceleration = air_acceleration

	velocity.x = move_toward(
		velocity.x,
		target_velocity.x,
		acceleration * delta
	)
	velocity.z = move_toward(
		velocity.z,
		target_velocity.z,
		acceleration * delta
	)


func _rotate_visual_toward(
	movement_direction: Vector3,
	delta: float
) -> void:
	if movement_direction.length_squared() < 0.0001:
		return

	var target_yaw: float = atan2(
		-movement_direction.x,
		-movement_direction.z
	)
	var rotation_weight: float = clampf(
		visual_rotation_speed * delta,
		0.0,
		1.0
	)
	_visual_root.rotation.y = lerp_angle(
		_visual_root.rotation.y,
		target_yaw,
		rotation_weight
	)


func _rotate_camera(mouse_delta: Vector2) -> void:
	_camera_yaw.rotate_y(-mouse_delta.x * mouse_sensitivity)
	_camera_pitch.rotate_x(-mouse_delta.y * mouse_sensitivity)
	_camera_pitch.rotation.x = clampf(
		_camera_pitch.rotation.x,
		deg_to_rad(minimum_camera_pitch_degrees),
		deg_to_rad(maximum_camera_pitch_degrees)
	)


func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _validate_input_actions() -> void:
	for action_name in REQUIRED_INPUT_ACTIONS:
		if not InputMap.has_action(action_name):
			push_error("Missing Input Map action: %s" % action_name)
