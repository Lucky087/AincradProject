class_name Floor001Outskirts
extends Node3D

## Coordinates Floor 1 spawn safety without owning persistent player data.
##
## The scene validates positions restored by SaveManager and returns players who
## fall below the greybox terrain to their active checkpoint or floor spawn.

@export_category("Stable Floor Bounds")
@export var playable_minimum: Vector3 = Vector3(-168.0, -5.0, -168.0)
@export var playable_maximum: Vector3 = Vector3(168.0, 60.0, 168.0)
@export var player_group: StringName = &"players"

@export_category("Required Nodes")
@export var player_spawn_path: NodePath = NodePath("SpawnMarkers/PlayerSpawn")
@export var starting_checkpoint_path: NodePath = NodePath("SafeZone/CityGateCheckpoint")
@export var fall_safety_volume_path: NodePath = NodePath("WorldBoundaries/FallSafetyVolume")

var _player_spawn: Marker3D = null
var _starting_checkpoint: CheckpointCrystal = null
var _fall_safety_volume: Area3D = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_fall_safety_volume.body_entered.connect(_on_fall_safety_volume_body_entered)
	_connect_to_save_manager()
	call_deferred("_validate_loaded_player_and_checkpoint")


func _on_fall_safety_volume_body_entered(body: Node3D) -> void:
	if not _setup_is_valid or not body.is_in_group(player_group):
		return

	var player_body: CharacterBody3D = body as CharacterBody3D
	if player_body == null:
		push_warning("Floor001Outskirts found a non-CharacterBody3D player group member.")
		return

	var respawn_component: PlayerRespawn = _find_player_respawn(player_body)
	var health_component: HealthComponent = _find_health_component(player_body)
	var safe_transform: Transform3D = _player_spawn.global_transform

	if respawn_component != null:
		var checkpoint_transform: Transform3D = respawn_component.get_active_checkpoint_transform()
		if _is_transform_inside_playable_region(checkpoint_transform):
			safe_transform = checkpoint_transform

	player_body.global_transform = safe_transform
	player_body.velocity = Vector3.ZERO
	if health_component != null:
		health_component.reset_health()

	print("Player recovered from the Floor 1 fall-safety volume.")


func _on_game_loaded(_save_path: String) -> void:
	call_deferred("_validate_loaded_player_and_checkpoint")


func _validate_loaded_player_and_checkpoint() -> void:
	if not _setup_is_valid:
		return

	var player_body: CharacterBody3D = _find_player_body()
	if player_body == null:
		push_warning("Floor001Outskirts could not find the player for load validation.")
		return

	var respawn_component: PlayerRespawn = _find_player_respawn(player_body)
	if respawn_component != null:
		_validate_checkpoint_transform(respawn_component)

	if _is_position_inside_playable_region(player_body.global_position):
		return

	push_warning("Loaded player position was outside Floor 1 bounds; using PlayerSpawn.")
	player_body.global_transform = _player_spawn.global_transform
	player_body.velocity = Vector3.ZERO


func _validate_checkpoint_transform(respawn_component: PlayerRespawn) -> void:
	if respawn_component.get_active_checkpoint_id().is_empty():
		return

	var checkpoint_transform: Transform3D = respawn_component.get_active_checkpoint_transform()
	if _is_transform_inside_playable_region(checkpoint_transform):
		return

	var respawn_marker: Marker3D = _get_starting_checkpoint_respawn_marker()
	if respawn_marker == null:
		push_warning("Floor001Outskirts could not migrate an invalid checkpoint transform.")
		return

	push_warning("Loaded checkpoint was outside Floor 1 bounds; using the city-gate checkpoint.")
	respawn_component.activate_checkpoint(
		_starting_checkpoint.checkpoint_id, respawn_marker.global_transform
	)


func _is_transform_inside_playable_region(value: Transform3D) -> bool:
	return _is_position_inside_playable_region(value.origin)


func _is_position_inside_playable_region(position: Vector3) -> bool:
	return (
		position.x >= playable_minimum.x
		and position.x <= playable_maximum.x
		and position.y >= playable_minimum.y
		and position.y <= playable_maximum.y
		and position.z >= playable_minimum.z
		and position.z <= playable_maximum.z
	)


func _find_player_body() -> CharacterBody3D:
	var player_node: Node = get_tree().get_first_node_in_group(player_group)
	if player_node is CharacterBody3D:
		return player_node as CharacterBody3D
	return null


func _find_player_respawn(player_root: Node) -> PlayerRespawn:
	for child_node: Node in player_root.get_children():
		if child_node is PlayerRespawn:
			return child_node as PlayerRespawn
	return null


func _find_health_component(player_root: Node) -> HealthComponent:
	for child_node: Node in player_root.get_children():
		if child_node is HealthComponent:
			return child_node as HealthComponent
	return null


func _get_starting_checkpoint_respawn_marker() -> Marker3D:
	var marker_node: Node = _starting_checkpoint.get_node_or_null("RespawnPoint")
	if marker_node is Marker3D:
		return marker_node as Marker3D
	return null


func _connect_to_save_manager() -> void:
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if save_manager == null:
		push_warning("Floor001Outskirts could not find SaveManager; load fallback is unavailable.")
		return
	if not save_manager.has_signal("load_completed"):
		push_warning("Floor001Outskirts found SaveManager without load_completed.")
		return

	var callback: Callable = Callable(self, "_on_game_loaded")
	if not save_manager.is_connected("load_completed", callback):
		save_manager.connect("load_completed", callback)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var spawn_node: Node = get_node_or_null(player_spawn_path)
	if spawn_node is Marker3D:
		_player_spawn = spawn_node as Marker3D
	else:
		push_error("Floor001Outskirts could not find PlayerSpawn at: %s" % player_spawn_path)
		is_valid = false

	var checkpoint_node: Node = get_node_or_null(starting_checkpoint_path)
	if checkpoint_node is CheckpointCrystal:
		_starting_checkpoint = checkpoint_node as CheckpointCrystal
	else:
		push_error(
			(
				"Floor001Outskirts could not find the starting checkpoint at: %s"
				% starting_checkpoint_path
			)
		)
		is_valid = false

	var safety_node: Node = get_node_or_null(fall_safety_volume_path)
	if safety_node is Area3D:
		_fall_safety_volume = safety_node as Area3D
	else:
		push_error(
			"Floor001Outskirts could not find FallSafetyVolume at: %s" % fall_safety_volume_path
		)
		is_valid = false

	return is_valid
