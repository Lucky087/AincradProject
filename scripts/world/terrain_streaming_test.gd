class_name TerrainStreamingTest
extends Node3D

## Coordinates the isolated runtime streaming test scene.
##
## The reusable loading logic remains in FloorChunkStreamer. This script only
## handles test-scene concerns: initial spawn, debug UI, current-cell boundary,
## test teleports, and fall recovery without touching persistent player data.

const PLAYER_GROUP: StringName = &"players"
const TELEPORT_NORTH: Vector2i = Vector2i(0, -1)
const TELEPORT_SOUTH: Vector2i = Vector2i(0, 1)
const TELEPORT_WEST: Vector2i = Vector2i(-1, 0)
const TELEPORT_EAST: Vector2i = Vector2i(1, 0)

@export_category("Required Nodes")
@export var terrain_streamer_path: NodePath = NodePath("TerrainStreamer")
@export var player_path: NodePath = NodePath("Player")
@export var fall_recovery_area_path: NodePath = NodePath("BoundarySafety/FallRecoveryArea")
@export var current_boundary_path: NodePath = NodePath("DebugVisualization/CurrentChunkBoundary")
@export var debug_label_path: NodePath = NodePath("DebugUI/DebugPanel/MarginContainer/DebugLabel")
@export var debug_timer_path: NodePath = NodePath("DebugUI/DebugUpdateTimer")

@export_category("Test Settings")
@export_range(1.0, 30.0, 0.5) var player_spawn_height_metres: float = 8.0
@export_range(0.1, 2.0, 0.05) var debug_update_interval_seconds: float = 0.25

var _terrain_streamer: FloorChunkStreamer = null
var _player: CharacterBody3D = null
var _fall_recovery_area: Area3D = null
var _current_boundary: MeshInstance3D = null
var _debug_label: Label = null
var _debug_timer: Timer = null
var _safe_recovery_position: Vector3 = Vector3.ZERO
var _setup_is_valid: bool = false
var _last_test_message: String = "Waiting for terrain manifest"


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		_update_debug_display()
		return

	_debug_timer.wait_time = debug_update_interval_seconds
	_debug_timer.timeout.connect(_on_debug_update_timer_timeout)
	_fall_recovery_area.body_entered.connect(_on_fall_recovery_area_body_entered)
	_terrain_streamer.manifest_loaded.connect(_on_manifest_loaded)
	_terrain_streamer.current_chunk_changed.connect(_on_current_chunk_changed)
	_terrain_streamer.streaming_warning.connect(_on_streaming_warning)

	if _terrain_streamer.is_manifest_ready():
		_finish_initial_setup()


func _unhandled_key_input(event: InputEvent) -> void:
	if not _setup_is_valid or not event is InputEventKey:
		return

	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo or not key_event.ctrl_pressed:
		return

	var direction: Vector2i = Vector2i.ZERO
	var keycode: Key = key_event.keycode
	if keycode == KEY_NONE:
		keycode = key_event.physical_keycode

	match keycode:
		KEY_UP:
			direction = TELEPORT_NORTH
		KEY_DOWN:
			direction = TELEPORT_SOUTH
		KEY_LEFT:
			direction = TELEPORT_WEST
		KEY_RIGHT:
			direction = TELEPORT_EAST
		_:
			return

	_teleport_one_chunk(direction)
	get_viewport().set_input_as_handled()


func _on_manifest_loaded(_chunk_count: int) -> void:
	_finish_initial_setup()


func _finish_initial_setup() -> void:
	var centre_grid: Vector2i = _terrain_streamer.get_centre_grid_coordinate()
	var spawn_position: Vector3 = _terrain_streamer.get_spawn_position_for_chunk(
		centre_grid, player_spawn_height_metres
	)
	if spawn_position == Vector3.ZERO:
		push_error("TerrainStreamingTest could not calculate the centre spawn.")
		_last_test_message = "Centre spawn calculation failed"
		return

	_safe_recovery_position = spawn_position
	_move_player_to(spawn_position)
	_update_boundary(centre_grid, true)
	_last_test_message = "Streaming test ready"
	_terrain_streamer.force_streaming_update()
	_update_debug_display()


func _teleport_one_chunk(direction: Vector2i) -> void:
	var current_grid: Vector2i = _terrain_streamer.get_grid_coordinate(_player.global_position)
	var target_grid: Vector2i = current_grid + direction
	if not _terrain_streamer.has_grid_coordinate(target_grid):
		_last_test_message = (
			"No generated chunk at %s; teleport cancelled." % _format_grid(target_grid)
		)
		print("TerrainStreamingTest: %s" % _last_test_message)
		_update_debug_display()
		return

	var target_position: Vector3 = _terrain_streamer.get_spawn_position_for_chunk(
		target_grid, player_spawn_height_metres
	)
	_move_player_to(target_position)
	_last_test_message = (
		"Teleported to %s at %s."
		% [_terrain_streamer.get_chunk_id_at(target_grid), _format_grid(target_grid)]
	)
	print("TerrainStreamingTest: %s" % _last_test_message)
	_terrain_streamer.force_streaming_update()
	_update_debug_display()


func _move_player_to(target_position: Vector3) -> void:
	_player.global_position = target_position
	_player.velocity = Vector3.ZERO


func _on_current_chunk_changed(
	grid_coordinate: Vector2i, _chunk_id: StringName, coordinate_exists: bool
) -> void:
	_update_boundary(grid_coordinate, coordinate_exists)
	_update_debug_display()


func _update_boundary(grid_coordinate: Vector2i, coordinate_exists: bool) -> void:
	if _current_boundary == null:
		return
	if not coordinate_exists:
		_current_boundary.visible = false
		return

	var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(grid_coordinate)
	if entry.is_empty():
		_current_boundary.visible = false
		return

	var bounds: Dictionary = entry["bounds"]
	_current_boundary.global_position = Vector3(
		(float(bounds["min_x"]) + float(bounds["max_x"])) * 0.5,
		float(bounds["max_y"]) + 0.35,
		(float(bounds["min_z"]) + float(bounds["max_z"])) * 0.5
	)
	_current_boundary.visible = true


func _on_fall_recovery_area_body_entered(body: Node3D) -> void:
	if body != _player and not body.is_in_group(PLAYER_GROUP):
		return

	var player_body: CharacterBody3D = body as CharacterBody3D
	if player_body == null:
		push_warning("TerrainStreamingTest fall volume received a non-player body.")
		return

	player_body.global_position = _safe_recovery_position
	player_body.velocity = Vector3.ZERO
	_last_test_message = "Fall recovery returned the player to the centre chunk."
	print("TerrainStreamingTest: %s" % _last_test_message)
	_terrain_streamer.force_streaming_update()
	_update_debug_display()


func _on_debug_update_timer_timeout() -> void:
	_update_debug_display()


func _on_streaming_warning(message: String) -> void:
	_last_test_message = message
	_update_debug_display()


func _update_debug_display() -> void:
	if _debug_label == null:
		return
	if _terrain_streamer == null:
		_debug_label.text = "Floor 1 Runtime Streaming Test\nTerrainStreamer unavailable"
		return

	var snapshot: Dictionary = _terrain_streamer.get_debug_snapshot()
	var player_position: Vector3 = snapshot.get("player_position", Vector3.ZERO)
	var current_grid: Vector2i = snapshot.get("current_grid", Vector2i.ZERO)
	var current_chunk_id: StringName = snapshot.get("current_chunk_id", &"")
	var current_chunk_text: String = String(current_chunk_id)
	if current_chunk_text.is_empty():
		current_chunk_text = "<outside test manifest>"

	var loaded_ids_value: Variant = snapshot.get("loaded_chunk_ids", [])
	var loaded_id_strings: PackedStringArray = []
	if loaded_ids_value is Array:
		for loaded_id_value: Variant in loaded_ids_value:
			loaded_id_strings.append(String(loaded_id_value))
	var loaded_id_lines: String = "  <none>"
	if not loaded_id_strings.is_empty():
		loaded_id_lines = "  " + "\n  ".join(loaded_id_strings)

	_debug_label.text = (
		"Floor 1 Runtime Terrain Streaming Test\n"
		+ "Player: (%.1f, %.1f, %.1f)\n" % [player_position.x, player_position.y, player_position.z]
		+ "Grid: %s\n" % _format_grid(current_grid)
		+ "Current chunk: %s\n" % current_chunk_text
		+ (
			"Coordinate in manifest: %s\n"
			% _yes_no(bool(snapshot.get("current_coordinate_exists", false)))
		)
		+ "Loaded roots: %d\n" % int(snapshot.get("loaded_chunk_count", 0))
		+ "LOD0 active: %d\n" % int(snapshot.get("lod0_chunk_count", 0))
		+ "LOD1 active: %d\n" % int(snapshot.get("lod1_chunk_count", 0))
		+ "Collision active: %d\n" % int(snapshot.get("collision_chunk_count", 0))
		+ "Loading requests: %d\n" % int(snapshot.get("loading_request_count", 0))
		+ "Failed loads: %d\n" % int(snapshot.get("failed_load_count", 0))
		+ "Manifest: %s\n" % String(snapshot.get("manifest_status", "Unknown"))
		+ "Manifest seams: %s\n" % _passed_text(bool(snapshot.get("manifest_seams_passed", false)))
		+ "Loaded chunk IDs:\n%s\n" % loaded_id_lines
		+ "Ctrl+Arrow: teleport one generated chunk\n"
		+ "Last message: %s" % _last_test_message
	)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true
	var streamer_node: Node = get_node_or_null(terrain_streamer_path)
	if streamer_node is FloorChunkStreamer:
		_terrain_streamer = streamer_node as FloorChunkStreamer
	else:
		push_error("TerrainStreamingTest could not find TerrainStreamer.")
		is_valid = false

	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		push_error("TerrainStreamingTest could not find Player.")
		is_valid = false

	var fall_area_node: Node = get_node_or_null(fall_recovery_area_path)
	if fall_area_node is Area3D:
		_fall_recovery_area = fall_area_node as Area3D
	else:
		push_error("TerrainStreamingTest could not find FallRecoveryArea.")
		is_valid = false

	var boundary_node: Node = get_node_or_null(current_boundary_path)
	if boundary_node is MeshInstance3D:
		_current_boundary = boundary_node as MeshInstance3D
	else:
		push_error("TerrainStreamingTest could not find CurrentChunkBoundary.")
		is_valid = false

	var debug_label_node: Node = get_node_or_null(debug_label_path)
	if debug_label_node is Label:
		_debug_label = debug_label_node as Label
	else:
		push_error("TerrainStreamingTest could not find DebugLabel.")
		is_valid = false

	var debug_timer_node: Node = get_node_or_null(debug_timer_path)
	if debug_timer_node is Timer:
		_debug_timer = debug_timer_node as Timer
	else:
		push_error("TerrainStreamingTest could not find DebugUpdateTimer.")
		is_valid = false

	return is_valid


func _format_grid(coordinate: Vector2i) -> String:
	return "(%+d, %+d)" % [coordinate.x, coordinate.y]


func _yes_no(value: bool) -> String:
	return "YES" if value else "NO"


func _passed_text(value: bool) -> String:
	return "PASSED" if value else "FAILED / UNAVAILABLE"
