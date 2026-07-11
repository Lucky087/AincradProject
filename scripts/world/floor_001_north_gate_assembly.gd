class_name Floor001NorthGateAssembly
extends Node3D

# gdlint: disable=max-returns
# gdlint: disable=max-public-methods
# gdlint: disable=max-file-lines

## Reusable runtime assembly for the Floor 1 Starting City north-gate greybox.
##
## The scene reads the Blender-generated architecture manifest, validates all
## sixteen render and collision resources, reproduces the reference placement,
## and creates StaticBody3D collision only from the dedicated collision GLBs.
## It contains no terrain, player, gameplay, navigation, or global systems.

signal assembly_ready
signal assembly_failed(message: String)
signal assembly_warning(message: String)

const DEFAULT_MANIFEST_PATH: String = (
	"res://AincradProject/assets/environments/floor_001/architecture/north_gate/"
	+ "floor_001_north_gate_architecture_manifest.json"
)
const EXPECTED_ASSET_SET_ID: String = "floor_001_starting_city_north_gate_architecture_v1"
const EXPECTED_GENERATION_STATUS: String = "complete_blender_exports_generated"
const EXPECTED_PIECE_COUNT: int = 16
const EXPECTED_TOTAL_GLB_COUNT: int = 32
const EXPECTED_PASSAGE_WIDTH_METRES: float = 14.0
const EXPECTED_PASSAGE_HEIGHT_METRES: float = 12.0
const ALIGNMENT_TOLERANCE_METRES: float = 0.05
const GENERATED_META_KEY: StringName = &"north_gate_generated"
const NORTH_DIRECTION: Vector3 = Vector3(0.0, 0.0, -1.0)
const FLAT_ROAD_PIECE_PREFIX: String = "floor_001_arch_stone_road_"
const ROAD_EDGING_PIECE_ID: String = "floor_001_arch_road_edging_straight"

@export_category("Architecture Manifest")
@export_file("*.json") var manifest_path: String = DEFAULT_MANIFEST_PATH
@export var auto_place_at_manifest_gate_centre: bool = true
@export var build_on_ready: bool = true

@export_category("Collision")
@export_flags_3d_physics var collision_layer: int = 1
@export_flags_3d_physics var collision_mask: int = 0
## Flat road GLBs remain loaded for validation and C-key visualization, but the
## terrain collision is the walking surface by default. The exported road slabs
## overlap the graded terrain and their concave triangle winding is unsuitable
## for CharacterBody3D floor contact.
@export var flat_road_collision_enabled: bool = false
## Road edging is also visual-only by default because its thin concave box
## intersects the terrain and can wedge the player capsule along the curb.
@export var road_edging_collision_enabled: bool = false

@export_category("Debug")
@export var placement_markers_visible_by_default: bool = false
@export var collision_debug_visible_by_default: bool = false

@export_category("Required Containers")
@export var render_root_path: NodePath = NodePath("Render")
@export var collision_root_path: NodePath = NodePath("Collision")
@export var placement_markers_path: NodePath = NodePath("PlacementMarkers")
@export var collision_visuals_path: NodePath = NodePath("Debug/CollisionVisuals")
@export var marker_visualization_path: NodePath = NodePath("Debug/PlacementMarkerVisualization")

var _manifest: Dictionary = {}
var _pieces_by_id: Dictionary = {}
var _render_resources: Dictionary = {}
var _collision_resources: Dictionary = {}
var _failed_assets: PackedStringArray = []
var _manifest_status: String = "NOT LOADED"
var _last_error: String = ""
var _warnings: PackedStringArray = []
var _assembly_is_ready: bool = false

var _render_root: Node3D = null
var _collision_root: Node3D = null
var _placement_markers: Node3D = null
var _collision_visuals: Node3D = null
var _marker_visualization: MeshInstance3D = null
var _render_category_nodes: Dictionary = {}
var _collision_category_nodes: Dictionary = {}

var _render_asset_count: int = 0
var _collision_asset_count: int = 0
var _render_instance_count: int = 0
var _collision_body_count: int = 0
var _collision_shape_count: int = 0
var _road_collision_body_count: int = 0
var _road_collision_shape_count: int = 0
var _disabled_road_collision_placement_count: int = 0
var _duplicate_collision_count: int = 0
var _collision_placement_ids: Dictionary = {}
var _road_collision_transform_report: PackedStringArray = []
var _flat_road_surface_samples: Array[Dictionary] = []
var _alignment_snapshot: Dictionary = {}
var _passage_width_metres: float = 0.0
var _passage_height_metres: float = 0.0
var _gate_depth_metres: float = 0.0
var _collision_debug_material: StandardMaterial3D = null
var _disabled_collision_debug_material: StandardMaterial3D = null
var _marker_material: StandardMaterial3D = null


func _ready() -> void:
	if not _resolve_required_nodes():
		_fail("Required north-gate assembly containers are missing.")
		return
	_prepare_debug_materials()
	set_placement_markers_visible(placement_markers_visible_by_default)
	set_collision_debug_visible(collision_debug_visible_by_default)
	if build_on_ready:
		rebuild_from_manifest()


func rebuild_from_manifest() -> bool:
	_reset_runtime_state()
	_clear_generated_children()
	_manifest = _load_json_dictionary(manifest_path)
	if _manifest.is_empty():
		return _fail("Architecture manifest could not be loaded: %s" % manifest_path)
	if not _validate_manifest():
		return false
	if auto_place_at_manifest_gate_centre:
		global_position = _anchor_position("CityGateCentre")
	_configure_placement_markers()
	_load_all_piece_resources()
	_build_reference_assembly()
	_build_marker_visualization()
	_calculate_alignment()

	if not _failed_assets.is_empty():
		return _fail(
			"North-gate assembly has %d failed architecture resources." % _failed_assets.size()
		)
	if not bool(_alignment_snapshot.get("within_tolerance", false)):
		_warn("North-gate placement exceeds the 0.05 metre alignment target.")

	_assembly_is_ready = true
	_manifest_status = "PASSED"
	assembly_ready.emit()
	return true


func is_assembly_ready() -> bool:
	return _assembly_is_ready


func get_manifest_status() -> String:
	return _manifest_status


func get_last_error() -> String:
	return _last_error


func get_manifest() -> Dictionary:
	return _manifest.duplicate(true)


func get_alignment_snapshot() -> Dictionary:
	return _alignment_snapshot.duplicate(true)


func get_failed_asset_count() -> int:
	return _failed_assets.size()


func get_failed_assets() -> PackedStringArray:
	return _failed_assets.duplicate()


func get_render_asset_count() -> int:
	return _render_asset_count


func get_collision_asset_count() -> int:
	return _collision_asset_count


func get_render_instance_count() -> int:
	return _render_instance_count


func get_collision_body_count() -> int:
	return _collision_body_count


func get_collision_shape_count() -> int:
	return _collision_shape_count


func get_passage_width_metres() -> float:
	return _passage_width_metres


func get_passage_height_metres() -> float:
	return _passage_height_metres


func set_placement_markers_visible(visible: bool) -> void:
	if _marker_visualization != null:
		_marker_visualization.visible = visible


func are_placement_markers_visible() -> bool:
	return _marker_visualization != null and _marker_visualization.visible


func set_collision_debug_visible(visible: bool) -> void:
	if _collision_visuals != null:
		_collision_visuals.visible = visible


func is_collision_debug_visible() -> bool:
	return _collision_visuals != null and _collision_visuals.visible


func _get_placement_marker(marker_name: StringName) -> Marker3D:
	if _placement_markers == null:
		return null
	var node: Node = _placement_markers.get_node_or_null(NodePath(String(marker_name)))
	return node as Marker3D if node is Marker3D else null


func is_position_inside_gate_passage(world_position: Vector3) -> bool:
	if _passage_width_metres <= 0.0 or _passage_height_metres <= 0.0:
		return false
	var local_position: Vector3 = to_local(world_position)
	return (
		absf(local_position.x) <= _passage_width_metres * 0.5
		and local_position.y >= -0.5
		and local_position.y <= _passage_height_metres
		and absf(local_position.z) <= _gate_depth_metres * 0.5
	)


func _resolve_required_nodes() -> bool:
	_render_root = get_node_or_null(render_root_path) as Node3D
	_collision_root = get_node_or_null(collision_root_path) as Node3D
	_placement_markers = get_node_or_null(placement_markers_path) as Node3D
	_collision_visuals = get_node_or_null(collision_visuals_path) as Node3D
	_marker_visualization = get_node_or_null(marker_visualization_path) as MeshInstance3D
	if (
		_render_root == null
		or _collision_root == null
		or _placement_markers == null
		or _collision_visuals == null
		or _marker_visualization == null
	):
		return false

	_render_category_nodes = {
		"gate": _render_root.get_node_or_null("Gate"),
		"gate_tower": _render_root.get_node_or_null("Towers"),
		"connector": _render_root.get_node_or_null("Connectors"),
		"city_wall": _render_root.get_node_or_null("Walls"),
		"battlement": _render_root.get_node_or_null("Battlements"),
		"stairs": _render_root.get_node_or_null("Stairs"),
		"platform": _render_root.get_node_or_null("Platforms"),
		"road": _render_root.get_node_or_null("Roads"),
	}
	_collision_category_nodes = {
		"gate": _collision_root.get_node_or_null("Gate"),
		"gate_tower": _collision_root.get_node_or_null("Towers"),
		"connector": _collision_root.get_node_or_null("Connectors"),
		"city_wall": _collision_root.get_node_or_null("Walls"),
		"battlement": _collision_root.get_node_or_null("Battlements"),
		"stairs": _collision_root.get_node_or_null("Stairs"),
		"platform": _collision_root.get_node_or_null("Platforms"),
		"road": _collision_root.get_node_or_null("Roads"),
	}
	for category_node: Variant in _render_category_nodes.values():
		if not category_node is Node3D:
			return false
	for category_node: Variant in _collision_category_nodes.values():
		if not category_node is Node3D:
			return false
	return true


func _reset_runtime_state() -> void:
	_manifest.clear()
	_pieces_by_id.clear()
	_render_resources.clear()
	_collision_resources.clear()
	_failed_assets.clear()
	_warnings.clear()
	_alignment_snapshot.clear()
	_render_asset_count = 0
	_collision_asset_count = 0
	_render_instance_count = 0
	_collision_body_count = 0
	_collision_shape_count = 0
	_road_collision_body_count = 0
	_road_collision_shape_count = 0
	_disabled_road_collision_placement_count = 0
	_duplicate_collision_count = 0
	_collision_placement_ids.clear()
	_road_collision_transform_report.clear()
	_flat_road_surface_samples.clear()
	_passage_width_metres = 0.0
	_passage_height_metres = 0.0
	_gate_depth_metres = 0.0
	_manifest_status = "VALIDATING"
	_last_error = ""
	_assembly_is_ready = false


func _clear_generated_children() -> void:
	for category_node: Variant in _render_category_nodes.values():
		_remove_generated_children(category_node as Node)
	for category_node: Variant in _collision_category_nodes.values():
		_remove_generated_children(category_node as Node)
	_remove_generated_children(_collision_visuals)
	_marker_visualization.mesh = null


func _remove_generated_children(parent: Node) -> void:
	if parent == null:
		return
	for child: Node in parent.get_children():
		if bool(child.get_meta(GENERATED_META_KEY, false)):
			child.free()


func _validate_manifest() -> bool:
	if String(_manifest.get("asset_set_id", "")) != EXPECTED_ASSET_SET_ID:
		return _fail("Unexpected north-gate asset-set ID.")
	var generation_status: String = String(_manifest.get("generation_status", ""))
	if generation_status != EXPECTED_GENERATION_STATUS:
		return _fail(
			"Architecture exports are not complete. Manifest status: %s" % generation_status
		)

	var exports_value: Variant = _manifest.get("exports", {})
	if not exports_value is Dictionary:
		return _fail("Architecture manifest has no exports dictionary.")
	var exports: Dictionary = exports_value
	if int(exports.get("piece_count", 0)) != EXPECTED_PIECE_COUNT:
		return _fail("Architecture manifest must register exactly 16 pieces.")
	if int(exports.get("expected_render_glb_count", 0)) != EXPECTED_PIECE_COUNT:
		return _fail("Architecture manifest must expect 16 render GLBs.")
	if int(exports.get("expected_collision_glb_count", 0)) != EXPECTED_PIECE_COUNT:
		return _fail("Architecture manifest must expect 16 collision GLBs.")
	if int(exports.get("actual_glb_count", 0)) != EXPECTED_TOTAL_GLB_COUNT:
		return _fail("Architecture manifest must confirm 32 generated GLBs.")

	var coordinate_value: Variant = _manifest.get("coordinate_system", {})
	if not coordinate_value is Dictionary:
		return _fail("Architecture coordinate-system data is missing.")
	var coordinate_system: Dictionary = coordinate_value
	if not is_equal_approx(float(coordinate_system.get("units_per_metre", 0.0)), 1.0):
		return _fail("Architecture scale must be one unit per metre.")
	var axes_value: Variant = coordinate_system.get("godot_axes", {})
	if not axes_value is Dictionary:
		return _fail("Godot axis data is missing from the architecture manifest.")
	var axes: Dictionary = axes_value
	if String(axes.get("north", "")) != "-Z" or String(axes.get("up", "")) != "+Y":
		return _fail("Architecture forward/up axes are incompatible with Floor 1.")

	var design_value: Variant = _manifest.get("design_parameters", {})
	if not design_value is Dictionary:
		return _fail("Architecture design parameters are missing.")
	var design: Dictionary = design_value
	_passage_width_metres = float(design.get("gate_passage_width_m", 0.0))
	_passage_height_metres = float(design.get("gate_passage_height_m", 0.0))
	if not is_equal_approx(_passage_width_metres, EXPECTED_PASSAGE_WIDTH_METRES):
		return _fail("Gate passage width must be 14 metres.")
	if not is_equal_approx(_passage_height_metres, EXPECTED_PASSAGE_HEIGHT_METRES):
		return _fail("Gate passage height must be 12 metres.")
	var gate_dimensions: Vector3 = _vector3_from_array(design.get("gate_central_dimensions_m", []))
	_gate_depth_metres = gate_dimensions.z
	if _gate_depth_metres <= 0.0:
		return _fail("Gate depth is missing from the architecture manifest.")

	var pieces_value: Variant = _manifest.get("pieces", [])
	if not pieces_value is Array:
		return _fail("Architecture piece records must be an array.")
	var pieces: Array = pieces_value
	if pieces.size() != EXPECTED_PIECE_COUNT:
		return _fail("Architecture manifest must contain exactly 16 piece records.")
	for piece_value: Variant in pieces:
		if not piece_value is Dictionary:
			return _fail("Architecture piece record is not a dictionary.")
		var piece: Dictionary = piece_value
		var piece_id: String = String(piece.get("piece_id", ""))
		if piece_id.is_empty() or _pieces_by_id.has(piece_id):
			return _fail("Architecture piece IDs must be non-empty and unique.")
		var render_path: String = String(piece.get("render_path", ""))
		var collision_path: String = String(piece.get("collision_path", ""))
		if not FileAccess.file_exists(render_path):
			return _fail("Missing render GLB: %s" % render_path)
		if not FileAccess.file_exists(collision_path):
			return _fail("Missing collision GLB: %s" % collision_path)
		_pieces_by_id[piece_id] = piece

	var reference_value: Variant = _manifest.get("reference_assembly", {})
	if not reference_value is Dictionary:
		return _fail("Reference assembly placement records are missing.")
	var reference: Dictionary = reference_value
	var placements_value: Variant = reference.get("placements", [])
	if not placements_value is Array or (placements_value as Array).is_empty():
		return _fail("Reference assembly placements are missing.")
	var placement_ids: Dictionary = {}
	for placement_value: Variant in placements_value as Array:
		if not placement_value is Dictionary:
			return _fail("Architecture placement record is not a dictionary.")
		var placement: Dictionary = placement_value
		var placement_id: String = String(placement.get("placement_id", ""))
		var piece_id: String = String(placement.get("piece_id", ""))
		if placement_id.is_empty() or placement_ids.has(placement_id):
			return _fail("Architecture placement IDs must be non-empty and unique.")
		if not _pieces_by_id.has(piece_id):
			return _fail("Placement references unknown piece ID: %s" % piece_id)
		placement_ids[placement_id] = true

	var validation_value: Variant = _manifest.get("validation", {})
	if not validation_value is Dictionary:
		return _fail("Architecture preflight validation data is missing.")
	var validation: Dictionary = validation_value
	if not bool(validation.get("preflight_passed", false)):
		return _fail("Blender architecture preflight did not pass.")
	if not bool(validation.get("open_gate_passage_preserved", false)):
		return _fail("Manifest does not confirm an open gate passage.")
	return true


func _load_all_piece_resources() -> void:
	for piece_id_value: Variant in _pieces_by_id.keys():
		var piece_id: String = String(piece_id_value)
		var piece: Dictionary = _pieces_by_id[piece_id]
		var render_path: String = String(piece.get("render_path", ""))
		var collision_path: String = String(piece.get("collision_path", ""))
		var render_scene: PackedScene = (
			ResourceLoader.load(render_path, "PackedScene") as PackedScene
		)
		if render_scene == null:
			_failed_assets.append(render_path)
		else:
			_render_resources[piece_id] = render_scene
			_render_asset_count += 1
		var collision_scene: PackedScene = (
			ResourceLoader.load(collision_path, "PackedScene") as PackedScene
		)
		if collision_scene == null:
			_failed_assets.append(collision_path)
		else:
			_collision_resources[piece_id] = collision_scene
			_collision_asset_count += 1


func _build_reference_assembly() -> void:
	var reference: Dictionary = _manifest.get("reference_assembly", {})
	var placements: Array = reference.get("placements", [])
	for placement_value: Variant in placements:
		var placement: Dictionary = placement_value
		var piece_id: String = String(placement.get("piece_id", ""))
		var piece: Dictionary = _pieces_by_id.get(piece_id, {})
		var category_key: String = _category_key(piece_id, String(piece.get("category", "")))
		_build_render_placement(placement, piece_id, category_key)
		_build_collision_placement(
			placement, piece_id, category_key, _is_collision_enabled_for_piece(piece_id)
		)
	_print_collision_diagnostics()


func _build_render_placement(placement: Dictionary, piece_id: String, category_key: String) -> void:
	if not _render_resources.has(piece_id):
		return
	var parent: Node3D = _render_category_nodes.get(category_key) as Node3D
	if parent == null:
		_failed_assets.append("render category:%s" % category_key)
		return
	var placement_root: Node3D = _create_placement_root(placement)
	parent.add_child(placement_root)
	var render_scene: PackedScene = _render_resources[piece_id] as PackedScene
	var instance: Node = render_scene.instantiate()
	instance.name = &"RenderAsset"
	placement_root.add_child(instance)
	_render_instance_count += 1
	_register_flat_road_surface_sample(placement, piece_id)


func _build_collision_placement(
	placement: Dictionary, piece_id: String, category_key: String, physics_enabled: bool
) -> void:
	if not _collision_resources.has(piece_id):
		return
	var placement_id: String = String(placement.get("placement_id", ""))
	if _collision_placement_ids.has(placement_id):
		_duplicate_collision_count += 1
		_warn("Duplicate collision placement skipped: %s" % placement_id)
		return
	_collision_placement_ids[placement_id] = true
	_register_road_collision_transform(placement, piece_id, physics_enabled)
	_build_collision_debug_visual(placement, piece_id, physics_enabled)
	if not physics_enabled:
		if _is_flat_road_piece(piece_id) or _is_road_edging_piece(piece_id):
			_disabled_road_collision_placement_count += 1
		return

	var parent: Node3D = _collision_category_nodes.get(category_key) as Node3D
	if parent == null:
		_failed_assets.append("collision category:%s" % category_key)
		return

	var placement_root: Node3D = _create_placement_root(placement)
	parent.add_child(placement_root)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = &"StaticBody3D"
	body.collision_layer = collision_layer
	body.collision_mask = collision_mask
	body.set_meta(GENERATED_META_KEY, true)
	body.set_meta("placement_id", placement_id)
	body.set_meta("piece_id", piece_id)
	placement_root.add_child(body)

	var collision_scene: PackedScene = _collision_resources[piece_id] as PackedScene
	var source_root: Node = collision_scene.instantiate()
	var mesh_nodes: Array[MeshInstance3D] = []
	_collect_mesh_instances(source_root, mesh_nodes)
	var shape_index: int = 0
	for mesh_instance: MeshInstance3D in mesh_nodes:
		if mesh_instance.mesh == null:
			continue
		var shape: Shape3D = mesh_instance.mesh.create_trimesh_shape()
		if shape == null:
			continue
		var collision_shape: CollisionShape3D = CollisionShape3D.new()
		collision_shape.name = StringName("CollisionShape_%02d" % shape_index)
		collision_shape.shape = shape
		collision_shape.transform = _transform_relative_to_root(mesh_instance, source_root)
		body.add_child(collision_shape)
		shape_index += 1
		_collision_shape_count += 1
		if _is_flat_road_piece(piece_id) or _is_road_edging_piece(piece_id):
			_road_collision_shape_count += 1
	source_root.free()
	if shape_index == 0:
		_failed_assets.append("collision meshes:%s" % piece_id)
		placement_root.free()
		return
	_collision_body_count += 1
	if _is_flat_road_piece(piece_id) or _is_road_edging_piece(piece_id):
		_road_collision_body_count += 1


func _build_collision_debug_visual(
	placement: Dictionary, piece_id: String, physics_enabled: bool
) -> void:
	var collision_scene: PackedScene = _collision_resources.get(piece_id) as PackedScene
	if collision_scene == null:
		return
	var visual_root: Node3D = _create_placement_root(placement)
	visual_root.name = StringName(String(placement.get("placement_id", "")) + "_debug")
	_collision_visuals.add_child(visual_root)
	var instance: Node = collision_scene.instantiate()
	instance.name = &"CollisionSourceVisual"
	visual_root.add_child(instance)
	var mesh_nodes: Array[MeshInstance3D] = []
	_collect_mesh_instances(instance, mesh_nodes)
	for mesh_instance: MeshInstance3D in mesh_nodes:
		mesh_instance.material_override = (
			_collision_debug_material if physics_enabled else _disabled_collision_debug_material
		)
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual_root.set_meta("physics_enabled", physics_enabled)


func _is_flat_road_piece(piece_id: String) -> bool:
	return piece_id.begins_with(FLAT_ROAD_PIECE_PREFIX)


func _is_road_edging_piece(piece_id: String) -> bool:
	return piece_id == ROAD_EDGING_PIECE_ID


func _is_collision_enabled_for_piece(piece_id: String) -> bool:
	if _is_flat_road_piece(piece_id):
		return flat_road_collision_enabled
	if _is_road_edging_piece(piece_id):
		return road_edging_collision_enabled
	return true


func _register_road_collision_transform(
	placement: Dictionary, piece_id: String, physics_enabled: bool
) -> void:
	if not _is_flat_road_piece(piece_id) and not _is_road_edging_piece(piece_id):
		return
	var local_position: Vector3 = _vector3_from_array(
		placement.get("local_position_relative_to_city_gate_centre", [])
	)
	var local_scale: Vector3 = _vector3_from_array(placement.get("local_scale", [1.0, 1.0, 1.0]))
	var world_position: Vector3 = to_global(local_position)
	var report_line: String = (
		(
			"%s | %s | physics=%s | world=(%.2f, %.2f, %.2f) | rotY=%.1f | "
			+ "scale=(%.3f, %.3f, %.3f)"
		)
		% [
			String(placement.get("placement_id", "")),
			piece_id,
			"ON" if physics_enabled else "OFF",
			world_position.x,
			world_position.y,
			world_position.z,
			float(placement.get("local_rotation_y_degrees", 0.0)),
			local_scale.x,
			local_scale.y,
			local_scale.z,
		]
	)
	_road_collision_transform_report.append(report_line)


func _register_flat_road_surface_sample(placement: Dictionary, piece_id: String) -> void:
	if not _is_flat_road_piece(piece_id):
		return
	var piece: Dictionary = _pieces_by_id.get(piece_id, {})
	var dimensions: Vector3 = _vector3_from_array(piece.get("nominal_dimensions_m", []))
	if dimensions.z <= 0.0:
		return
	var local_position: Vector3 = _vector3_from_array(
		placement.get("local_position_relative_to_city_gate_centre", [])
	)
	var local_scale: Vector3 = _vector3_from_array(placement.get("local_scale", [1.0, 1.0, 1.0]))
	var local_surface_position: Vector3 = local_position + Vector3.UP * dimensions.z * local_scale.y
	var world_surface_position: Vector3 = to_global(local_surface_position)
	(
		_flat_road_surface_samples
		. append(
			{
				"placement_id": String(placement.get("placement_id", "")),
				"piece_id": piece_id,
				"world_position": world_surface_position,
				"surface_y": world_surface_position.y,
			}
		)
	)


func _refresh_road_collision_debug_metadata() -> void:
	set_meta(
		"road_collision_debug_snapshot",
		{
			"flat_road_collision_enabled": flat_road_collision_enabled,
			"road_edging_collision_enabled": road_edging_collision_enabled,
			"road_collision_body_count": _road_collision_body_count,
			"road_collision_shape_count": _road_collision_shape_count,
			"disabled_road_collision_placement_count": _disabled_road_collision_placement_count,
			"duplicate_collision_count": _duplicate_collision_count,
			"road_collision_transform_report": _road_collision_transform_report.duplicate(),
			"flat_road_surface_samples": _flat_road_surface_samples.duplicate(true),
		},
	)


func _print_collision_diagnostics() -> void:
	_refresh_road_collision_debug_metadata()
	print(
		(
			(
				"North-gate road collision: flat surfaces=%s, edging=%s, active bodies=%d, "
				+ "active shapes=%d, disabled placements=%d, duplicates=%d"
			)
			% [
				"ON" if flat_road_collision_enabled else "OFF",
				"ON" if road_edging_collision_enabled else "OFF",
				_road_collision_body_count,
				_road_collision_shape_count,
				_disabled_road_collision_placement_count,
				_duplicate_collision_count,
			]
		)
	)
	for report_line: String in _road_collision_transform_report:
		print("  ", report_line)


func _create_placement_root(placement: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = StringName(String(placement.get("placement_id", "unnamed_placement")))
	root.position = _vector3_from_array(
		placement.get("local_position_relative_to_city_gate_centre", [])
	)
	root.rotation_degrees = Vector3(0.0, float(placement.get("local_rotation_y_degrees", 0.0)), 0.0)
	root.scale = _vector3_from_array(placement.get("local_scale", [1.0, 1.0, 1.0]))
	root.set_meta(GENERATED_META_KEY, true)
	root.set_meta("placement_id", String(placement.get("placement_id", "")))
	root.set_meta("piece_id", String(placement.get("piece_id", "")))
	return root


func _collect_mesh_instances(node: Node, output: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		output.append(node as MeshInstance3D)
	for child: Node in node.get_children():
		_collect_mesh_instances(child, output)


func _transform_relative_to_root(node: Node3D, source_root: Node) -> Transform3D:
	var result: Transform3D = Transform3D.IDENTITY
	var current: Node = node
	while current != null:
		if current is Node3D:
			result = (current as Node3D).transform * result
		if current == source_root:
			break
		current = current.get_parent()
	return result


func _category_key(piece_id: String, manifest_category: String) -> String:
	if manifest_category == "access":
		return "stairs" if piece_id.contains("stairs") else "platform"
	if manifest_category == "road_edging":
		return "road"
	return manifest_category


func _configure_placement_markers() -> void:
	var gate_world: Vector3 = _anchor_position("CityGateCentre")
	var marker_positions: Dictionary = {
		"GateCentre": Vector3.ZERO,
		"WestWallEndpoint": _anchor_position("CityWallWestConnection") - gate_world,
		"EastWallEndpoint": _anchor_position("CityWallEastConnection") - gate_world,
		"MainRoadStart": _anchor_position("MainRoadStart") - gate_world,
		"GateForward": Vector3(0.0, 0.0, -20.0),
	}
	for marker_name_value: Variant in marker_positions.keys():
		var marker_name: String = String(marker_name_value)
		var marker: Marker3D = _get_placement_marker(StringName(marker_name))
		if marker != null:
			marker.position = marker_positions[marker_name]


func _calculate_alignment() -> void:
	var gate_marker: Marker3D = _get_placement_marker(&"GateCentre")
	var west_marker: Marker3D = _get_placement_marker(&"WestWallEndpoint")
	var east_marker: Marker3D = _get_placement_marker(&"EastWallEndpoint")
	var road_marker: Marker3D = _get_placement_marker(&"MainRoadStart")
	if gate_marker == null or west_marker == null or east_marker == null or road_marker == null:
		_alignment_snapshot = {"within_tolerance": false}
		return
	var gate_error: float = gate_marker.global_position.distance_to(
		_anchor_position("CityGateCentre")
	)
	var west_error: float = west_marker.global_position.distance_to(
		_anchor_position("CityWallWestConnection")
	)
	var east_error: float = east_marker.global_position.distance_to(
		_anchor_position("CityWallEastConnection")
	)
	var road_error: float = road_marker.global_position.distance_to(
		_anchor_position("MainRoadStart")
	)
	var forward_direction: Vector3 = (global_transform.basis * Vector3.FORWARD).normalized()
	var forward_dot: float = clampf(forward_direction.dot(NORTH_DIRECTION), -1.0, 1.0)
	var forward_angle_degrees: float = rad_to_deg(acos(forward_dot))
	var within_tolerance: bool = (
		gate_error <= ALIGNMENT_TOLERANCE_METRES
		and west_error <= ALIGNMENT_TOLERANCE_METRES
		and east_error <= ALIGNMENT_TOLERANCE_METRES
		and road_error <= ALIGNMENT_TOLERANCE_METRES
		and forward_angle_degrees <= 0.1
	)
	_alignment_snapshot = {
		"gate_centre_error_m": gate_error,
		"west_endpoint_error_m": west_error,
		"east_endpoint_error_m": east_error,
		"road_centreline_error_m": road_error,
		"forward_dot": forward_dot,
		"forward_angle_error_degrees": forward_angle_degrees,
		"forward_matches_negative_z": forward_dot >= 0.9999,
		"target_tolerance_m": ALIGNMENT_TOLERANCE_METRES,
		"within_tolerance": within_tolerance,
	}
	if not within_tolerance:
		var warning_text: String = (
			(
				"North-gate alignment warning: gate %.4f m, west %.4f m, east %.4f m, "
				+ "road %.4f m, forward %.3f degrees."
			)
			% [gate_error, west_error, east_error, road_error, forward_angle_degrees]
		)
		push_warning(warning_text)


func _build_marker_visualization() -> void:
	var mesh: ImmediateMesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, _marker_material)
	for child: Node in _placement_markers.get_children():
		if not child is Marker3D:
			continue
		var marker: Marker3D = child as Marker3D
		var position: Vector3 = marker.position + Vector3.UP * 0.5
		_add_line(mesh, position + Vector3(-3.0, 0.0, 0.0), position + Vector3(3.0, 0.0, 0.0))
		_add_line(mesh, position + Vector3(0.0, 0.0, -3.0), position + Vector3(0.0, 0.0, 3.0))
		_add_line(mesh, position, position + Vector3.UP * 12.0)
	mesh.surface_end()
	_marker_visualization.mesh = mesh
	_marker_visualization.visible = placement_markers_visible_by_default


func _prepare_debug_materials() -> void:
	_collision_debug_material = StandardMaterial3D.new()
	_collision_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_collision_debug_material.albedo_color = Color(1.0, 0.12, 0.08, 0.28)
	_collision_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_collision_debug_material.no_depth_test = true

	_disabled_collision_debug_material = StandardMaterial3D.new()
	_disabled_collision_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_disabled_collision_debug_material.albedo_color = Color(1.0, 0.72, 0.08, 0.32)
	_disabled_collision_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_disabled_collision_debug_material.no_depth_test = true

	_marker_material = StandardMaterial3D.new()
	_marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_marker_material.albedo_color = Color(1.0, 0.3, 0.92, 0.95)
	_marker_material.no_depth_test = true


func _anchor_position(anchor_name: String) -> Vector3:
	var anchors_value: Variant = _manifest.get("locked_anchors", {})
	if not anchors_value is Dictionary:
		return Vector3.ZERO
	var anchors: Dictionary = anchors_value
	var anchor_value: Variant = anchors.get(anchor_name, {})
	if not anchor_value is Dictionary:
		return Vector3.ZERO
	return _vector3_from_array((anchor_value as Dictionary).get("position", []))


func _add_line(mesh: ImmediateMesh, from_position: Vector3, to_position: Vector3) -> void:
	mesh.surface_add_vertex(from_position)
	mesh.surface_add_vertex(to_position)


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
	var values: Array = value
	if values.size() != 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _warn(message: String) -> void:
	_warnings.append(message)
	push_warning(message)
	assembly_warning.emit(message)


func _fail(message: String) -> bool:
	_last_error = message
	_manifest_status = "FAILED: %s" % message
	_assembly_is_ready = false
	push_error(message)
	assembly_failed.emit(message)
	return false
