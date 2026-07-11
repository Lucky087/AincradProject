extends Node3D

## F6-only placement and collision preview for the Floor 1 north-gate assembly.
##
## This wrapper instances the permanent southern region and existing player.
## It reuses the architecture assembly integrated inside that region, preventing
## duplicate render or collision instances. It never changes F5 startup,
## player progression, checkpoints, inventory, quests, equipment, gold, or saves.

const PLAYER_GROUP: StringName = &"players"
const WORLD_COLLISION_MASK: int = 1
const MAX_SAFE_PLACEMENT_ATTEMPTS: int = 300
const GATE_CENTRE_WORLD: Vector3 = Vector3(0.0, 9.0, 3835.0)
const OUTSIDE_GATE_OFFSET: Vector3 = Vector3(0.0, 0.0, -64.0)
const INSIDE_GATE_OFFSET: Vector3 = Vector3(0.0, 0.0, 28.0)
const WEST_ENDPOINT_OFFSET: Vector3 = Vector3(-194.0, 0.0, -16.0)
const EAST_ENDPOINT_OFFSET: Vector3 = Vector3(194.0, 0.0, -16.0)

@export_category("Required Nodes")
@export var region_path: NodePath = NodePath("SouthernRegion")
@export var assembly_path: NodePath = NodePath(
	"SouthernRegion/StaticContent/CityGateArchitecture/NorthGateAssembly"
)
@export var player_path: NodePath = NodePath("Player")
@export var fall_recovery_area_path: NodePath = NodePath("PreviewSafety/FallRecoveryArea")
@export var current_boundary_path: NodePath = NodePath("DebugVisualization/CurrentChunkBoundary")
@export var loaded_boundaries_path: NodePath = NodePath("DebugVisualization/LoadedChunkBoundaries")
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

var _region: Floor001SouthernRegion = null
var _assembly: Floor001NorthGateAssembly = null
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
var _safe_recovery_position: Vector3 = GATE_CENTRE_WORLD + Vector3.UP * 2.0
var _boundaries_visible: bool = true
var _last_boundary_signature: String = ""
var _current_test_location: String = "Preparing north-gate preview"
var _last_message: String = "Resolving preview scenes"
var _setup_is_valid: bool = false
var _road_surface_terrain_report: PackedStringArray = []


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
	_assembly.assembly_warning.connect(_on_assembly_warning)
	_assembly.assembly_failed.connect(_on_assembly_failed)
	_region.assign_streaming_target(_player)

	if _region.is_configuration_ready() and _terrain_streamer.is_manifest_ready():
		call_deferred("_teleport_outside_gate")
	else:
		_last_message = "Southern region configuration or terrain manifest is not ready"
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
			_teleport_outside_gate()
		KEY_F2:
			_teleport_inside_gate()
		KEY_F3:
			_teleport_west_endpoint()
		KEY_F4:
			_teleport_east_endpoint()
		KEY_G:
			_assembly.set_placement_markers_visible(not _assembly.are_placement_markers_visible())
			_last_message = (
				"Architecture placement markers shown"
				if _assembly.are_placement_markers_visible()
				else "Architecture placement markers hidden"
			)
		KEY_C:
			_assembly.set_collision_debug_visible(not _assembly.is_collision_debug_visible())
			_last_message = (
				"Collision-source GLB visuals shown"
				if _assembly.is_collision_debug_visible()
				else "Collision-source GLB visuals hidden"
			)
		KEY_B:
			_boundaries_visible = not _boundaries_visible
			_refresh_boundary_visualization(true)
			_last_message = (
				"Terrain chunk boundaries shown"
				if _boundaries_visible
				else "Terrain chunk boundaries hidden"
			)
		_:
			return
	get_viewport().set_input_as_handled()
	_update_debug_display()


func _teleport_outside_gate() -> void:
	_begin_safe_placement(
		"Outside north gate", GATE_CENTRE_WORLD + OUTSIDE_GATE_OFFSET, GATE_CENTRE_WORLD
	)


func _teleport_inside_gate() -> void:
	_begin_safe_placement(
		"Inside city side of gate", GATE_CENTRE_WORLD + INSIDE_GATE_OFFSET, GATE_CENTRE_WORLD
	)


func _teleport_west_endpoint() -> void:
	_begin_safe_placement(
		"West wall endpoint",
		GATE_CENTRE_WORLD + WEST_ENDPOINT_OFFSET,
		GATE_CENTRE_WORLD + Vector3(-190.0, 0.0, 0.0)
	)


func _teleport_east_endpoint() -> void:
	_begin_safe_placement(
		"East wall endpoint",
		GATE_CENTRE_WORLD + EAST_ENDPOINT_OFFSET,
		GATE_CENTRE_WORLD + Vector3(190.0, 0.0, 0.0)
	)


func _begin_safe_placement(
	location_name: String, target_world_position: Vector3, look_at_world_position: Vector3
) -> void:
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
		"look_at": look_at_world_position,
	}
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_current_test_location = location_name
	_last_message = "Loading terrain and collision for %s" % location_name
	_terrain_streamer.force_streaming_update()
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _finish_safe_placement(target_position: Vector3, raycast_confirmed: bool) -> void:
	var look_at_position: Vector3 = _pending_safe_placement.get("look_at", GATE_CENTRE_WORLD)
	_player.global_position = target_position
	_player.velocity = Vector3.ZERO
	var flat_look_at: Vector3 = Vector3(
		look_at_position.x, _player.global_position.y, look_at_position.z
	)
	if _player.global_position.distance_to(flat_look_at) > 0.1:
		_player.look_at(flat_look_at, Vector3.UP)
	_safe_recovery_position = target_position
	_pending_safe_placement.clear()
	_safe_placement_attempts = 0
	_collision_ready_physics_frames = 0
	_set_player_simulation_enabled(true)
	_last_message = (
		"Player placed on exported terrain or architecture collision"
		if raycast_confirmed
		else "Player placed at the marker-derived safe fallback"
	)
	_terrain_streamer.force_streaming_update()
	_refresh_boundary_visualization(true)
	_update_road_surface_terrain_diagnostics()
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
	_last_message = "Preview-only fall recovery returned the same player outside the gate"
	_teleport_outside_gate()


func _on_current_chunk_changed(
	_grid_coordinate: Vector2i, _chunk_id: StringName, _coordinate_exists: bool
) -> void:
	_refresh_boundary_visualization(true)
	_update_debug_display()


func _on_streaming_state_changed() -> void:
	_refresh_boundary_visualization(false)
	_update_road_surface_terrain_diagnostics()


func _on_streaming_warning(message: String) -> void:
	_last_message = message
	_update_debug_display()


func _on_assembly_warning(message: String) -> void:
	_last_message = message
	_update_debug_display()


func _on_assembly_failed(message: String) -> void:
	_last_message = "Architecture assembly failed safely: %s" % message
	_update_debug_display()


func _on_debug_update_timer_timeout() -> void:
	_refresh_boundary_visualization(false)
	_update_road_surface_terrain_diagnostics()
	_update_debug_display()


func _create_debug_materials() -> void:
	_current_boundary_material = _make_line_material(Color(0.2, 0.95, 1.0, 1.0))
	_loaded_boundary_material = _make_line_material(Color(1.0, 0.72, 0.18, 0.65))


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


func _collect_static_body_rids(node: Node, output: Array[RID]) -> void:
	if node is StaticBody3D:
		output.append((node as StaticBody3D).get_rid())
	for child: Node in node.get_children():
		_collect_static_body_rids(child, output)


func _update_road_surface_terrain_diagnostics() -> void:
	_road_surface_terrain_report.clear()
	if (
		_assembly == null
		or _terrain_streamer == null
		or _player == null
		or not _assembly.is_assembly_ready()
		or not _terrain_streamer.is_manifest_ready()
	):
		return
	var road_debug: Dictionary = (
		_assembly.get_meta("road_collision_debug_snapshot", {}) as Dictionary
	)
	var samples_value: Variant = road_debug.get("flat_road_surface_samples", [])
	if not samples_value is Array:
		return
	var samples: Array = samples_value
	var excluded_rids: Array[RID] = [_player.get_rid()]
	_collect_static_body_rids(_assembly, excluded_rids)
	for sample_value: Variant in samples:
		if not sample_value is Dictionary:
			continue
		var sample: Dictionary = sample_value
		var world_position_value: Variant = sample.get("world_position", Vector3.ZERO)
		if not world_position_value is Vector3:
			continue
		var road_surface_position: Vector3 = world_position_value as Vector3
		var grid: Vector2i = _terrain_streamer.get_grid_coordinate(road_surface_position)
		if not _terrain_streamer.is_collision_active_at(grid):
			_road_surface_terrain_report.append(
				"%s | terrain collision pending" % String(sample.get("placement_id", ""))
			)
			continue
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			road_surface_position + Vector3.UP * 20.0,
			road_surface_position + Vector3.DOWN * 80.0,
			WORLD_COLLISION_MASK
		)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.exclude = excluded_rids
		var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			_road_surface_terrain_report.append(
				"%s | no terrain hit" % String(sample.get("placement_id", ""))
			)
			continue
		var terrain_y: float = (hit.get("position", road_surface_position) as Vector3).y
		var surface_y: float = float(sample.get("surface_y", road_surface_position.y))
		var report_line: String = (
			"%s | road surface %.3f m | terrain %.3f m | difference %+0.3f m"
			% [
				String(sample.get("placement_id", "")),
				surface_y,
				terrain_y,
				surface_y - terrain_y,
			]
		)
		_road_surface_terrain_report.append(report_line)


func _update_debug_display() -> void:
	if _debug_label == null:
		return
	if _assembly == null or _terrain_streamer == null or _player == null:
		_debug_label.text = "Floor 1 North-Gate Preview\nRequired nodes unavailable"
		return
	var alignment: Dictionary = _assembly.get_alignment_snapshot()
	var terrain_snapshot: Dictionary = _terrain_streamer.get_debug_snapshot()
	var player_position: Vector3 = _player.global_position
	var current_grid: Vector2i = terrain_snapshot.get("current_grid", Vector2i.ZERO)
	var current_chunk: String = String(terrain_snapshot.get("current_chunk_id", &""))
	if current_chunk.is_empty():
		current_chunk = "<outside southern manifest>"
	var inside_passage: bool = _assembly.is_position_inside_gate_passage(player_position)
	var road_debug: Dictionary = (
		_assembly.get_meta("road_collision_debug_snapshot", {}) as Dictionary
	)
	var road_transform_report: PackedStringArray = road_debug.get(
		"road_collision_transform_report", PackedStringArray()
	)
	var road_transform_text: String = (
		"<none>" if road_transform_report.is_empty() else "\n".join(road_transform_report)
	)
	var road_surface_text: String = (
		"<terrain samples pending>"
		if _road_surface_terrain_report.is_empty()
		else "\n".join(_road_surface_terrain_report)
	)
	_debug_label.text = (
		"Floor 1 Starting City North-Gate Preview\n"
		+ "Manifest status: %s\n" % _assembly.get_manifest_status()
		+ (
			"Render assets: %d / 16 | placed instances: %d\n"
			% [_assembly.get_render_asset_count(), _assembly.get_render_instance_count()]
		)
		+ (
			"Collision assets: %d / 16 | bodies: %d | shapes: %d\n"
			% [
				_assembly.get_collision_asset_count(),
				_assembly.get_collision_body_count(),
				_assembly.get_collision_shape_count(),
			]
		)
		+ "Failed assets: %d\n" % _assembly.get_failed_asset_count()
		+ (
			"Road physics: flat=%s | edging=%s | bodies=%d | shapes=%d | disabled=%d\n"
			% [
				"ON" if bool(road_debug.get("flat_road_collision_enabled", false)) else "OFF",
				"ON" if bool(road_debug.get("road_edging_collision_enabled", false)) else "OFF",
				int(road_debug.get("road_collision_body_count", 0)),
				int(road_debug.get("road_collision_shape_count", 0)),
				int(road_debug.get("disabled_road_collision_placement_count", 0)),
			]
		)
		+ (
			"Duplicate collision placements: %d\n"
			% int(road_debug.get("duplicate_collision_count", 0))
		)
		+ "Road collision transforms:\n%s\n" % road_transform_text
		+ "Road surface versus terrain:\n%s\n" % road_surface_text
		+ (
			"Alignment error m — gate %.4f | west %.4f | east %.4f | road %.4f\n"
			% [
				float(alignment.get("gate_centre_error_m", -1.0)),
				float(alignment.get("west_endpoint_error_m", -1.0)),
				float(alignment.get("east_endpoint_error_m", -1.0)),
				float(alignment.get("road_centreline_error_m", -1.0)),
			]
		)
		+ (
			"Gate forward -Z: %s | angle error: %.3f°\n"
			% [
				"YES" if bool(alignment.get("forward_matches_negative_z", false)) else "NO",
				float(alignment.get("forward_angle_error_degrees", -1.0)),
			]
		)
		+ (
			"Passage: %.1f m wide × %.1f m high | Player inside: %s\n"
			% [
				_assembly.get_passage_width_metres(),
				_assembly.get_passage_height_metres(),
				"YES" if inside_passage else "NO",
			]
		)
		+ "Player: (%.1f, %.1f, %.1f)\n" % [player_position.x, player_position.y, player_position.z]
		+ "Current chunk: %s %s\n" % [_format_grid(current_grid), current_chunk]
		+ (
			"Terrain loaded: %d | LOD0 %d | LOD1 %d | collision %d\n"
			% [
				int(terrain_snapshot.get("loaded_chunk_count", 0)),
				int(terrain_snapshot.get("lod0_chunk_count", 0)),
				int(terrain_snapshot.get("lod1_chunk_count", 0)),
				int(terrain_snapshot.get("collision_chunk_count", 0)),
			]
		)
		+ "Test location: %s\n" % _current_test_location
		+ "F1 Outside | F2 Inside | F3 West | F4 East\n"
		+ "G Markers | C Collision visuals | B Chunk boundaries\n"
		+ "C colours: red=active physics source | amber=visual-only disabled source\n"
		+ "Last message: %s" % _last_message
	)


func _resolve_required_nodes() -> bool:
	var valid: bool = true
	var region_node: Node = get_node_or_null(region_path)
	if region_node is Floor001SouthernRegion:
		_region = region_node as Floor001SouthernRegion
	else:
		push_error("North-gate preview could not find the permanent southern region.")
		valid = false

	var assembly_node: Node = get_node_or_null(assembly_path)
	if assembly_node is Floor001NorthGateAssembly:
		_assembly = assembly_node as Floor001NorthGateAssembly
	else:
		push_error("North-gate preview could not find the reusable architecture assembly.")
		valid = false

	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		push_error("North-gate preview could not find the existing player scene.")
		valid = false

	var fall_area_node: Node = get_node_or_null(fall_recovery_area_path)
	if fall_area_node is Area3D:
		_fall_recovery_area = fall_area_node as Area3D
	else:
		push_error("North-gate preview could not find FallRecoveryArea.")
		valid = false

	_current_boundary = _resolve_mesh_instance(current_boundary_path, "CurrentChunkBoundary")
	_loaded_boundaries = _resolve_mesh_instance(loaded_boundaries_path, "LoadedChunkBoundaries")
	if _current_boundary == null or _loaded_boundaries == null:
		valid = false

	var label_node: Node = get_node_or_null(debug_label_path)
	if label_node is Label:
		_debug_label = label_node as Label
	else:
		push_error("North-gate preview could not find DebugLabel.")
		valid = false

	var timer_node: Node = get_node_or_null(debug_timer_path)
	if timer_node is Timer:
		_debug_timer = timer_node as Timer
	else:
		push_error("North-gate preview could not find DebugUpdateTimer.")
		valid = false

	if _region != null:
		_terrain_streamer = _region.get_terrain_streamer()
	if _terrain_streamer == null:
		push_error("North-gate preview could not access TerrainStreamer.")
		valid = false
	return valid


func _resolve_mesh_instance(path: NodePath, display_name: String) -> MeshInstance3D:
	var node: Node = get_node_or_null(path)
	if node is MeshInstance3D:
		return node as MeshInstance3D
	push_error("North-gate preview could not find %s." % display_name)
	return null


func _format_grid(coordinate: Vector2i) -> String:
	return "(%+d, %+d)" % [coordinate.x, coordinate.y]
