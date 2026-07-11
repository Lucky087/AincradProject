extends Node3D

## F6-only preview wrapper for the permanent Floor 1 southern production region.
##
## The permanent region remains player-independent. This scene instances the
## existing player, assigns it as the streamer's target, performs safe terrain
## placement, provides fall recovery, and draws lightweight debug guides.

const PLAYER_GROUP: StringName = &"players"
const TERRAIN_COLLISION_MASK: int = 1
const MAX_SAFE_PLACEMENT_ATTEMPTS: int = 300
const CITY_GATE_LOCATION: String = "PlayerSpawnCityGate"

@export_category("Required Nodes")
@export var region_path: NodePath = NodePath("SouthernRegion")
@export var player_path: NodePath = NodePath("Player")
@export var fall_recovery_area_path: NodePath = NodePath("PreviewSafety/FallRecoveryArea")
@export var current_boundary_path: NodePath = NodePath("DebugVisualization/CurrentChunkBoundary")
@export var loaded_boundaries_path: NodePath = NodePath("DebugVisualization/LoadedChunkBoundaries")
@export var region_guides_path: NodePath = NodePath("DebugVisualization/RegionGuides")
@export var debug_label_path: NodePath = NodePath(
	"DebugUI/DebugPanel/MarginContainer/ScrollContainer/DebugLabel"
)
@export var debug_timer_path: NodePath = NodePath("DebugUI/DebugUpdateTimer")

@export_category("Preview Settings")
@export_range(1.0, 40.0, 0.5) var spawn_clearance_metres: float = 10.0
@export_range(10.0, 200.0, 1.0) var raycast_margin_metres: float = 60.0
@export_range(0.1, 2.0, 0.05) var debug_update_interval_seconds: float = 0.25
@export_range(250.0, 2000.0, 10.0) var preview_camera_far_metres: float = 1100.0
@export var show_loaded_chunk_boundaries: bool = true
@export var show_region_guides: bool = true

var _region: Floor001SouthernRegion = null
var _terrain_streamer: FloorChunkStreamer = null
var _player: CharacterBody3D = null
var _fall_recovery_area: Area3D = null
var _current_boundary: MeshInstance3D = null
var _loaded_boundaries: MeshInstance3D = null
var _region_guides: MeshInstance3D = null
var _debug_label: Label = null
var _debug_timer: Timer = null

var _current_boundary_material: StandardMaterial3D = null
var _loaded_boundary_material: StandardMaterial3D = null
var _safe_zone_material: StandardMaterial3D = null
var _marker_material: StandardMaterial3D = null
var _pending_safe_placement: Dictionary = {}
var _safe_placement_attempts: int = 0
var _collision_ready_physics_frames: int = 0
var _safe_recovery_position: Vector3 = Vector3(0.0, 12.0, 3835.0)
var _inside_safe_zone: bool = false
var _boundaries_visible: bool = true
var _guides_visible: bool = true
var _last_boundary_signature: String = ""
var _last_message: String = "Preparing production-region preview"
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		_update_debug_display()
		return

	_set_player_simulation_enabled(false)
	_configure_preview_camera()
	_create_debug_materials()
	_build_region_guides()
	_debug_timer.wait_time = debug_update_interval_seconds
	_debug_timer.timeout.connect(_on_debug_update_timer_timeout)
	_fall_recovery_area.body_entered.connect(_on_fall_recovery_area_body_entered)
	_region.safe_zone_entered.connect(_on_safe_zone_entered)
	_region.safe_zone_exited.connect(_on_safe_zone_exited)
	_terrain_streamer.current_chunk_changed.connect(_on_current_chunk_changed)
	_terrain_streamer.streaming_state_changed.connect(_on_streaming_state_changed)
	_terrain_streamer.streaming_warning.connect(_on_streaming_warning)
	_region.assign_streaming_target(_player)

	if _region.is_configuration_ready() and _terrain_streamer.is_manifest_ready():
		call_deferred("_begin_initial_spawn")
	else:
		_last_message = "Region configuration or southern manifest is not ready"
	_update_debug_display()


func _physics_process(_delta: float) -> void:
	if not _setup_is_valid or _pending_safe_placement.is_empty():
		return

	_safe_placement_attempts += 1
	var target_grid: Vector2i = _pending_safe_placement.get("grid", Vector2i.ZERO)
	if not _terrain_streamer.is_collision_active_at(target_grid):
		if _safe_placement_attempts >= MAX_SAFE_PLACEMENT_ATTEMPTS:
			_abort_safe_placement("Terrain collision did not become active.")
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
		ray_start, ray_end, TERRAIN_COLLISION_MASK
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
			_begin_initial_spawn()
		KEY_B:
			_boundaries_visible = not _boundaries_visible
			_refresh_boundary_visualization(true)
			_last_message = (
				"Chunk boundaries shown" if _boundaries_visible else "Chunk boundaries hidden"
			)
		KEY_M:
			_guides_visible = not _guides_visible
			_region_guides.visible = _guides_visible
			_last_message = (
				"Stable markers and safe zone shown"
				if _guides_visible
				else "Stable markers and safe zone hidden"
			)
		_:
			return
	get_viewport().set_input_as_handled()
	_update_debug_display()


func _begin_initial_spawn() -> void:
	var spawn_marker: Marker3D = _region.get_player_spawn_marker()
	if spawn_marker == null:
		_last_message = "PlayerSpawnCityGate is unavailable"
		_update_debug_display()
		return
	_begin_safe_placement(spawn_marker)


func _begin_safe_placement(marker: Marker3D) -> void:
	if not _terrain_streamer.is_manifest_ready():
		_last_message = "Spawn blocked because manifest validation did not pass"
		_update_debug_display()
		return
	var target_xz: Vector2 = Vector2(marker.global_position.x, marker.global_position.z)
	var target_grid: Vector2i = _terrain_streamer.get_grid_coordinate(
		Vector3(target_xz.x, 0.0, target_xz.y)
	)
	if not _terrain_streamer.has_grid_coordinate(target_grid):
		_last_message = "Spawn marker is outside the southern terrain manifest"
		_update_debug_display()
		return
	var entry: Dictionary = _terrain_streamer.get_chunk_entry_at(target_grid)
	var bounds: Dictionary = entry.get("bounds", {})
	var holding_position: Vector3 = Vector3(
		target_xz.x,
		float(bounds.get("max_y", marker.global_position.y)) + spawn_clearance_metres,
		target_xz.y
	)
	var fallback_position: Vector3 = marker.global_position + Vector3.UP * 0.5
	_set_player_simulation_enabled(false)
	_player.global_position = holding_position
	_player.velocity = Vector3.ZERO
	_pending_safe_placement = {
		"grid": target_grid,
		"xz": target_xz,
		"fallback_position": fallback_position,
	}
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_last_message = "Loading city-gate terrain and collision"
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
		"Player placed on exported terrain collision"
		if raycast_confirmed
		else "Player placed at the marker-derived safe fallback"
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


func _on_safe_zone_entered(_safe_zone_id: StringName, body: Node3D) -> void:
	if body == _player or body.is_in_group(PLAYER_GROUP):
		_inside_safe_zone = true
		_last_message = "Entered the city-gate safe-zone placeholder"
		_update_debug_display()


func _on_safe_zone_exited(_safe_zone_id: StringName, body: Node3D) -> void:
	if body == _player or body.is_in_group(PLAYER_GROUP):
		_inside_safe_zone = false
		_last_message = "Exited the city-gate safe-zone placeholder"
		_update_debug_display()


func _on_fall_recovery_area_body_entered(body: Node3D) -> void:
	if body != _player and not body.is_in_group(PLAYER_GROUP):
		return
	_player.global_position = _safe_recovery_position
	_player.velocity = Vector3.ZERO
	_last_message = "Preview fall recovery returned the same player to the gate"
	_begin_initial_spawn()


func _on_current_chunk_changed(
	_grid_coordinate: Vector2i, _chunk_id: StringName, _coordinate_exists: bool
) -> void:
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _on_streaming_state_changed() -> void:
	_refresh_boundary_visualization(false)


func _on_streaming_warning(message: String) -> void:
	_last_message = message
	_update_debug_display()


func _on_debug_update_timer_timeout() -> void:
	_inside_safe_zone = _region.is_position_inside_safe_zone(_player.global_position)
	_refresh_boundary_visualization(false)
	_update_debug_display()


func _create_debug_materials() -> void:
	_current_boundary_material = _make_line_material(Color(0.2, 0.95, 1.0, 1.0))
	_loaded_boundary_material = _make_line_material(Color(1.0, 0.72, 0.18, 0.65))
	_safe_zone_material = _make_line_material(Color(0.25, 1.0, 0.48, 0.8))
	_marker_material = _make_line_material(Color(1.0, 0.35, 0.9, 0.9))


func _make_line_material(colour: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = colour
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	return material


func _build_region_guides() -> void:
	var mesh: ImmediateMesh = ImmediateMesh.new()
	var configuration: Dictionary = _region.get_configuration()
	var safe_zone_value: Variant = configuration.get("safe_zone", {})
	if safe_zone_value is Dictionary:
		var safe_zone: Dictionary = safe_zone_value
		var centre: Vector3 = _vector3_from_array(safe_zone.get("centre", []))
		var radius: float = float(safe_zone.get("radius_m", 0.0))
		mesh.surface_begin(Mesh.PRIMITIVE_LINES, _safe_zone_material)
		var segments: int = 64
		for index: int in range(segments):
			var first_angle: float = TAU * float(index) / float(segments)
			var second_angle: float = TAU * float(index + 1) / float(segments)
			_add_line(
				mesh,
				centre + Vector3(cos(first_angle) * radius, 1.25, sin(first_angle) * radius),
				centre + Vector3(cos(second_angle) * radius, 1.25, sin(second_angle) * radius)
			)
		mesh.surface_end()

	mesh.surface_begin(Mesh.PRIMITIVE_LINES, _marker_material)
	for marker_key: Variant in _collect_preview_marker_ids(configuration):
		var marker: Marker3D = _region.get_marker(StringName(String(marker_key)))
		if marker == null:
			continue
		var position: Vector3 = marker.global_position + Vector3.UP * 0.5
		_add_line(mesh, position + Vector3(-4.0, 0.0, 0.0), position + Vector3(4.0, 0.0, 0.0))
		_add_line(mesh, position + Vector3(0.0, 0.0, -4.0), position + Vector3(0.0, 0.0, 4.0))
		_add_line(mesh, position, position + Vector3.UP * 10.0)
	mesh.surface_end()
	_region_guides.mesh = mesh
	_region_guides.visible = show_region_guides and _guides_visible


func _collect_preview_marker_ids(configuration: Dictionary) -> PackedStringArray:
	var ids: PackedStringArray = []
	for key: String in ["spawn_markers", "landmark_markers"]:
		var definitions_value: Variant = configuration.get(key, [])
		if not definitions_value is Array:
			continue
		for definition_value: Variant in definitions_value:
			if definition_value is Dictionary:
				ids.append(String((definition_value as Dictionary).get("marker_id", "")))
	return ids


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
	if _terrain_streamer == null or _region == null or _player == null:
		_debug_label.text = "Floor 1 Southern Production Preview\nRequired nodes unavailable"
		return
	var snapshot: Dictionary = _terrain_streamer.get_debug_snapshot()
	var player_position: Vector3 = _player.global_position
	var current_grid: Vector2i = snapshot.get("current_grid", Vector2i.ZERO)
	var current_chunk: String = String(snapshot.get("current_chunk_id", &""))
	if current_chunk.is_empty():
		current_chunk = "<outside southern manifest>"
	_debug_label.text = (
		"Floor 1 Southern Production Region Preview\n"
		+ "Region ID: %s\n" % String(_region.get_region_id())
		+ "Dataset: %s\n" % String(snapshot.get("manifest_dataset_id", "<missing>"))
		+ "Manifest: %s\n" % String(snapshot.get("manifest_validation_result", "NOT RUN"))
		+ "Player: (%.1f, %.1f, %.1f)\n" % [player_position.x, player_position.y, player_position.z]
		+ "Current grid: %s\n" % _format_grid(current_grid)
		+ "Current chunk: %s\n" % current_chunk
		+ "Loaded roots: %d\n" % int(snapshot.get("loaded_chunk_count", 0))
		+ (
			"LOD0: %d | LOD1: %d | Collision: %d\n"
			% [
				int(snapshot.get("lod0_chunk_count", 0)),
				int(snapshot.get("lod1_chunk_count", 0)),
				int(snapshot.get("collision_chunk_count", 0)),
			]
		)
		+ (
			"Pending: %d | Failed: %d\n"
			% [
				int(snapshot.get("pending_load_count", 0)),
				int(snapshot.get("failed_load_count", 0)),
			]
		)
		+ "Inside safe zone: %s\n" % ("YES" if _inside_safe_zone else "NO")
		+ "Safe-zone ID: %s\n" % String(_region.get_safe_zone_id())
		+ "F1 Return to gate | B Chunk boundaries | M Markers/safe zone\n"
		+ "Last message: %s" % _last_message
	)


func _resolve_required_nodes() -> bool:
	var valid: bool = true
	var region_node: Node = get_node_or_null(region_path)
	if region_node is Floor001SouthernRegion:
		_region = region_node as Floor001SouthernRegion
	else:
		push_error("Southern region preview could not find the production region.")
		valid = false

	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		push_error("Southern region preview could not find Player.")
		valid = false

	var fall_area_node: Node = get_node_or_null(fall_recovery_area_path)
	if fall_area_node is Area3D:
		_fall_recovery_area = fall_area_node as Area3D
	else:
		push_error("Southern region preview could not find FallRecoveryArea.")
		valid = false

	_current_boundary = _resolve_mesh_instance(current_boundary_path, "CurrentChunkBoundary")
	_loaded_boundaries = _resolve_mesh_instance(loaded_boundaries_path, "LoadedChunkBoundaries")
	_region_guides = _resolve_mesh_instance(region_guides_path, "RegionGuides")
	if _current_boundary == null or _loaded_boundaries == null or _region_guides == null:
		valid = false

	var label_node: Node = get_node_or_null(debug_label_path)
	if label_node is Label:
		_debug_label = label_node as Label
	else:
		push_error("Southern region preview could not find DebugLabel.")
		valid = false

	var timer_node: Node = get_node_or_null(debug_timer_path)
	if timer_node is Timer:
		_debug_timer = timer_node as Timer
	else:
		push_error("Southern region preview could not find DebugUpdateTimer.")
		valid = false

	if _region != null:
		_terrain_streamer = _region.get_terrain_streamer()
	if _terrain_streamer == null:
		push_error("Southern region preview could not access TerrainStreamer.")
		valid = false
	return valid


func _resolve_mesh_instance(path: NodePath, display_name: String) -> MeshInstance3D:
	var node: Node = get_node_or_null(path)
	if node is MeshInstance3D:
		return node as MeshInstance3D
	push_error("Southern region preview could not find %s." % display_name)
	return null


func _vector3_from_array(value: Variant) -> Vector3:
	if not value is Array:
		return Vector3.ZERO
	var values: Array = value
	if values.size() != 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _format_grid(coordinate: Vector2i) -> String:
	return "(%+d, %+d)" % [coordinate.x, coordinate.y]
