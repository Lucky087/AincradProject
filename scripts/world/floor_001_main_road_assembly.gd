class_name Floor001MainRoadAssembly
extends Node3D

# gdlint: disable=max-returns
# gdlint: disable=max-public-methods
# gdlint: disable=max-file-lines
# gdlint: disable=max-line-length

## Data-driven greybox assembly for the first permanent northbound Floor 1 road.
##
## The route uses only the render GLBs from the accepted Milestone 15A kit.
## Flat road collision is intentionally never created: streamed terrain remains
## the authoritative walking surface, preserving the accepted 15B.1 fix.

signal road_assembly_ready
signal road_assembly_failed(message: String)
signal road_assembly_warning(message: String)
signal road_visibility_changed

const DEFAULT_ROAD_DATA_PATH: String = "res://AincradProject/data/floors/floor_001_main_road.json"
const EXPECTED_ROAD_ID: String = "road_floor_001_starting_city_northbound"
const EXPECTED_FLOOR_ID: String = "floor_001"
const EXPECTED_REGION_ID: String = "region_floor_001_southern"
const EXPECTED_ARCHITECTURE_STATUS: String = "complete_blender_exports_generated"
const GENERATED_META_KEY: StringName = &"floor_001_main_road_generated"
const LOCAL_FORWARD: Vector3 = Vector3(0.0, 0.0, -1.0)
const NORTH_DIRECTION: Vector3 = Vector3(0.0, 0.0, -1.0)
const MINIMUM_FINAL_PIECE_LENGTH_M: float = 4.0
const MAXIMUM_PLACEMENT_COUNT: int = 128
const POSITION_TOLERANCE_METRES: float = 0.05

@export_category("Road Data")
@export_file("*.json") var road_data_path: String = DEFAULT_ROAD_DATA_PATH
@export var build_on_ready: bool = true

@export_category("Visual Placement")
@export_range(0.0, 0.25, 0.01) var visual_offset_metres: float = 0.05
@export_range(2.0, 20.0, 0.5) var curve_selection_threshold_degrees: float = 9.0
@export var edging_visible_by_default: bool = false

@export_category("Debug")
@export var spline_debug_visible_by_default: bool = false
@export var placement_markers_visible_by_default: bool = false

@export_category("Required Nodes")
@export var road_path_node_path: NodePath = NodePath("RoadPath")
@export var gate_approach_root_path: NodePath = NodePath("RoadRender/GateApproach")
@export var grasslands_root_path: NodePath = NodePath("RoadRender/BeginnerGrasslands")
@export var northern_root_path: NodePath = NodePath("RoadRender/NorthernContinuation")
@export var road_edging_root_path: NodePath = NodePath("RoadEdging")
@export var placement_markers_root_path: NodePath = NodePath("PlacementMarkers")
@export var spline_visual_path: NodePath = NodePath("Debug/SplineVisualization")
@export var placement_visual_path: NodePath = NodePath("Debug/PlacementVisualization")

var _road_data: Dictionary = {}
var _architecture_manifest: Dictionary = {}
var _pieces_by_id: Dictionary = {}
var _render_resources: Dictionary = {}
var _control_points: Array[Dictionary] = []
var _control_point_offsets: Dictionary = {}
var _placement_records: Array[Dictionary] = []
var _failed_assets: PackedStringArray = []
var _last_error: String = ""
var _road_ready: bool = false

var _road_path: Path3D = null
var _gate_approach_root: Node3D = null
var _grasslands_root: Node3D = null
var _northern_root: Node3D = null
var _road_edging_root: Node3D = null
var _placement_markers_root: Node3D = null
var _spline_visual: MeshInstance3D = null
var _placement_visual: MeshInstance3D = null

var _road_id: StringName = &""
var _path_length_metres: float = 0.0
var _straight_count: int = 0
var _left_curve_count: int = 0
var _right_curve_count: int = 0
var _edging_pair_count: int = 0
var _spline_debug_visible: bool = false
var _placement_markers_visible: bool = false
var _edging_visible: bool = false
var _debug_spline_material: StandardMaterial3D = null
var _debug_marker_material: StandardMaterial3D = null


func _ready() -> void:
	if not _resolve_required_nodes():
		_fail("Required main-road assembly nodes are missing.")
		return
	_prepare_debug_materials()
	_spline_debug_visible = spline_debug_visible_by_default
	_placement_markers_visible = placement_markers_visible_by_default
	_edging_visible = edging_visible_by_default
	if build_on_ready:
		rebuild_from_data()


func rebuild_from_data() -> bool:
	_reset_runtime_state()
	_road_data = _load_json_dictionary(road_data_path)
	if _road_data.is_empty():
		return _fail("Road data could not be loaded: %s" % road_data_path)
	if not _validate_road_data():
		return false
	if not _load_architecture_manifest_and_assets():
		return false
	if not _build_curve_from_data():
		return false
	_build_modular_route()
	if _placement_records.is_empty():
		return _fail("No road placements were generated.")
	_build_debug_visualization()
	_apply_debug_visibility()
	_road_ready = _failed_assets.is_empty()
	if not _road_ready:
		return _fail("Road assembly completed with failed assets: %s" % ", ".join(_failed_assets))
	print(
		(
			(
				"Floor001MainRoadAssembly ready: %d placements (%d straight, %d left, %d right), "
				+ "%.2f m path, flat-road collision disabled."
			)
			% [
				_placement_records.size(),
				_straight_count,
				_left_curve_count,
				_right_curve_count,
				_path_length_metres,
			]
		)
	)
	road_assembly_ready.emit()
	return true


func is_assembly_ready() -> bool:
	return _road_ready


func get_road_id() -> StringName:
	return _road_id


func get_failed_asset_count() -> int:
	return _failed_assets.size()


func get_collision_policy_name() -> String:
	var collision_value: Variant = _road_data.get("collision_policy", {})
	var collision_policy: Dictionary = (
		collision_value as Dictionary if collision_value is Dictionary else {}
	)
	return String(collision_policy.get("policy_id", "unknown"))


func get_control_point_world_position(control_point_id: StringName) -> Vector3:
	for point: Dictionary in _control_points:
		if StringName(point.get("control_point_id", "")) == control_point_id:
			return _road_path.to_global(_vector3_from_array(point.get("position", [])))
	return Vector3.ZERO


func get_distance_along_road(world_position: Vector3) -> float:
	if not _road_ready or _road_path.curve == null:
		return 0.0
	return _road_path.curve.get_closest_offset(_road_path.to_local(world_position))


func get_nearest_placement_id(world_position: Vector3) -> StringName:
	if _placement_records.is_empty():
		return &""
	var distance_along: float = get_distance_along_road(world_position)
	var best_id: StringName = &""
	var best_difference: float = INF
	for placement: Dictionary in _placement_records:
		var midpoint: float = (
			(
				float(placement.get("start_distance_m", 0.0))
				+ float(placement.get("end_distance_m", 0.0))
			)
			* 0.5
		)
		var difference: float = absf(midpoint - distance_along)
		if difference < best_difference:
			best_difference = difference
			best_id = StringName(placement.get("placement_id", ""))
	return best_id


func set_spline_debug_visible(visible: bool) -> void:
	_spline_debug_visible = visible
	_apply_debug_visibility()
	road_visibility_changed.emit()


func is_spline_debug_visible() -> bool:
	return _spline_debug_visible


func set_placement_markers_visible(visible: bool) -> void:
	_placement_markers_visible = visible
	_apply_debug_visibility()
	road_visibility_changed.emit()


func are_placement_markers_visible() -> bool:
	return _placement_markers_visible


func set_edging_visible(visible: bool) -> void:
	_edging_visible = visible
	_apply_debug_visibility()
	road_visibility_changed.emit()


func is_edging_visible() -> bool:
	return _edging_visible


func get_debug_snapshot() -> Dictionary:
	return {
		"road_ready": _road_ready,
		"road_id": String(_road_id),
		"control_point_count": _control_points.size(),
		"placement_count": _placement_records.size(),
		"straight_piece_count": _straight_count,
		"left_curve_count": _left_curve_count,
		"right_curve_count": _right_curve_count,
		"edging_pair_count": _edging_pair_count,
		"path_length_m": _path_length_metres,
		"collision_policy": get_collision_policy_name(),
		"flat_road_collision_created": false,
		"failed_asset_count": _failed_assets.size(),
		"spline_debug_visible": _spline_debug_visible,
		"placement_markers_visible": _placement_markers_visible,
		"edging_visible": _edging_visible,
		"last_error": _last_error,
	}


func _resolve_required_nodes() -> bool:
	_road_path = get_node_or_null(road_path_node_path) as Path3D
	_gate_approach_root = get_node_or_null(gate_approach_root_path) as Node3D
	_grasslands_root = get_node_or_null(grasslands_root_path) as Node3D
	_northern_root = get_node_or_null(northern_root_path) as Node3D
	_road_edging_root = get_node_or_null(road_edging_root_path) as Node3D
	_placement_markers_root = get_node_or_null(placement_markers_root_path) as Node3D
	_spline_visual = get_node_or_null(spline_visual_path) as MeshInstance3D
	_placement_visual = get_node_or_null(placement_visual_path) as MeshInstance3D
	return (
		_road_path != null
		and _gate_approach_root != null
		and _grasslands_root != null
		and _northern_root != null
		and _road_edging_root != null
		and _placement_markers_root != null
		and _spline_visual != null
		and _placement_visual != null
	)


func _reset_runtime_state() -> void:
	_clear_generated_children(_gate_approach_root)
	_clear_generated_children(_grasslands_root)
	_clear_generated_children(_northern_root)
	_clear_generated_children(_road_edging_root)
	_clear_generated_children(_placement_markers_root)
	_road_path.curve = null
	_spline_visual.mesh = null
	_placement_visual.mesh = null
	_road_data.clear()
	_architecture_manifest.clear()
	_pieces_by_id.clear()
	_render_resources.clear()
	_control_points.clear()
	_control_point_offsets.clear()
	_placement_records.clear()
	_failed_assets.clear()
	_last_error = ""
	_road_ready = false
	_road_id = &""
	_path_length_metres = 0.0
	_straight_count = 0
	_left_curve_count = 0
	_right_curve_count = 0
	_edging_pair_count = 0


func _clear_generated_children(parent: Node) -> void:
	if parent == null:
		return
	for child: Node in parent.get_children():
		if bool(child.get_meta(GENERATED_META_KEY, false)):
			parent.remove_child(child)
			child.queue_free()


func _validate_road_data() -> bool:
	if String(_road_data.get("road_id", "")) != EXPECTED_ROAD_ID:
		return _fail("Unexpected road_id in road JSON.")
	if String(_road_data.get("floor_id", "")) != EXPECTED_FLOOR_ID:
		return _fail("Unexpected floor_id in road JSON.")
	if String(_road_data.get("region_id", "")) != EXPECTED_REGION_ID:
		return _fail("Unexpected region_id in road JSON.")
	if not is_equal_approx(float(_road_data.get("road_width_m", 0.0)), 14.0):
		return _fail("The main road must retain the 14 metre gate-compatible width.")

	var points_value: Variant = _road_data.get("control_points", [])
	if not points_value is Array:
		return _fail("control_points must be an array.")
	var points_array: Array = points_value as Array
	if points_array.size() != 5:
		return _fail("Milestone 16A requires exactly five production-approved control points.")

	var expected_points: Dictionary = {
		"road_gate": Vector3(0.0, 9.0, 3835.0),
		"road_01": Vector3(12.0, 8.3, 3665.0),
		"road_02": Vector3(-28.0, 8.8, 3480.0),
		"road_03": Vector3(34.0, 10.2, 3280.0),
		"road_north_continuation": Vector3(20.0, 14.0, 2816.0),
	}
	var previous_z: float = INF
	var seen_ids: Dictionary = {}
	for point_value: Variant in points_array:
		if not point_value is Dictionary:
			return _fail("Every control point must be an object.")
		var point: Dictionary = point_value as Dictionary
		var point_id: String = String(point.get("control_point_id", ""))
		if not expected_points.has(point_id):
			return _fail("Unexpected control point ID: %s" % point_id)
		if seen_ids.has(point_id):
			return _fail("Duplicate control point ID: %s" % point_id)
		seen_ids[point_id] = true
		var position: Vector3 = _vector3_from_array(point.get("position", []))
		if position.distance_to(expected_points[point_id]) > POSITION_TOLERANCE_METRES:
			return _fail("Control point %s does not match approved production data." % point_id)
		if position.z >= previous_z:
			return _fail("Control points must preserve northward negative-Z progression.")
		previous_z = position.z
		_control_points.append(point.duplicate(true))

	if String(_road_data.get("start_marker_id", "")) != "road_gate":
		return _fail("Road start marker must be road_gate.")
	if String(_road_data.get("end_marker_id", "")) != "road_north_continuation":
		return _fail("Road end marker must be road_north_continuation.")
	_road_id = StringName(_road_data.get("road_id", ""))
	return true


func _load_architecture_manifest_and_assets() -> bool:
	var manifest_path: String = String(_road_data.get("architecture_manifest_path", ""))
	_architecture_manifest = _load_json_dictionary(manifest_path)
	if _architecture_manifest.is_empty():
		return _fail("Architecture manifest could not be loaded: %s" % manifest_path)
	if String(_architecture_manifest.get("generation_status", "")) != EXPECTED_ARCHITECTURE_STATUS:
		return _fail("Architecture manifest does not confirm completed Blender exports.")

	var pieces_value: Variant = _architecture_manifest.get("pieces", [])
	if not pieces_value is Array:
		return _fail("Architecture manifest pieces field is invalid.")
	for piece_value: Variant in pieces_value as Array:
		if piece_value is Dictionary:
			var piece: Dictionary = piece_value as Dictionary
			_pieces_by_id[String(piece.get("piece_id", ""))] = piece

	var asset_ids_value: Variant = _road_data.get("road_asset_ids", {})
	if not asset_ids_value is Dictionary:
		return _fail("road_asset_ids is missing from road data.")
	var asset_ids: Dictionary = asset_ids_value as Dictionary
	for role: String in ["straight", "curve_left", "curve_right", "intersection", "edging"]:
		var piece_id: String = String(asset_ids.get(role, ""))
		if piece_id.is_empty() or not _pieces_by_id.has(piece_id):
			return _fail("Road asset role %s references an unknown manifest piece." % role)
		var piece: Dictionary = _pieces_by_id[piece_id]
		var render_path: String = String(piece.get("render_path", ""))
		if not ResourceLoader.exists(render_path):
			_failed_assets.append(render_path)
			continue
		var loaded_resource: Resource = ResourceLoader.load(render_path)
		if not loaded_resource is PackedScene:
			_failed_assets.append(render_path)
			continue
		_render_resources[piece_id] = loaded_resource as PackedScene
	if not _failed_assets.is_empty():
		return _fail("One or more required road render assets failed to load.")
	return true


func _build_curve_from_data() -> bool:
	var curve: Curve3D = Curve3D.new()
	var spline_value: Variant = _road_data.get("spline_policy", {})
	var spline_policy: Dictionary = spline_value as Dictionary if spline_value is Dictionary else {}
	curve.bake_interval = float(spline_policy.get("bake_interval_m", 2.0))
	for point: Dictionary in _control_points:
		var world_position: Vector3 = _vector3_from_array(point.get("position", []))
		var local_position: Vector3 = _road_path.to_local(world_position)
		var in_handle: Vector3 = _vector3_from_array(point.get("curve_in_handle", []))
		var out_handle: Vector3 = _vector3_from_array(point.get("curve_out_handle", []))
		curve.add_point(local_position, in_handle, out_handle)
	_road_path.curve = curve
	_path_length_metres = curve.get_baked_length()
	if _path_length_metres < 900.0:
		return _fail("Generated road path is unexpectedly short.")
	if (
		curve.sample_baked(0.0, true).distance_to(
			_vector3_from_array(_control_points[0].get("position", []))
		)
		> POSITION_TOLERANCE_METRES
	):
		return _fail("Road curve does not begin at MainRoadStart.")
	if (
		curve.sample_baked(_path_length_metres, true).distance_to(
			_vector3_from_array(_control_points[-1].get("position", []))
		)
		> POSITION_TOLERANCE_METRES
	):
		return _fail("Road curve does not end at MainRoadNorthernExit.")
	for point: Dictionary in _control_points:
		var point_id: String = String(point.get("control_point_id", ""))
		var local_position: Vector3 = _vector3_from_array(point.get("position", []))
		_control_point_offsets[point_id] = curve.get_closest_offset(local_position)
	return true


func _build_modular_route() -> void:
	var asset_ids: Dictionary = _road_data.get("road_asset_ids", {})
	var geometry: Dictionary = _road_data.get("asset_geometry", {})
	var transition: Dictionary = _road_data.get("gate_transition", {})
	var edging_policy: Dictionary = _road_data.get("edging_policy", {})
	var section_policy: Dictionary = _road_data.get("section_policy", {})
	var straight_id: String = String(asset_ids.get("straight", ""))
	var left_id: String = String(asset_ids.get("curve_left", ""))
	var right_id: String = String(asset_ids.get("curve_right", ""))
	var edging_id: String = String(asset_ids.get("edging", ""))
	var straight_length: float = float(geometry.get("straight_piece_length_m", 24.0))
	var curve_chord_length: float = float(geometry.get("curve_chord_length_m", 15.5291427062))
	var left_chord: Vector3 = _vector3_from_array(geometry.get("curve_left_local_chord_m", []))
	var right_chord: Vector3 = _vector3_from_array(geometry.get("curve_right_local_chord_m", []))
	var current_distance: float = float(transition.get("new_road_placement_start_distance_m", 80.0))
	var northern_start: float = float(
		section_policy.get("northern_continuation_starts_at_distance_m", 760.0)
	)
	var gate_approach_end: float = float(_control_point_offsets.get("road_01", 180.0)) + 24.0
	var edge_interval: int = maxi(
		1, int(edging_policy.get("placement_interval_straight_segments", 3))
	)
	var placement_index: int = 0
	var straight_index: int = 0

	while current_distance < _path_length_metres - 0.05:
		if placement_index >= MAXIMUM_PLACEMENT_COUNT:
			_warn("Placement safety limit reached before the route end.")
			break
		var start_position: Vector3 = _road_path.curve.sample_baked(current_distance, true)
		var remaining_horizontal: float = _horizontal_distance(
			start_position, _road_path.curve.sample_baked(_path_length_metres, true)
		)
		if remaining_horizontal < MINIMUM_FINAL_PIECE_LENGTH_M:
			break

		var straight_end: float = _find_distance_for_horizontal_chord(
			current_distance, straight_length
		)
		var start_heading: float = _heading_at_distance(current_distance + 1.0)
		var end_heading: float = _heading_at_distance(
			maxf(current_distance + 1.0, straight_end - 1.0)
		)
		var heading_change: float = _signed_angle_difference_degrees(start_heading, end_heading)
		var use_curve: bool = (
			absf(heading_change) >= curve_selection_threshold_degrees
			and remaining_horizontal >= curve_chord_length + 1.0
			and straight_end < _path_length_metres - 0.1
		)

		var piece_id: String = straight_id
		var end_distance: float = straight_end
		var local_chord: Vector3 = Vector3(0.0, 0.0, -straight_length)
		var placement_kind: String = "straight"
		if use_curve:
			end_distance = _find_distance_for_horizontal_chord(current_distance, curve_chord_length)
			if heading_change < 0.0:
				piece_id = left_id
				local_chord = left_chord
				placement_kind = "curve_left"
			else:
				piece_id = right_id
				local_chord = right_chord
				placement_kind = "curve_right"

		var end_position: Vector3 = _road_path.curve.sample_baked(end_distance, true)
		var chord_length: float = _horizontal_distance(start_position, end_position)
		if chord_length < MINIMUM_FINAL_PIECE_LENGTH_M:
			break
		if end_distance >= _path_length_metres - 0.05 and placement_kind != "straight":
			piece_id = straight_id
			placement_kind = "straight"
			local_chord = Vector3(0.0, 0.0, -straight_length)

		placement_index += 1
		var placement_id: String = "%s_segment_%03d" % [EXPECTED_ROAD_ID, placement_index]
		var category_root: Node3D = _grasslands_root
		var section_name: String = "BeginnerGrasslands"
		var midpoint_distance: float = (current_distance + end_distance) * 0.5
		if midpoint_distance <= gate_approach_end:
			category_root = _gate_approach_root
			section_name = "GateApproach"
		elif midpoint_distance >= northern_start:
			category_root = _northern_root
			section_name = "NorthernContinuation"

		var visual_start_position: Vector3 = _visual_position_at_distance(current_distance)
		var visual_end_position: Vector3 = _visual_position_at_distance(end_distance)
		var placement_root: Node3D = _create_placement_root(
			placement_id,
			piece_id,
			placement_kind,
			visual_start_position,
			visual_end_position,
			local_chord,
			straight_length,
			category_root
		)
		if placement_root == null:
			current_distance = end_distance
			continue

		if placement_kind == "straight":
			_straight_count += 1
			straight_index += 1
			if straight_index % edge_interval == 0:
				_build_sparse_edging_pair(
					placement_id, placement_root, edging_id, chord_length / straight_length
				)
		elif placement_kind == "curve_left":
			_left_curve_count += 1
		else:
			_right_curve_count += 1

		var record: Dictionary = {
			"placement_id": placement_id,
			"piece_id": piece_id,
			"placement_kind": placement_kind,
			"section": section_name,
			"start_distance_m": current_distance,
			"end_distance_m": end_distance,
			"start_position": start_position,
			"end_position": end_position,
			"visual_start_position": visual_start_position,
			"visual_end_position": visual_end_position,
			"heading_change_degrees": heading_change,
			"collision_created": false,
		}
		_placement_records.append(record)
		_create_placement_marker(record, placement_root.global_transform)
		if end_distance <= current_distance + 0.01:
			_warn("Road placement did not advance; generation stopped safely.")
			break
		current_distance = end_distance


func _create_placement_root(
	placement_id: String,
	piece_id: String,
	placement_kind: String,
	start_position: Vector3,
	end_position: Vector3,
	local_chord: Vector3,
	straight_length: float,
	parent: Node3D
) -> Node3D:
	if not _render_resources.has(piece_id):
		_failed_assets.append(piece_id)
		return null
	var packed_scene: PackedScene = _render_resources[piece_id]
	var instance: Node = packed_scene.instantiate()
	if instance == null:
		_failed_assets.append(piece_id)
		return null
	var root: Node3D = Node3D.new()
	root.name = placement_id
	root.set_meta(GENERATED_META_KEY, true)
	root.set_meta("placement_id", placement_id)
	root.set_meta("piece_id", piece_id)
	root.set_meta("placement_kind", placement_kind)
	root.set_meta("flat_road_collision_created", false)
	parent.add_child(root)

	var world_chord: Vector3 = end_position - start_position
	var horizontal_world_chord: Vector3 = Vector3(world_chord.x, 0.0, world_chord.z)
	if horizontal_world_chord.length_squared() < 0.0001:
		root.queue_free()
		_failed_assets.append(placement_id)
		return null

	if placement_kind == "straight":
		var centre: Vector3 = (start_position + end_position) * 0.5
		root.position = centre
		root.look_at(centre + world_chord, Vector3.UP)
		root.scale = Vector3(1.0, 1.0, world_chord.length() / straight_length)
	else:
		root.position = start_position
		var local_horizontal: Vector3 = Vector3(local_chord.x, 0.0, local_chord.z)
		var curve_yaw: float = local_horizontal.normalized().signed_angle_to(
			horizontal_world_chord.normalized(), Vector3.UP
		)
		root.basis = Basis(Vector3.UP, curve_yaw)

	root.add_child(instance)
	return root


func _build_sparse_edging_pair(
	placement_id: String, road_root: Node3D, edging_id: String, longitudinal_scale: float
) -> void:
	if not _render_resources.has(edging_id):
		return
	var width: float = float(_road_data.get("road_width_m", 14.0))
	var lateral_offset: float = width * 0.5 + 0.4
	for side_record: Dictionary in [
		{"suffix": "west", "x": -lateral_offset},
		{"suffix": "east", "x": lateral_offset},
	]:
		var edge_root: Node3D = Node3D.new()
		edge_root.name = "%s_edge_%s" % [placement_id, String(side_record.get("suffix", ""))]
		edge_root.set_meta(GENERATED_META_KEY, true)
		edge_root.set_meta("visual_only", true)
		_road_edging_root.add_child(edge_root)
		edge_root.global_transform = road_root.global_transform
		edge_root.translate_object_local(Vector3(float(side_record.get("x", 0.0)), 0.0, 0.0))
		edge_root.scale.z = longitudinal_scale
		var edge_scene: PackedScene = _render_resources[edging_id]
		edge_root.add_child(edge_scene.instantiate())
	_edging_pair_count += 1


func _create_placement_marker(record: Dictionary, placement_transform: Transform3D) -> void:
	var marker: Marker3D = Marker3D.new()
	marker.name = "%s_marker" % String(record.get("placement_id", ""))
	marker.set_meta(GENERATED_META_KEY, true)
	marker.set_meta("placement_id", record.get("placement_id", ""))
	marker.set_meta("piece_id", record.get("piece_id", ""))
	marker.transform = (
		_placement_markers_root.global_transform.affine_inverse() * placement_transform
	)
	_placement_markers_root.add_child(marker)


func _visual_position_at_distance(distance_metres: float) -> Vector3:
	var position: Vector3 = _road_path.curve.sample_baked(distance_metres, true)
	var target_y: float = position.y + visual_offset_metres
	var transition_value: Variant = _road_data.get("gate_transition", {})
	var transition: Dictionary = (
		transition_value as Dictionary if transition_value is Dictionary else {}
	)
	var blend_start: float = float(transition.get("new_road_placement_start_distance_m", 80.0))
	var blend_end: float = float(transition.get("height_blend_end_distance_m", blend_start))
	var gate_base_y: float = float(transition.get("existing_gate_road_render_base_y_m", target_y))
	if distance_metres <= blend_end and blend_end > blend_start:
		var blend: float = clampf(
			(distance_metres - blend_start) / (blend_end - blend_start), 0.0, 1.0
		)
		blend = blend * blend * (3.0 - 2.0 * blend)
		position.y = lerpf(gate_base_y, target_y, blend)
	else:
		position.y = target_y
	return position


func _find_distance_for_horizontal_chord(
	start_distance: float, target_chord_length: float
) -> float:
	var start_position: Vector3 = _road_path.curve.sample_baked(start_distance, true)
	var low: float = start_distance
	var high: float = minf(_path_length_metres, start_distance + target_chord_length * 1.7 + 4.0)
	if (
		_horizontal_distance(start_position, _road_path.curve.sample_baked(high, true))
		< target_chord_length
	):
		return _path_length_metres
	for _iteration: int in range(24):
		var middle: float = (low + high) * 0.5
		var middle_position: Vector3 = _road_path.curve.sample_baked(middle, true)
		if _horizontal_distance(start_position, middle_position) < target_chord_length:
			low = middle
		else:
			high = middle
	return (low + high) * 0.5


func _heading_at_distance(distance_metres: float) -> float:
	var sample_distance: float = clampf(distance_metres, 0.0, _path_length_metres)
	var before: Vector3 = _road_path.curve.sample_baked(maxf(0.0, sample_distance - 1.0), true)
	var after: Vector3 = _road_path.curve.sample_baked(
		minf(_path_length_metres, sample_distance + 1.0), true
	)
	var direction: Vector3 = after - before
	return rad_to_deg(atan2(direction.x, -direction.z))


func _signed_angle_difference_degrees(from_degrees: float, to_degrees: float) -> float:
	return wrapf(to_degrees - from_degrees, -180.0, 180.0)


func _horizontal_distance(first: Vector3, second: Vector3) -> float:
	return Vector2(first.x, first.z).distance_to(Vector2(second.x, second.z))


func _build_debug_visualization() -> void:
	var spline_mesh: ImmediateMesh = ImmediateMesh.new()
	spline_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _debug_spline_material)
	var sample_step: float = 8.0
	var distance: float = 0.0
	var previous: Vector3 = _road_path.curve.sample_baked(0.0, true) + Vector3.UP * 0.35
	while distance < _path_length_metres:
		distance = minf(_path_length_metres, distance + sample_step)
		var current: Vector3 = _road_path.curve.sample_baked(distance, true) + Vector3.UP * 0.35
		_add_line(spline_mesh, previous, current)
		previous = current
	for point: Dictionary in _control_points:
		var position: Vector3 = _vector3_from_array(point.get("position", []))
		_add_cross(spline_mesh, position + Vector3.UP * 0.4, 2.0)
	var start_position: Vector3 = _road_path.curve.sample_baked(0.0, true)
	var end_position: Vector3 = _road_path.curve.sample_baked(_path_length_metres, true)
	_add_vertical_marker(spline_mesh, start_position, 5.0)
	_add_vertical_marker(spline_mesh, end_position, 5.0)
	spline_mesh.surface_end()
	_spline_visual.mesh = spline_mesh

	var placement_mesh: ImmediateMesh = ImmediateMesh.new()
	placement_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _debug_marker_material)
	for record: Dictionary in _placement_records:
		var start: Vector3 = record.get("start_position", Vector3.ZERO)
		var end: Vector3 = record.get("end_position", Vector3.ZERO)
		var midpoint: Vector3 = (start + end) * 0.5 + Vector3.UP * 0.55
		_add_cross(placement_mesh, midpoint, 0.9)
		var direction: Vector3 = Vector3(end.x - start.x, 0.0, end.z - start.z).normalized()
		_add_line(placement_mesh, midpoint, midpoint + direction * 3.0)
	placement_mesh.surface_end()
	_placement_visual.mesh = placement_mesh


func _prepare_debug_materials() -> void:
	_debug_spline_material = StandardMaterial3D.new()
	_debug_spline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_spline_material.albedo_color = Color(0.25, 0.9, 1.0, 0.95)
	_debug_spline_material.no_depth_test = true
	_debug_marker_material = StandardMaterial3D.new()
	_debug_marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_marker_material.albedo_color = Color(1.0, 0.75, 0.2, 0.95)
	_debug_marker_material.no_depth_test = true


func _apply_debug_visibility() -> void:
	if _spline_visual != null:
		_spline_visual.visible = _spline_debug_visible
	if _placement_visual != null:
		_placement_visual.visible = _placement_markers_visible
	if _road_edging_root != null:
		_road_edging_root.visible = _edging_visible


func _add_line(mesh: ImmediateMesh, from_position: Vector3, to_position: Vector3) -> void:
	mesh.surface_add_vertex(from_position)
	mesh.surface_add_vertex(to_position)


func _add_cross(mesh: ImmediateMesh, centre: Vector3, radius: float) -> void:
	_add_line(mesh, centre + Vector3.LEFT * radius, centre + Vector3.RIGHT * radius)
	_add_line(mesh, centre + Vector3.FORWARD * radius, centre + Vector3.BACK * radius)


func _add_vertical_marker(mesh: ImmediateMesh, base: Vector3, height: float) -> void:
	_add_line(mesh, base + Vector3.UP * 0.2, base + Vector3.UP * height)


func _load_json_dictionary(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if parsed is Dictionary else {}


func _vector3_from_array(value: Variant) -> Vector3:
	if not value is Array:
		return Vector3.ZERO
	var values: Array = value as Array
	if values.size() < 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _warn(message: String) -> void:
	push_warning("Floor001MainRoadAssembly: %s" % message)
	road_assembly_warning.emit(message)


func _fail(message: String) -> bool:
	_last_error = message
	_road_ready = false
	push_error("Floor001MainRoadAssembly: %s" % message)
	road_assembly_failed.emit(message)
	return false
