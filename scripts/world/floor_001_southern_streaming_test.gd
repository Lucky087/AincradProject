class_name Floor001SouthernStreamingTest
extends Node3D

## Coordinates the isolated 7 x 7 southern Floor 1 streaming validation scene.
##
## FloorChunkStreamer owns manifest registration, threaded requests, visual LOD,
## collision, and unloading. This controller only handles test-scene concerns:
## safe manifest-derived placement, debug teleports, fall recovery, boundaries,
## camera range, and periodically refreshed diagnostics.

const PLAYER_GROUP: StringName = &"players"
const TERRAIN_COLLISION_MASK: int = 1
const LOCATION_CITY_GATE: String = "City-gate plateau"
const LOCATION_NORTH: String = "Northern continuation edge"
const LOCATION_WEST: String = "Western ridge transition"
const LOCATION_EAST: String = "Eastern lowland transition"
const LOCATION_CENTRE: String = "Centre chunk"
const MAX_SAFE_PLACEMENT_ATTEMPTS: int = 300

@export_category("Required Nodes")
@export var terrain_streamer_path: NodePath = NodePath("TerrainStreamer")
@export var player_path: NodePath = NodePath("Player")
@export var city_gate_spawn_path: NodePath = NodePath("SpawnMarkers/CityGateSpawn")
@export var northern_spawn_path: NodePath = NodePath("SpawnMarkers/NorthernTestSpawn")
@export var western_spawn_path: NodePath = NodePath("SpawnMarkers/WesternTestSpawn")
@export var eastern_spawn_path: NodePath = NodePath("SpawnMarkers/EasternTestSpawn")
@export var centre_spawn_path: NodePath = NodePath("SpawnMarkers/CentreChunkSpawn")
@export var fall_recovery_area_path: NodePath = NodePath("BoundarySafety/FallRecoveryArea")
@export var current_boundary_path: NodePath = NodePath("DebugVisualization/CurrentChunkBoundary")
@export var loaded_boundaries_path: NodePath = NodePath("DebugVisualization/LoadedChunkBoundaries")
@export var debug_label_path: NodePath = NodePath(
	"DebugUI/DebugPanel/MarginContainer/ScrollContainer/DebugLabel"
)
@export var debug_timer_path: NodePath = NodePath("DebugUI/DebugUpdateTimer")

@export_category("Test Settings")
@export_range(1.0, 40.0, 0.5) var manifest_spawn_clearance_metres: float = 10.0
@export_range(10.0, 200.0, 1.0) var raycast_margin_metres: float = 60.0
@export_range(0.1, 2.0, 0.05) var debug_update_interval_seconds: float = 0.25
@export_range(250.0, 2000.0, 10.0) var test_camera_far_metres: float = 1100.0
@export var show_loaded_chunk_boundaries: bool = true

var _terrain_streamer: FloorChunkStreamer = null
var _player: CharacterBody3D = null
var _city_gate_spawn: Marker3D = null
var _northern_spawn: Marker3D = null
var _western_spawn: Marker3D = null
var _eastern_spawn: Marker3D = null
var _centre_spawn: Marker3D = null
var _fall_recovery_area: Area3D = null
var _current_boundary: MeshInstance3D = null
var _loaded_boundaries: MeshInstance3D = null
var _debug_label: Label = null
var _debug_timer: Timer = null

var _current_boundary_material: StandardMaterial3D = null
var _loaded_boundary_material: StandardMaterial3D = null
var _pending_safe_placement: Dictionary = {}
var _safe_placement_attempts: int = 0
var _collision_ready_physics_frames: int = 0
var _safe_recovery_position: Vector3 = Vector3(0.0, 30.0, 3835.0)
var _current_test_location: String = "Manifest validation"
var _last_test_message: String = "Waiting for southern terrain manifest validation"
var _last_boundary_signature: String = ""
var _setup_is_valid: bool = false
var _boundaries_visible: bool = true


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		_update_debug_display()
		return

	_set_player_simulation_enabled(false)
	_configure_test_camera()
	_create_boundary_materials()
	_debug_timer.wait_time = debug_update_interval_seconds
	_debug_timer.timeout.connect(_on_debug_update_timer_timeout)
	_fall_recovery_area.body_entered.connect(_on_fall_recovery_area_body_entered)
	_terrain_streamer.manifest_loaded.connect(_on_manifest_loaded)
	_terrain_streamer.current_chunk_changed.connect(_on_current_chunk_changed)
	_terrain_streamer.streaming_state_changed.connect(_on_streaming_state_changed)
	_terrain_streamer.streaming_warning.connect(_on_streaming_warning)

	if _terrain_streamer.is_manifest_ready():
		call_deferred("_begin_initial_setup")
	else:
		var snapshot: Dictionary = _terrain_streamer.get_debug_snapshot()
		_last_test_message = (
			"Southern manifest unavailable: %s"
			% String(snapshot.get("manifest_status", "validation did not complete"))
		)
	_update_debug_display()


func _physics_process(_delta: float) -> void:
	if _pending_safe_placement.is_empty() or not _setup_is_valid:
		return

	_safe_placement_attempts += 1
	var target_grid: Vector2i = _pending_safe_placement.get("grid", Vector2i.ZERO)
	if not _terrain_streamer.is_collision_active_at(target_grid):
		if _safe_placement_attempts >= MAX_SAFE_PLACEMENT_ATTEMPTS:
			_abort_safe_placement(
				"Collision did not become active; player remains safely suspended"
			)
		return

	_collision_ready_physics_frames += 1
	if _collision_ready_physics_frames < 2:
		return

	var target_xz: Vector2 = _pending_safe_placement.get("xz", Vector2.ZERO)
	var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(target_grid)
	if entry.is_empty():
		_finish_safe_placement_with_manifest_fallback()
		return

	var bounds: Dictionary = entry.get("bounds", {})
	var ray_start: Vector3 = Vector3(
		target_xz.x, float(bounds.get("max_y", 0.0)) + raycast_margin_metres, target_xz.y
	)
	var ray_end: Vector3 = Vector3(
		target_xz.x, float(bounds.get("min_y", 0.0)) - raycast_margin_metres, target_xz.y
	)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		ray_start, ray_end, TERRAIN_COLLISION_MASK
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [_player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		if _safe_placement_attempts >= MAX_SAFE_PLACEMENT_ATTEMPTS:
			_finish_safe_placement_with_manifest_fallback()
		return

	var hit_position: Vector3 = hit.get("position", ray_start)
	_finish_safe_placement(hit_position + Vector3.UP * 0.18, true)


func _unhandled_key_input(event: InputEvent) -> void:
	if not _setup_is_valid or not event is InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	var keycode: Key = key_event.keycode
	if keycode == KEY_NONE:
		keycode = key_event.physical_keycode

	match keycode:
		KEY_F1:
			_begin_safe_placement(_city_gate_spawn, LOCATION_CITY_GATE)
		KEY_F2:
			_begin_safe_placement(_northern_spawn, LOCATION_NORTH)
		KEY_F3:
			_begin_safe_placement(_western_spawn, LOCATION_WEST)
		KEY_F4:
			_begin_safe_placement(_eastern_spawn, LOCATION_EAST)
		KEY_F9:
			_begin_safe_placement(_centre_spawn, LOCATION_CENTRE)
		KEY_B:
			_toggle_boundaries()
		_:
			return

	get_viewport().set_input_as_handled()


func _on_manifest_loaded(chunk_count: int) -> void:
	if chunk_count != 49:
		_last_test_message = "Manifest registered %d chunks instead of 49" % chunk_count
		_update_debug_display()
		return
	_begin_initial_setup()


func _begin_initial_setup() -> void:
	if not _terrain_streamer.is_manifest_ready():
		return
	_last_test_message = "Southern manifest passed; preparing city-gate collision"
	_begin_safe_placement(_city_gate_spawn, LOCATION_CITY_GATE)


func _begin_safe_placement(marker: Marker3D, location_name: String) -> void:
	if marker == null:
		_last_test_message = "Teleport marker is unavailable"
		_update_debug_display()
		return
	if not _terrain_streamer.is_manifest_ready():
		_last_test_message = "Teleport blocked because manifest validation did not pass"
		_update_debug_display()
		return

	var target_xz: Vector2 = Vector2(marker.global_position.x, marker.global_position.z)
	var target_grid: Vector2i = _terrain_streamer.get_grid_coordinate(
		Vector3(target_xz.x, 0.0, target_xz.y)
	)
	if not _terrain_streamer.has_grid_coordinate(target_grid):
		_last_test_message = ("No southern manifest chunk exists at %s" % _format_grid(target_grid))
		_update_debug_display()
		return

	var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(target_grid)
	var bounds: Dictionary = entry.get("bounds", {})
	var holding_position: Vector3 = Vector3(
		target_xz.x, float(bounds.get("max_y", 0.0)) + manifest_spawn_clearance_metres, target_xz.y
	)
	_set_player_simulation_enabled(false)
	_player.global_position = holding_position
	_player.velocity = Vector3.ZERO
	_pending_safe_placement = {
		"grid": target_grid,
		"xz": target_xz,
		"location": location_name,
		"fallback_position": holding_position,
	}
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_current_test_location = location_name
	_last_test_message = "Loading terrain and collision for %s" % location_name
	_terrain_streamer.force_streaming_update()
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _finish_safe_placement(target_position: Vector3, raycast_confirmed: bool) -> void:
	var location_name: String = String(
		_pending_safe_placement.get("location", _current_test_location)
	)
	_player.global_position = target_position
	_player.velocity = Vector3.ZERO
	if location_name == LOCATION_CITY_GATE:
		_safe_recovery_position = target_position
	_pending_safe_placement.clear()
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_set_player_simulation_enabled(true)
	_last_test_message = (
		(
			"Placed safely on terrain at %s"
			if raycast_confirmed
			else "Used manifest-safe fallback at %s"
		)
		% location_name
	)
	_terrain_streamer.force_streaming_update()
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _finish_safe_placement_with_manifest_fallback() -> void:
	if _pending_safe_placement.is_empty():
		return
	var fallback_position: Vector3 = _pending_safe_placement.get(
		"fallback_position", _safe_recovery_position
	)
	_finish_safe_placement(fallback_position, false)


func _abort_safe_placement(reason: String) -> void:
	_player.velocity = Vector3.ZERO
	_pending_safe_placement.clear()
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_set_player_simulation_enabled(false)
	_last_test_message = reason
	_update_debug_display()


func _set_player_simulation_enabled(enabled: bool) -> void:
	if _player == null:
		return
	_player.velocity = Vector3.ZERO
	_player.set_physics_process(enabled)


func _configure_test_camera() -> void:
	var camera_node: Node = _player.get_node_or_null("CameraYaw/CameraPitch/SpringArm3D/Camera3D")
	if camera_node is Camera3D:
		(camera_node as Camera3D).far = test_camera_far_metres


func _on_current_chunk_changed(
	_grid_coordinate: Vector2i, _chunk_id: StringName, _coordinate_exists: bool
) -> void:
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _on_streaming_state_changed() -> void:
	_refresh_boundary_visualization(false)


func _on_streaming_warning(message: String) -> void:
	_last_test_message = message
	_update_debug_display()


func _on_fall_recovery_area_body_entered(body: Node3D) -> void:
	if body != _player and not body.is_in_group(PLAYER_GROUP):
		return
	if not body is CharacterBody3D:
		return

	_player.global_position = _safe_recovery_position
	_player.velocity = Vector3.ZERO
	_last_test_message = "Fall recovery returned the same player to the city gate"
	_current_test_location = LOCATION_CITY_GATE
	_begin_safe_placement(_city_gate_spawn, LOCATION_CITY_GATE)


func _on_debug_update_timer_timeout() -> void:
	_refresh_boundary_visualization(false)
	_update_debug_display()


func _toggle_boundaries() -> void:
	_boundaries_visible = not _boundaries_visible
	_current_boundary.visible = _boundaries_visible
	_loaded_boundaries.visible = _boundaries_visible and show_loaded_chunk_boundaries
	_last_test_message = (
		"Chunk boundaries shown" if _boundaries_visible else "Chunk boundaries hidden"
	)
	_update_debug_display()


func _create_boundary_materials() -> void:
	_current_boundary_material = StandardMaterial3D.new()
	_current_boundary_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_current_boundary_material.albedo_color = Color(0.2, 0.95, 1.0, 1.0)
	_current_boundary_material.no_depth_test = true

	_loaded_boundary_material = StandardMaterial3D.new()
	_loaded_boundary_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_loaded_boundary_material.albedo_color = Color(1.0, 0.72, 0.18, 0.65)
	_loaded_boundary_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_loaded_boundary_material.no_depth_test = true


func _refresh_boundary_visualization(force_rebuild: bool) -> void:
	if _terrain_streamer == null or not _terrain_streamer.is_manifest_ready():
		_current_boundary.visible = false
		_loaded_boundaries.visible = false
		return

	var current_grid: Vector2i = _terrain_streamer.get_grid_coordinate(_player.global_position)
	var loaded_grids: Array[Vector2i] = _terrain_streamer.get_loaded_grid_coordinates()
	var signature_parts: PackedStringArray = [_format_grid(current_grid)]
	var loaded_grid_strings: PackedStringArray = []
	for coordinate: Vector2i in loaded_grids:
		loaded_grid_strings.append(_format_grid(coordinate))
	loaded_grid_strings.sort()
	for grid_text: String in loaded_grid_strings:
		signature_parts.append(grid_text)
	var signature: String = "|".join(signature_parts)
	if not force_rebuild and signature == _last_boundary_signature:
		return
	_last_boundary_signature = signature

	var current_coordinates: Array[Vector2i] = []
	if _terrain_streamer.has_grid_coordinate(current_grid):
		current_coordinates.append(current_grid)
	_build_boundary_mesh(_current_boundary, current_coordinates, _current_boundary_material, 1.0)

	var nearby_coordinates: Array[Vector2i] = []
	if show_loaded_chunk_boundaries:
		for coordinate: Vector2i in loaded_grids:
			if coordinate != current_grid:
				nearby_coordinates.append(coordinate)
	_build_boundary_mesh(_loaded_boundaries, nearby_coordinates, _loaded_boundary_material, 0.75)
	_current_boundary.visible = _boundaries_visible and not current_coordinates.is_empty()
	_loaded_boundaries.visible = (
		_boundaries_visible and show_loaded_chunk_boundaries and not nearby_coordinates.is_empty()
	)


func _build_boundary_mesh(
	mesh_instance: MeshInstance3D,
	coordinates: Array[Vector2i],
	material: Material,
	height_offset: float
) -> void:
	var immediate_mesh: ImmediateMesh = ImmediateMesh.new()
	if coordinates.is_empty():
		mesh_instance.mesh = immediate_mesh
		return

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for coordinate: Vector2i in coordinates:
		var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(coordinate)
		if entry.is_empty():
			continue
		var bounds: Dictionary = entry.get("bounds", {})
		var min_x: float = float(bounds.get("min_x", 0.0))
		var max_x: float = float(bounds.get("max_x", 0.0))
		var min_z: float = float(bounds.get("min_z", 0.0))
		var max_z: float = float(bounds.get("max_z", 0.0))
		var y: float = float(bounds.get("max_y", 0.0)) + height_offset
		_add_line(immediate_mesh, Vector3(min_x, y, min_z), Vector3(max_x, y, min_z))
		_add_line(immediate_mesh, Vector3(max_x, y, min_z), Vector3(max_x, y, max_z))
		_add_line(immediate_mesh, Vector3(max_x, y, max_z), Vector3(min_x, y, max_z))
		_add_line(immediate_mesh, Vector3(min_x, y, max_z), Vector3(min_x, y, min_z))
	immediate_mesh.surface_end()
	mesh_instance.mesh = immediate_mesh


func _add_line(mesh: ImmediateMesh, from_position: Vector3, to_position: Vector3) -> void:
	mesh.surface_add_vertex(from_position)
	mesh.surface_add_vertex(to_position)


func _update_debug_display() -> void:
	if _debug_label == null:
		return
	if _terrain_streamer == null:
		_debug_label.text = "Floor 1 Southern Streaming Test\nTerrainStreamer unavailable"
		return

	var snapshot: Dictionary = _terrain_streamer.get_debug_snapshot()
	var player_position: Vector3 = snapshot.get("player_position", Vector3.ZERO)
	var current_grid: Vector2i = snapshot.get("current_grid", Vector2i.ZERO)
	var current_chunk_text: String = String(snapshot.get("current_chunk_id", &""))
	if current_chunk_text.is_empty():
		current_chunk_text = "<outside southern manifest>"

	var loaded_ids_value: Variant = snapshot.get("loaded_chunk_ids", [])
	var loaded_ids: PackedStringArray = []
	if loaded_ids_value is Array:
		for loaded_id_value: Variant in loaded_ids_value:
			loaded_ids.append(String(loaded_id_value))
	var loaded_id_lines: String = _format_loaded_ids(loaded_ids)

	_debug_label.text = (
		"Floor 1 Southern 7 x 7 Streaming Validation\n"
		+ "Dataset: %s\n" % String(snapshot.get("manifest_dataset_id", "<missing>"))
		+ (
			"Manifest validation: %s\n"
			% String(snapshot.get("manifest_validation_result", "NOT RUN"))
		)
		+ "Manifest status: %s\n" % String(snapshot.get("manifest_status", "Unknown"))
		+ (
			"Export status: %s\n"
			% String(snapshot.get("manifest_generation_status", "<not supplied>"))
		)
		+ "Seam validation: %s\n" % _passed_text(bool(snapshot.get("manifest_seams_passed", false)))
		+ "Registered chunks: %d / 49\n" % int(snapshot.get("registry_chunk_count", 0))
		+ "Player: (%.1f, %.1f, %.1f)\n" % [player_position.x, player_position.y, player_position.z]
		+ "Current grid: %s\n" % _format_grid(current_grid)
		+ "Current chunk: %s\n" % current_chunk_text
		+ "Current test location: %s\n" % _current_test_location
		+ "Loaded roots: %d\n" % int(snapshot.get("loaded_chunk_count", 0))
		+ (
			"LOD0 active: %d | LOD1 active: %d\n"
			% [
				int(snapshot.get("lod0_chunk_count", 0)),
				int(snapshot.get("lod1_chunk_count", 0)),
			]
		)
		+ "Collision active: %d\n" % int(snapshot.get("collision_chunk_count", 0))
		+ (
			"Pending loads: %d | Failed: %d\n"
			% [
				int(snapshot.get("pending_load_count", 0)),
				int(snapshot.get("failed_load_count", 0)),
			]
		)
		+ (
			"Completed loads: %d | Unloads: %d\n"
			% [
				int(snapshot.get("completed_load_count", 0)),
				int(snapshot.get("unload_count", 0)),
			]
		)
		+ (
			"Last update: %.3f ms | Recent: %.3f ms\n"
			% [
				float(snapshot.get("last_streaming_update_duration_ms", 0.0)),
				float(snapshot.get("recent_streaming_update_duration_ms", 0.0)),
			]
		)
		+ "Loaded chunk IDs:\n%s\n" % loaded_id_lines
		+ "F1 Gate | F2 North | F3 West | F4 East | F9 Centre | B Boundaries\n"
		+ "Last message: %s" % _last_test_message
	)


func _format_loaded_ids(loaded_ids: PackedStringArray) -> String:
	if loaded_ids.is_empty():
		return "  <none>"
	var lines: PackedStringArray = []
	var current_line: PackedStringArray = []
	for loaded_id: String in loaded_ids:
		current_line.append(loaded_id)
		if current_line.size() == 3:
			lines.append("  " + " | ".join(current_line))
			current_line.clear()
	if not current_line.is_empty():
		lines.append("  " + " | ".join(current_line))
	return "\n".join(lines)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true
	var streamer_node: Node = get_node_or_null(terrain_streamer_path)
	if streamer_node is FloorChunkStreamer:
		_terrain_streamer = streamer_node as FloorChunkStreamer
	else:
		push_error("Floor001SouthernStreamingTest could not find TerrainStreamer.")
		is_valid = false

	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		push_error("Floor001SouthernStreamingTest could not find Player.")
		is_valid = false

	_city_gate_spawn = _resolve_marker(city_gate_spawn_path, "CityGateSpawn")
	_northern_spawn = _resolve_marker(northern_spawn_path, "NorthernTestSpawn")
	_western_spawn = _resolve_marker(western_spawn_path, "WesternTestSpawn")
	_eastern_spawn = _resolve_marker(eastern_spawn_path, "EasternTestSpawn")
	_centre_spawn = _resolve_marker(centre_spawn_path, "CentreChunkSpawn")
	if (
		_city_gate_spawn == null
		or _northern_spawn == null
		or _western_spawn == null
		or _eastern_spawn == null
		or _centre_spawn == null
	):
		is_valid = false

	var fall_area_node: Node = get_node_or_null(fall_recovery_area_path)
	if fall_area_node is Area3D:
		_fall_recovery_area = fall_area_node as Area3D
	else:
		push_error("Floor001SouthernStreamingTest could not find FallRecoveryArea.")
		is_valid = false

	var current_boundary_node: Node = get_node_or_null(current_boundary_path)
	if current_boundary_node is MeshInstance3D:
		_current_boundary = current_boundary_node as MeshInstance3D
	else:
		push_error("Floor001SouthernStreamingTest could not find CurrentChunkBoundary.")
		is_valid = false

	var loaded_boundaries_node: Node = get_node_or_null(loaded_boundaries_path)
	if loaded_boundaries_node is MeshInstance3D:
		_loaded_boundaries = loaded_boundaries_node as MeshInstance3D
	else:
		push_error("Floor001SouthernStreamingTest could not find LoadedChunkBoundaries.")
		is_valid = false

	var debug_label_node: Node = get_node_or_null(debug_label_path)
	if debug_label_node is Label:
		_debug_label = debug_label_node as Label
	else:
		push_error("Floor001SouthernStreamingTest could not find DebugLabel.")
		is_valid = false

	var debug_timer_node: Node = get_node_or_null(debug_timer_path)
	if debug_timer_node is Timer:
		_debug_timer = debug_timer_node as Timer
	else:
		push_error("Floor001SouthernStreamingTest could not find DebugUpdateTimer.")
		is_valid = false

	return is_valid


func _resolve_marker(path: NodePath, marker_name: String) -> Marker3D:
	var marker_node: Node = get_node_or_null(path)
	if marker_node is Marker3D:
		return marker_node as Marker3D
	push_error("Floor001SouthernStreamingTest could not find %s." % marker_name)
	return null


func _format_grid(coordinate: Vector2i) -> String:
	return "(%+d, %+d)" % [coordinate.x, coordinate.y]


func _passed_text(value: bool) -> String:
	return "PASSED" if value else "FAILED"
