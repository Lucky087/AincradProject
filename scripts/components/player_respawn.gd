class_name PlayerRespawn
extends Node

## Coordinates player death, checkpoint data, respawning, and temporary immunity.
##
## The component keeps the existing player scene alive. It disables gameplay
## input during death, moves the same CharacterBody3D to the active checkpoint,
## restores health, and then returns control after the fade completes.

signal player_died
signal respawn_started
signal player_respawned(checkpoint_id: StringName)
signal respawn_invulnerability_started(duration_seconds: float)
signal respawn_invulnerability_ended
signal checkpoint_changed(checkpoint_id: StringName, checkpoint_transform: Transform3D)

@export_category("Timing")
@export_range(0.1, 10.0, 0.1) var death_wait_seconds: float = 3.0
@export_range(0.05, 3.0, 0.05) var fade_to_black_seconds: float = 0.45
@export_range(0.05, 3.0, 0.05) var fade_from_black_seconds: float = 0.55
@export_range(0.1, 10.0, 0.1) var respawn_invulnerability_seconds: float = 2.0

@export_category("Required Player Nodes")
@export var health_component_path: NodePath = NodePath("../HealthComponent")
@export var player_controller_path: NodePath = NodePath("..")
@export var player_combat_path: NodePath = NodePath("../PlayerCombat")
@export var player_interactor_path: NodePath = NodePath("../PlayerInteractor")
@export var inventory_ui_path: NodePath = NodePath("../InventoryUI")
@export var shop_ui_path: NodePath = NodePath("../ShopUI")
@export var death_ui_path: NodePath = NodePath("../DeathUI")

@export_category("Required Timers")
@export var death_wait_timer_path: NodePath = NodePath("DeathWaitTimer")
@export var invulnerability_timer_path: NodePath = NodePath("InvulnerabilityTimer")

var _player_body: CharacterBody3D = null
var _health_component: HealthComponent = null
var _player_controller: PlayerController = null
var _player_combat: PlayerCombat = null
var _player_interactor: PlayerInteractor = null
var _inventory_ui: InventoryUI = null
var _shop_ui: ShopUI = null
var _death_ui: DeathUI = null
var _death_wait_timer: Timer = null
var _invulnerability_timer: Timer = null

var _fallback_spawn_transform: Transform3D = Transform3D.IDENTITY
var _active_checkpoint_id: StringName = &""
var _active_checkpoint_transform: Transform3D = Transform3D.IDENTITY
var _is_dead: bool = false
var _is_respawning: bool = false
var _is_respawn_invulnerable: bool = false
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_fallback_spawn_transform = _player_body.global_transform
	_active_checkpoint_transform = _fallback_spawn_transform

	_health_component.died.connect(_on_health_component_died)
	_death_wait_timer.timeout.connect(_on_death_wait_timer_timeout)
	_invulnerability_timer.timeout.connect(_on_invulnerability_timer_timeout)
	_death_ui.fade_to_black_finished.connect(_on_fade_to_black_finished)
	_death_ui.fade_from_black_finished.connect(_on_fade_from_black_finished)
	_refresh_checkpoint_visuals()


## Returns true from lethal damage until the player has been placed back in play.
func is_player_dead() -> bool:
	return _is_dead


## Returns true while the fade/teleport part of the respawn sequence is active.
func is_respawning() -> bool:
	return _is_respawning


## Returns true during the post-respawn damage-immunity window.
func is_respawn_invulnerable() -> bool:
	return _is_respawn_invulnerable


## Returns whether enemies should currently treat this player as a valid target.
func can_be_targeted_by_enemies() -> bool:
	return (
		_setup_is_valid
		and not _is_dead
		and not _is_respawning
		and not _is_respawn_invulnerable
		and _health_component.is_alive()
	)


## Activates a stable checkpoint and fully heals the player once.
func activate_checkpoint(
	checkpoint_id: StringName,
	checkpoint_transform: Transform3D
) -> bool:
	if not _setup_is_valid:
		return false
	if checkpoint_id.is_empty():
		push_warning("PlayerRespawn rejected an empty checkpoint ID.")
		return false
	if _active_checkpoint_id == checkpoint_id:
		return false

	_active_checkpoint_id = checkpoint_id
	_active_checkpoint_transform = checkpoint_transform
	_health_component.reset_health()
	checkpoint_changed.emit(_active_checkpoint_id, _active_checkpoint_transform)
	_refresh_checkpoint_visuals()
	print("Checkpoint activated: %s" % _active_checkpoint_id)
	return true


func get_active_checkpoint_id() -> StringName:
	return _active_checkpoint_id


func get_active_checkpoint_transform() -> Transform3D:
	if _active_checkpoint_id.is_empty():
		return _fallback_spawn_transform
	return _active_checkpoint_transform


func is_checkpoint_active(checkpoint_id: StringName) -> bool:
	return not checkpoint_id.is_empty() and checkpoint_id == _active_checkpoint_id


## Returns only persistent checkpoint data. Death and fade state are temporary.
func get_save_data() -> Dictionary:
	var saved_transform: Transform3D = get_active_checkpoint_transform()
	var saved_rotation: Vector3 = saved_transform.basis.get_euler()
	return {
		"active_checkpoint_id": String(_active_checkpoint_id),
		"checkpoint_position": {
			"x": saved_transform.origin.x,
			"y": saved_transform.origin.y,
			"z": saved_transform.origin.z,
		},
		"checkpoint_rotation": {
			"x": saved_rotation.x,
			"y": saved_rotation.y,
			"z": saved_rotation.z,
		},
	}


## Restores checkpoint data and clears any temporary death sequence.
##
## Missing checkpoint data is expected for save versions 1 through 3 and uses
## the original scene spawn captured during _ready().
func load_save_data(data: Dictionary) -> void:
	if not _setup_is_valid:
		return

	_cancel_temporary_death_state_for_load()

	if data.is_empty():
		_active_checkpoint_id = &""
		_active_checkpoint_transform = _fallback_spawn_transform
		checkpoint_changed.emit(_active_checkpoint_id, _active_checkpoint_transform)
		_refresh_checkpoint_visuals()
		return

	var loaded_checkpoint_id: StringName = _read_checkpoint_id(data)
	if loaded_checkpoint_id.is_empty():
		_active_checkpoint_id = &""
		_active_checkpoint_transform = _fallback_spawn_transform
	else:
		var fallback_rotation: Vector3 = _fallback_spawn_transform.basis.get_euler()
		var loaded_position: Vector3 = _read_vector3_dictionary(
			data,
			"checkpoint_position",
			_fallback_spawn_transform.origin
		)
		var loaded_rotation: Vector3 = _read_vector3_dictionary(
			data,
			"checkpoint_rotation",
			fallback_rotation
		)
		_active_checkpoint_id = loaded_checkpoint_id
		_active_checkpoint_transform = Transform3D(
			Basis.from_euler(loaded_rotation),
			loaded_position
		)

	checkpoint_changed.emit(_active_checkpoint_id, get_active_checkpoint_transform())
	_refresh_checkpoint_visuals()

	# A valid save should never contain a dead player because saving is blocked
	# during death. Recover safely if an older or hand-edited file contains 0 HP.
	if not _health_component.is_alive():
		push_warning(
			"PlayerRespawn loaded a player with zero health; respawning at the safe location."
		)
		_move_player_to_respawn_transform()
		_health_component.reset_health()


func _on_health_component_died(_source: Node) -> void:
	if not _setup_is_valid or _is_dead or _is_respawning:
		return

	_is_dead = true
	_is_respawning = false
	_is_respawn_invulnerable = false
	_health_component.is_invulnerable = true
	_close_modal_interfaces()
	_set_gameplay_controls_enabled(false)
	_clear_player_velocity()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_death_ui.show_death_screen()
	_death_wait_timer.start(death_wait_seconds)
	player_died.emit()
	print("Player died. Respawn sequence started.")


func _on_death_wait_timer_timeout() -> void:
	if not _is_dead:
		return

	_is_respawning = true
	respawn_started.emit()
	_death_ui.fade_to_black(fade_to_black_seconds)


func _on_fade_to_black_finished() -> void:
	if not _is_dead or not _is_respawning:
		return

	_move_player_to_respawn_transform()
	_health_component.reset_health()
	_health_component.is_invulnerable = true
	_clear_player_velocity()
	_death_ui.prepare_for_fade_back()
	_death_ui.fade_from_black(fade_from_black_seconds)


func _on_fade_from_black_finished() -> void:
	if not _is_dead or not _is_respawning:
		return

	_is_dead = false
	_is_respawning = false
	_is_respawn_invulnerable = true
	_set_modal_interfaces_blocked(false)
	_set_gameplay_controls_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_death_ui.show_respawn_protection()
	_invulnerability_timer.start(respawn_invulnerability_seconds)
	player_respawned.emit(_active_checkpoint_id)
	respawn_invulnerability_started.emit(respawn_invulnerability_seconds)
	print(
		"Player respawned at checkpoint '%s' with %.1f seconds of protection."
		% [_get_checkpoint_debug_name(), respawn_invulnerability_seconds]
	)


func _on_invulnerability_timer_timeout() -> void:
	if not _is_respawn_invulnerable:
		return

	_is_respawn_invulnerable = false
	_health_component.is_invulnerable = false
	_death_ui.hide_respawn_protection()
	respawn_invulnerability_ended.emit()
	print("Respawn protection ended.")


func _move_player_to_respawn_transform() -> void:
	_player_body.global_transform = get_active_checkpoint_transform()
	_clear_player_velocity()


func _clear_player_velocity() -> void:
	if _player_body != null:
		_player_body.velocity = Vector3.ZERO


func _close_modal_interfaces() -> void:
	if _shop_ui != null and _shop_ui.is_shop_open():
		_shop_ui.close_shop()
	if _inventory_ui != null and _inventory_ui.is_inventory_open():
		_inventory_ui.close_inventory()
	_set_modal_interfaces_blocked(true)


func _set_modal_interfaces_blocked(is_blocked: bool) -> void:
	if _inventory_ui != null:
		_inventory_ui.set_external_open_blocked(is_blocked)
	if _shop_ui != null:
		_shop_ui.set_external_open_blocked(is_blocked)


func _set_gameplay_controls_enabled(is_enabled: bool) -> void:
	_player_controller.set_movement_input_enabled(is_enabled)
	_player_controller.set_process_unhandled_input(is_enabled)
	_player_combat.set_combat_input_enabled(is_enabled)
	_player_interactor.set_interaction_input_enabled(is_enabled)


func _cancel_temporary_death_state_for_load() -> void:
	var had_temporary_state: bool = (
		_is_dead or _is_respawning or _is_respawn_invulnerable
	)
	_death_wait_timer.stop()
	_invulnerability_timer.stop()
	_is_dead = false
	_is_respawning = false
	_is_respawn_invulnerable = false
	_health_component.is_invulnerable = false
	_death_ui.reset_ui_immediately()

	if had_temporary_state:
		_set_modal_interfaces_blocked(false)
		_set_gameplay_controls_enabled(true)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _refresh_checkpoint_visuals() -> void:
	if not is_inside_tree():
		return

	for checkpoint_node: Node in get_tree().get_nodes_in_group(&"checkpoints"):
		if not checkpoint_node.has_method("set_checkpoint_active"):
			continue

		var checkpoint_id_value: Variant = checkpoint_node.get("checkpoint_id")
		var checkpoint_id: StringName = &""
		if checkpoint_id_value is StringName:
			checkpoint_id = checkpoint_id_value as StringName
		elif checkpoint_id_value is String:
			checkpoint_id = StringName(checkpoint_id_value as String)

		checkpoint_node.call(
			"set_checkpoint_active",
			is_checkpoint_active(checkpoint_id)
		)


func _get_checkpoint_debug_name() -> String:
	if _active_checkpoint_id.is_empty():
		return "original_spawn"
	return String(_active_checkpoint_id)


func _read_checkpoint_id(data: Dictionary) -> StringName:
	var value: Variant = data.get("active_checkpoint_id", "")
	if value is StringName:
		return value as StringName
	if value is String:
		return StringName(value as String)

	push_warning("PlayerRespawn ignored an invalid active_checkpoint_id.")
	return &""


func _read_vector3_dictionary(
	data: Dictionary,
	key: String,
	fallback: Vector3
) -> Vector3:
	var value: Variant = data.get(key, {})
	if not value is Dictionary:
		push_warning("PlayerRespawn expected '%s' to be a Dictionary." % key)
		return fallback

	var vector_data: Dictionary = value as Dictionary
	return Vector3(
		_read_numeric_value(vector_data, "x", fallback.x, key),
		_read_numeric_value(vector_data, "y", fallback.y, key),
		_read_numeric_value(vector_data, "z", fallback.z, key)
	)


func _read_numeric_value(
	data: Dictionary,
	key: String,
	fallback: float,
	context: String
) -> float:
	var value: Variant = data.get(key, fallback)
	if value is int or value is float:
		return float(value)

	push_warning(
		"PlayerRespawn expected '%s.%s' to be numeric; using %.3f."
		% [context, key, fallback]
	)
	return fallback


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var parent_node: Node = get_parent()
	if parent_node is CharacterBody3D:
		_player_body = parent_node as CharacterBody3D
	else:
		push_error("PlayerRespawn must be a direct child of CharacterBody3D.")
		is_valid = false

	var health_node: Node = get_node_or_null(health_component_path)
	if health_node is HealthComponent:
		_health_component = health_node as HealthComponent
	else:
		push_error("PlayerRespawn could not find HealthComponent at: %s" % health_component_path)
		is_valid = false

	var controller_node: Node = get_node_or_null(player_controller_path)
	if controller_node is PlayerController:
		_player_controller = controller_node as PlayerController
	else:
		push_error("PlayerRespawn could not find PlayerController at: %s" % player_controller_path)
		is_valid = false

	var combat_node: Node = get_node_or_null(player_combat_path)
	if combat_node is PlayerCombat:
		_player_combat = combat_node as PlayerCombat
	else:
		push_error("PlayerRespawn could not find PlayerCombat at: %s" % player_combat_path)
		is_valid = false

	var interactor_node: Node = get_node_or_null(player_interactor_path)
	if interactor_node is PlayerInteractor:
		_player_interactor = interactor_node as PlayerInteractor
	else:
		push_error("PlayerRespawn could not find PlayerInteractor at: %s" % player_interactor_path)
		is_valid = false

	var inventory_ui_node: Node = get_node_or_null(inventory_ui_path)
	if inventory_ui_node is InventoryUI:
		_inventory_ui = inventory_ui_node as InventoryUI
	else:
		push_error("PlayerRespawn could not find InventoryUI at: %s" % inventory_ui_path)
		is_valid = false

	var shop_ui_node: Node = get_node_or_null(shop_ui_path)
	if shop_ui_node is ShopUI:
		_shop_ui = shop_ui_node as ShopUI
	else:
		push_error("PlayerRespawn could not find ShopUI at: %s" % shop_ui_path)
		is_valid = false

	var death_ui_node: Node = get_node_or_null(death_ui_path)
	if death_ui_node is DeathUI:
		_death_ui = death_ui_node as DeathUI
	else:
		push_error("PlayerRespawn could not find DeathUI at: %s" % death_ui_path)
		is_valid = false

	var death_timer_node: Node = get_node_or_null(death_wait_timer_path)
	if death_timer_node is Timer:
		_death_wait_timer = death_timer_node as Timer
	else:
		push_error("PlayerRespawn could not find DeathWaitTimer at: %s" % death_wait_timer_path)
		is_valid = false

	var invulnerability_timer_node: Node = get_node_or_null(invulnerability_timer_path)
	if invulnerability_timer_node is Timer:
		_invulnerability_timer = invulnerability_timer_node as Timer
	else:
		push_error(
			"PlayerRespawn could not find InvulnerabilityTimer at: %s"
			% invulnerability_timer_path
		)
		is_valid = false

	return is_valid
