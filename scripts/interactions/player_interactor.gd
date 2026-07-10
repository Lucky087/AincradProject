class_name PlayerInteractor
extends Node3D

## Detects one camera-targeted Interactable and handles the interact input.
##
## The camera ray chooses the object in the centre of the view. A separate
## player-to-object distance check prevents interaction with distant objects.

const INTERACT_ACTION: StringName = &"interact"

@export_category("Interaction")
@export_range(0.5, 10.0, 0.1) var maximum_interaction_distance: float = 4.0
@export var ray_cast_path: NodePath
@export var interaction_ui_path: NodePath

var _ray_cast: RayCast3D = null
var _interaction_ui: InteractionUI = null
var _current_target: Interactable = null
var _setup_is_valid: bool = false
var _interaction_input_enabled: bool = true


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	_setup_is_valid = _validate_input_action() and _setup_is_valid

	if _setup_is_valid:
		_add_player_to_ray_exceptions()
	else:
		set_physics_process(false)
		set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _interaction_input_enabled:
		return

	if event.is_action_pressed(INTERACT_ACTION):
		_try_interact()
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if not _interaction_input_enabled:
		return

	_update_current_target()


## Enables or disables interaction targeting and input.
func set_interaction_input_enabled(is_enabled: bool) -> void:
	_interaction_input_enabled = is_enabled
	if not is_enabled:
		_set_current_target(null)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	if ray_cast_path.is_empty():
		push_error("PlayerInteractor has no ray_cast_path assigned.")
		is_valid = false
	else:
		var ray_cast_node: Node = get_node_or_null(ray_cast_path)
		if ray_cast_node is RayCast3D:
			_ray_cast = ray_cast_node as RayCast3D
		else:
			push_error(
				"PlayerInteractor could not find a RayCast3D at: %s"
				% ray_cast_path
			)
			is_valid = false

	if interaction_ui_path.is_empty():
		push_error("PlayerInteractor has no interaction_ui_path assigned.")
		is_valid = false
	else:
		var ui_node: Node = get_node_or_null(interaction_ui_path)
		if ui_node is InteractionUI:
			_interaction_ui = ui_node as InteractionUI
		else:
			push_error(
				"PlayerInteractor could not find an InteractionUI at: %s"
				% interaction_ui_path
			)
			is_valid = false

	return is_valid


func _validate_input_action() -> bool:
	if InputMap.has_action(INTERACT_ACTION):
		return true

	push_error("Missing Input Map action: %s" % INTERACT_ACTION)
	return false


func _add_player_to_ray_exceptions() -> void:
	if _ray_cast == null:
		return

	var player_body: Node = get_parent()
	if player_body is CollisionObject3D:
		_ray_cast.add_exception(player_body as CollisionObject3D)
	else:
		push_warning(
			"PlayerInteractor's parent is not a CollisionObject3D. "
			+ "The interaction ray could hit the player."
		)


func _update_current_target() -> void:
	if not is_instance_valid(_current_target):
		_current_target = null

	var new_target: Interactable = _find_targeted_interactable()
	_set_current_target(new_target)


func _find_targeted_interactable() -> Interactable:
	if _ray_cast == null or not _ray_cast.is_colliding():
		return null

	var collider: Object = _ray_cast.get_collider()
	if not collider is Interactable:
		return null

	var interactable: Interactable = collider as Interactable
	var distance_to_target: float = global_position.distance_to(
		interactable.global_position
	)

	if distance_to_target > maximum_interaction_distance:
		return null

	if not interactable.is_interaction_available(self):
		return null

	return interactable


func _set_current_target(new_target: Interactable) -> void:
	_current_target = new_target

	if _interaction_ui == null:
		return

	if not is_instance_valid(_current_target):
		_interaction_ui.hide_prompt()
		return

	var prompt_text: String = _current_target.get_interaction_prompt(self)
	if prompt_text.is_empty():
		_interaction_ui.hide_prompt()
	else:
		_interaction_ui.show_prompt(prompt_text)


func _try_interact() -> void:
	if not is_instance_valid(_current_target):
		_set_current_target(null)
		return

	if not _current_target.is_interaction_available(self):
		_set_current_target(null)
		return

	var message: String = _current_target.interact(self)
	if _interaction_ui != null and not message.is_empty():
		_interaction_ui.show_message(message)

	# Refresh immediately because an interaction may disable the target,
	# as the one-use test chest does.
	_update_current_target()
