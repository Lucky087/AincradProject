class_name Floor001MainRoadPreview
extends Node3D

# gdlint: disable=max-line-length
# gdlint: disable=max-returns

## F6-only preview for the permanent southern main-road greybox.
##
## The preview owns no progression or save state. It instances the existing
## player, permanent southern region, and reusable road assembly separately.

const PLAYER_GROUP: StringName = &"players"
const WORLD_COLLISION_MASK: int = 1
const MAX_SAFE_PLACEMENT_ATTEMPTS: int = 360
const NORTHERN_EXIT_CONTROL: StringName = &"road_north_continuation"

@export_category("Required Nodes")
@export var region_path: NodePath = NodePath("SouthernRegion")
@export var road_assembly_path: NodePath = NodePath("MainRoadAssembly")
@export var player_path: NodePath = NodePath("Player")
@export var fall_recovery_area_path: NodePath = NodePath("PreviewSafety/FallRecoveryArea")
@export var current_boundary_path: NodePath = NodePath("DebugVisualization/CurrentChunkBoundary")
@export var loaded_boundaries_path: NodePath = NodePath("DebugVisualization/LoadedChunkBoundaries")
@export var debug_label_path: NodePath = NodePath(
	"DebugUI/DebugPanel/MarginContainer/ScrollContainer/DebugLabel"
)
@export var debug_timer_path: NodePath = NodePath("DebugUI/DebugUpdateTimer")

@export_category("Preview Settings")
@export_range(1.0, 40.0, 0.5) var spawn_clearance_metres: float = 12.0
@export_range(10.0, 200.0, 1.0) var raycast_margin_metres: float = 70.0
@export_range(0.1, 2.0, 0.05) var debug_update_interval_seconds: float = 0.25
@export_range(500.0, 3000.0, 10.0) var preview_camera_far_metres: float = 1800.0
@export var show_loaded_chunk_boundaries: bool = true

var _region: Floor001SouthernRegion = null
var _road: Floor001MainRoadAssembly = null
var _terrain_streamer: FloorChunkStreamer = null
var _player: CharacterBody3D = null
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
var _safe_recovery_position: Vector3 = Vector3(0.0, 11.0, 3835.0)
var _boundaries_visible: bool = true
var _last_boundary_signature: String = ""
var _current_test_location: String = "Preparing main-road preview"
var _last_message: String = "Resolving preview scenes"
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		_update_debug_display()
		return
	_set_player_simulation_enabled(false)
	_configure_preview_camera()
	_create_debug_materials()
	_debug_timer.wait_time = debug_update_interval_seconds
	_debug_timer.timeout.connect(_on_debug_update_timer_timeout)
	_fall_recovery_area.body_entered.connect(_on_fall_recovery_area_body_entered)
	_terrain_streamer.current_chunk_changed.connect(_on_current_chunk_changed)
	_terrain_streamer.streaming_state_changed.connect(_on_streaming_state_changed)
	_terrain_streamer.streaming_warning.connect(_on_streaming_warning)
	_road.road_assembly_warning.connect(_on_road_warning)
	_road.road_assembly_failed.connect(_on_road_failed)
	_road.road_assembly_ready.connect(_on_road_ready)
	_region.assign_streaming_target(_player)
	if (
		_region.is_configuration_ready()
		and _terrain_streamer.is_manifest_ready()
		and _road.is_assembly_ready()
	):
		call_deferred("_teleport_to_control_point", &"road_gate", "Gate-road start")
	else:
		_last_message = "Region, terrain, or road assembly is not ready"
	_update_debug_display()


func _physics_process(_delta: float) -> void:
	if not _setup_is_valid or _pending_safe_placement.is_empty():
		return
	_safe_placement_attempts += 1
	var target_grid: Vector2i = _pending_safe_placement.get("grid", Vector2i.ZERO)
	if not _terrain_streamer.is_collision_active_at(target_grid):
		if _safe_placement_attempts >= MAX_SAFE_PLACEMENT_ATTEMPTS:
			_abort_safe_placement("Terrain collision did not become active at the target.")
		return
	_collision_ready_physics_frames += 1
	if _collision_ready_physics_frames < 2:
		return

	var target_xz: Vector2 = _pending_safe_placement.get("xz", Vector2.ZERO)
	var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(target_grid)
	var bounds: Dictionary = entry.get("bounds", {})
	var ray_start: Vector3 = Vector3(
		target_xz.x, float(bounds.get("max_y", 0.0)) + raycast_margin_metres, target_xz.y
	)
	var ray_end: Vector3 = Vector3(
		target_xz.x, float(bounds.get("min_y", 0.0)) - raycast_margin_metres, target_xz.y
	)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		ray_start, ray_end, WORLD_COLLISION_MASK
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [_player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		if _safe_placement_attempts >= MAX_SAFE_PLACEMENT_ATTEMPTS:
			_finish_safe_placement(
				_pending_safe_placement.get("fallback_position", _safe_recovery_position), false
			)
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
			_teleport_to_control_point(&"road_gate", "Gate-road start")
		KEY_F2:
			_teleport_to_control_point(&"road_01", "MainRoadControl01")
		KEY_F3:
			_teleport_to_control_point(&"road_02", "MainRoadControl02")
		KEY_F4:
			_teleport_to_control_point(&"road_03", "MainRoadControl03")
		KEY_N:
			_teleport_to_control_point(NORTHERN_EXIT_CONTROL, "Northern road exit")
		KEY_R:
			_road.set_spline_debug_visible(not _road.is_spline_debug_visible())
			_last_message = (
				"Road spline shown" if _road.is_spline_debug_visible() else "Road spline hidden"
			)
		KEY_P:
			_road.set_placement_markers_visible(not _road.are_placement_markers_visible())
			_last_message = (
				"Road placement markers shown"
				if _road.are_placement_markers_visible()
				else "Road placement markers hidden"
			)
		KEY_E:
			_road.set_edging_visible(not _road.is_edging_visible())
			_last_message = (
				"Sparse visual edging shown" if _road.is_edging_visible() else "Road edging hidden"
			)
		KEY_B:
			_boundaries_visible = not _boundaries_visible
			_refresh_boundary_visualization(true)
			_last_message = (
				"Terrain boundaries shown" if _boundaries_visible else "Terrain boundaries hidden"
			)
		_:
			return
	get_viewport().set_input_as_handled()
	_update_debug_display()


func _teleport_to_control_point(control_point_id: StringName, location_name: String) -> void:
	if not _road.is_assembly_ready():
		_last_message = "Teleport blocked because the road assembly is not ready"
		_update_debug_display()
		return
	var target_position: Vector3 = _road.get_control_point_world_position(control_point_id)
	if target_position == Vector3.ZERO and control_point_id != &"road_gate":
		_last_message = "Unknown road control point: %s" % String(control_point_id)
		_update_debug_display()
		return
	_begin_safe_placement(location_name, target_position)


func _begin_safe_placement(location_name: String, target_world_position: Vector3) -> void:
	if not _terrain_streamer.is_manifest_ready():
		_last_message = "Teleport blocked because the southern terrain manifest is not ready"
		_update_debug_display()
		return
	var target_grid: Vector2i = _terrain_streamer.get_grid_coordinate(target_world_position)
	if not _terrain_streamer.has_grid_coordinate(target_grid):
		_last_message = "Teleport target is outside the southern terrain manifest"
		_update_debug_display()
		return
	var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(target_grid)
	var bounds: Dictionary = entry.get("bounds", {})
	var holding_position: Vector3 = Vector3(
		target_world_position.x,
		float(bounds.get("max_y", target_world_position.y)) + spawn_clearance_metres,
		target_world_position.z
	)
	var fallback_position: Vector3 = target_world_position + Vector3.UP * 2.0
	_set_player_simulation_enabled(false)
	_player.global_position = holding_position
	_player.velocity = Vector3.ZERO
	_pending_safe_placement = {
		"grid": target_grid,
		"xz": Vector2(target_world_position.x, target_world_position.z),
		"fallback_position": fallback_position,
	}
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_current_test_location = location_name
	_last_message = "Loading terrain collision for %s" % location_name
	_terrain_streamer.force_streaming_update()
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _finish_safe_placement(target_position: Vector3, raycast_confirmed: bool) -> void:
	_player.global_position = target_position
	_player.velocity = Vector3.ZERO
	_safe_recovery_position = target_position
	_pending_safe_placement.clear()
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_set_player_simulation_enabled(true)
	_last_message = (
		"Player placed on authoritative terrain collision"
		if raycast_confirmed
		else "Player placed at the marker-derived fallback"
	)
	_terrain_streamer.force_streaming_update()
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _abort_safe_placement(reason: String) -> void:
	_player.velocity = Vector3.ZERO
	_pending_safe_placement.clear()
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_set_player_simulation_enabled(false)
	_last_message = reason
	_update_debug_display()


func _set_player_simulation_enabled(enabled: bool) -> void:
	if _player == null:
		return
	_player.velocity = Vector3.ZERO
	_player.set_physics_process(enabled)


func _configure_preview_camera() -> void:
	var camera_node: Node = _player.get_node_or_null("CameraYaw/CameraPitch/SpringArm3D/Camera3D")
	if camera_node is Camera3D:
		(camera_node as Camera3D).far = preview_camera_far_metres


func _on_fall_recovery_area_body_entered(body: Node3D) -> void:
	if body != _player and not body.is_in_group(PLAYER_GROUP):
		return
	_player.global_position = _safe_recovery_position
	_player.velocity = Vector3.ZERO
	_last_message = "Preview-only fall recovery returned the same player to the road"
	_teleport_to_control_point(&"road_gate", "Gate-road start")


func _on_current_chunk_changed(
	_grid_coordinate: Vector2i, _chunk_id: StringName, _coordinate_exists: bool
) -> void:
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _on_streaming_state_changed() -> void:
	_refresh_boundary_visualization(false)
	_update_debug_display()


func _on_streaming_warning(message: String) -> void:
	_last_message = message
	_update_debug_display()


func _on_road_warning(message: String) -> void:
	_last_message = message
	_update_debug_display()


func _on_road_failed(message: String) -> void:
	_last_message = "Road assembly failed: %s" % message
	_update_debug_display()


func _on_road_ready() -> void:
	_last_message = "Road assembly ready"
	_update_debug_display()


func _on_debug_update_timer_timeout() -> void:
	_refresh_boundary_visualization(false)
	_update_debug_display()


func _create_debug_materials() -> void:
	_current_boundary_material = _make_line_material(Color(1.0, 0.86, 0.22, 0.95))
	_loaded_boundary_material = _make_line_material(Color(0.25, 0.72, 1.0, 0.58))


func _make_line_material(colour: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = colour
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	return material


func _refresh_boundary_visualization(force_rebuild: bool) -> void:
	if not _terrain_streamer.is_manifest_ready():
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
	var mesh: ImmediateMesh = ImmediateMesh.new()
	if coordinates.is_empty():
		mesh_instance.mesh = mesh
		return
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for coordinate: Vector2i in coordinates:
		var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(coordinate)
		var bounds: Dictionary = entry.get("bounds", {})
		var min_x: float = float(bounds.get("min_x", 0.0))
		var max_x: float = float(bounds.get("max_x", 0.0))
		var min_z: float = float(bounds.get("min_z", 0.0))
		var max_z: float = float(bounds.get("max_z", 0.0))
		var y: float = float(bounds.get("max_y", 0.0)) + height_offset
		_add_line(mesh, Vector3(min_x, y, min_z), Vector3(max_x, y, min_z))
		_add_line(mesh, Vector3(max_x, y, min_z), Vector3(max_x, y, max_z))
		_add_line(mesh, Vector3(max_x, y, max_z), Vector3(min_x, y, max_z))
		_add_line(mesh, Vector3(min_x, y, max_z), Vector3(min_x, y, min_z))
	mesh.surface_end()
	mesh_instance.mesh = mesh


func _add_line(mesh: ImmediateMesh, from_position: Vector3, to_position: Vector3) -> void:
	mesh.surface_add_vertex(from_position)
	mesh.surface_add_vertex(to_position)


func _update_debug_display() -> void:
	if _debug_label == null:
		return
	if _terrain_streamer == null or _road == null or _player == null:
		_debug_label.text = "Floor 1 Main Road Preview\nRequired nodes unavailable"
		return
	var terrain_snapshot: Dictionary = _terrain_streamer.get_debug_snapshot()
	var road_snapshot: Dictionary = _road.get_debug_snapshot()
	var player_position: Vector3 = _player.global_position
	var current_grid: Vector2i = terrain_snapshot.get("current_grid", Vector2i.ZERO)
	var distance_along: float = _road.get_distance_along_road(player_position)
	var nearest_segment: String = String(_road.get_nearest_placement_id(player_position))
	if nearest_segment.is_empty():
		nearest_segment = "<none>"
	_debug_label.text = (
		"Floor 1 Main Northbound Road Preview\n"
		+ "Road ID: %s\n" % String(road_snapshot.get("road_id", "<missing>"))
		+ (
			"Status: %s\n"
			% ("READY" if bool(road_snapshot.get("road_ready", false)) else "NOT READY")
		)
		+ "Control points: %d\n" % int(road_snapshot.get("control_point_count", 0))
		+ (
			"Placements: %d | Straight: %d | Left: %d | Right: %d\n"
			% [
				int(road_snapshot.get("placement_count", 0)),
				int(road_snapshot.get("straight_piece_count", 0)),
				int(road_snapshot.get("left_curve_count", 0)),
				int(road_snapshot.get("right_curve_count", 0)),
			]
		)
		+ "Player: (%.1f, %.1f, %.1f)\n" % [player_position.x, player_position.y, player_position.z]
		+ (
			"Distance along road: %.1f / %.1f m\n"
			% [distance_along, float(road_snapshot.get("path_length_m", 0.0))]
		)
		+ "Nearest segment: %s\n" % nearest_segment
		+ (
			"Terrain grid: %s | Chunk: %s\n"
			% [
				_format_grid(current_grid),
				String(terrain_snapshot.get("current_chunk_id", "<outside>")),
			]
		)
		+ (
			"Loaded terrain: %d | Pending: %d | Failed: %d\n"
			% [
				int(terrain_snapshot.get("loaded_chunk_count", 0)),
				int(terrain_snapshot.get("pending_load_count", 0)),
				int(terrain_snapshot.get("failed_load_count", 0)),
			]
		)
		+ (
			"Road collision: %s (flat collision created: NO)\n"
			% String(road_snapshot.get("collision_policy", "unknown"))
		)
		+ (
			"Road failed assets: %d | Edging: %s\n"
			% [
				int(road_snapshot.get("failed_asset_count", 0)),
				"ON" if _road.is_edging_visible() else "OFF",
			]
		)
		+ "Location: %s\n" % _current_test_location
		+ "F1 Gate | F2 CP1 | F3 CP2 | F4 CP3 | N North exit\n"
		+ "R Spline | P Placements | E Edging | B Chunk boundaries\n"
		+ "Last message: %s" % _last_message
	)


func _resolve_required_nodes() -> bool:
	var valid: bool = true
	var region_node: Node = get_node_or_null(region_path)
	if region_node is Floor001SouthernRegion:
		_region = region_node as Floor001SouthernRegion
		_terrain_streamer = _region.get_terrain_streamer()
	else:
		valid = false
	var road_node: Node = get_node_or_null(road_assembly_path)
	if road_node is Floor001MainRoadAssembly:
		_road = road_node as Floor001MainRoadAssembly
	else:
		valid = false
	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		valid = false
	_fall_recovery_area = get_node_or_null(fall_recovery_area_path) as Area3D
	_current_boundary = get_node_or_null(current_boundary_path) as MeshInstance3D
	_loaded_boundaries = get_node_or_null(loaded_boundaries_path) as MeshInstance3D
	_debug_label = get_node_or_null(debug_label_path) as Label
	_debug_timer = get_node_or_null(debug_timer_path) as Timer
	if (
		_terrain_streamer == null
		or _fall_recovery_area == null
		or _current_boundary == null
		or _loaded_boundaries == null
		or _debug_label == null
		or _debug_timer == null
	):
		valid = false
	if not valid:
		push_error("Floor001MainRoadPreview: required nodes could not be resolved.")
	return valid


func _format_grid(coordinate: Vector2i) -> String:
	return "(%+d, %+d)" % [coordinate.x, coordinate.y]
