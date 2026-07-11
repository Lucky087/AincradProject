class_name TerrainChunkTestLoader
extends Node3D

# gdlint: disable=max-returns

## Loads the nine Blender terrain-test chunks from their generated manifest.
##
## This scene is intentionally isolated from the normal game. It validates the
## manifest, places LOD scenes from manifest coordinates, builds StaticBody3D
## collision from the dedicated collision GLBs, exposes an F4 LOD toggle, and
## recovers the player if they fall below the test grid.

const MANIFEST_PATH: String = (
	"res://AincradProject/assets/environments/floor_001/terrain/"
	+ "test_chunks/terrain_test_manifest.json"
)
const EXPECTED_FLOOR_ID: String = "floor_001"
const EXPECTED_CHUNK_COUNT: int = 9
const EXPECTED_CHUNK_SIZE_METRES: float = 256.0
const EXPECTED_TOTAL_SIZE_METRES: float = 768.0
const EXPECTED_CENTRE_CHUNK_ID: StringName = &"floor_001_chunk_x+00_z+14"
const TERRAIN_COLLISION_LAYER: int = 1
const PLAYER_GROUP: StringName = &"players"
const LOD_TOGGLE_KEY: Key = KEY_F4

@export_category("Required Nodes")
@export var terrain_chunks_path: NodePath = NodePath("TerrainChunks")
@export var player_path: NodePath = NodePath("Player")
@export var fall_recovery_area_path: NodePath = NodePath("BoundarySafety/FallRecoveryArea")
@export var debug_label_path: NodePath = NodePath("DebugUI/DebugPanel/MarginContainer/DebugLabel")
@export var debug_timer_path: NodePath = NodePath("DebugUI/DebugUpdateTimer")

@export_category("Test Settings")
@export_range(0.1, 5.0, 0.1)
var debug_update_interval_seconds: float = 0.25
@export_range(1.0, 20.0, 0.5)
var player_height_above_centre_chunk: float = 6.0

var _terrain_chunks: Node3D = null
var _player: CharacterBody3D = null
var _fall_recovery_area: Area3D = null
var _debug_label: Label = null
var _debug_timer: Timer = null

var _chunk_records: Dictionary = {}
var _loaded_lod0_count: int = 0
var _loaded_lod1_count: int = 0
var _loaded_collision_count: int = 0
var _current_lod_index: int = 0
var _centre_chunk_id: StringName = EXPECTED_CENTRE_CHUNK_ID
var _manifest_seams_passed: bool = false
var _manifest_status: String = "Manifest not loaded"
var _safe_player_transform: Transform3D = Transform3D.IDENTITY
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		_update_debug_label()
		return

	_safe_player_transform = _player.global_transform
	_debug_timer.wait_time = debug_update_interval_seconds
	_debug_timer.timeout.connect(_on_debug_update_timer_timeout)
	_fall_recovery_area.body_entered.connect(_on_fall_recovery_area_body_entered)

	var manifest: Dictionary = _load_manifest()
	if manifest.is_empty():
		_update_debug_label()
		return

	if not _validate_manifest(manifest):
		_update_debug_label()
		return

	_load_all_chunks(manifest)
	_configure_player_spawn()
	_update_debug_label()


func _unhandled_key_input(event: InputEvent) -> void:
	if not _setup_is_valid or not event is InputEventKey:
		return

	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if (
		key_event.keycode != LOD_TOGGLE_KEY
		and key_event.physical_keycode != LOD_TOGGLE_KEY
	):
		return

	_toggle_visual_lod()
	get_viewport().set_input_as_handled()


func _load_manifest() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_manifest_status = "Manifest missing"
		push_error("TerrainChunkTest could not find: %s" % MANIFEST_PATH)
		return {}

	var manifest_file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null:
		_manifest_status = "Manifest could not be opened"
		push_error(
			"TerrainChunkTest could not open manifest. Error: %s"
			% error_string(FileAccess.get_open_error())
		)
		return {}

	var manifest_text: String = manifest_file.get_as_text()
	var read_error: Error = manifest_file.get_error()
	manifest_file.close()

	if read_error != OK:
		_manifest_status = "Manifest read failed"
		push_error(
			"TerrainChunkTest failed while reading the manifest. Error: %s"
			% error_string(read_error)
		)
		return {}

	if manifest_text.strip_edges().is_empty():
		_manifest_status = "Manifest is empty"
		push_error("TerrainChunkTest found an empty manifest.")
		return {}

	var json_parser: JSON = JSON.new()
	var parse_error: Error = json_parser.parse(manifest_text)
	if parse_error != OK:
		_manifest_status = "Manifest JSON is invalid"
		push_error(
			(
				"TerrainChunkTest could not parse the manifest at line %d: %s"
				% [json_parser.get_error_line(), json_parser.get_error_message()]
			)
		)
		return {}

	var parsed_data: Variant = json_parser.data
	if not parsed_data is Dictionary:
		_manifest_status = "Manifest root is not an object"
		push_error("TerrainChunkTest expected a Dictionary at the JSON root.")
		return {}

	return parsed_data


func _validate_manifest(manifest: Dictionary) -> bool:
	if String(manifest.get("floor_id", "")) != EXPECTED_FLOOR_ID:
		_manifest_status = "Unexpected floor ID"
		push_error("TerrainChunkTest manifest floor_id must be floor_001.")
		return false

	if not _is_number(manifest.get("chunk_size_m")):
		_manifest_status = "Missing chunk size"
		push_error("TerrainChunkTest manifest is missing numeric chunk_size_m.")
		return false

	var chunk_size: float = float(manifest["chunk_size_m"])
	if not is_equal_approx(chunk_size, EXPECTED_CHUNK_SIZE_METRES):
		_manifest_status = "Unexpected chunk size"
		push_error(
			"TerrainChunkTest expected 256 m chunks but found %.3f m." % chunk_size
		)
		return false

	if not _is_number(manifest.get("units_per_metre")):
		_manifest_status = "Missing unit scale"
		push_error("TerrainChunkTest manifest is missing units_per_metre.")
		return false

	if not is_equal_approx(float(manifest["units_per_metre"]), 1.0):
		_manifest_status = "Incorrect unit scale"
		push_error("TerrainChunkTest requires one Godot unit per metre.")
		return false

	var chunks_value: Variant = manifest.get("chunks")
	if not chunks_value is Array:
		_manifest_status = "Chunk list is missing"
		push_error("TerrainChunkTest manifest chunks must be an Array.")
		return false

	var chunks: Array = chunks_value
	if chunks.size() != EXPECTED_CHUNK_COUNT:
		_manifest_status = "Unexpected chunk count"
		push_error(
			"TerrainChunkTest expected 9 chunks but found %d." % chunks.size()
		)
		return false

	var test_grid_value: Variant = manifest.get("test_grid")
	if not test_grid_value is Dictionary:
		_manifest_status = "Test-grid metadata is missing"
		push_error("TerrainChunkTest manifest is missing test_grid metadata.")
		return false

	var test_grid: Dictionary = test_grid_value
	var centre_value: Variant = test_grid.get("centre_chunk")
	if not centre_value is Dictionary:
		_manifest_status = "Centre chunk metadata is missing"
		push_error("TerrainChunkTest manifest is missing centre_chunk metadata.")
		return false

	var centre_chunk: Dictionary = centre_value
	_centre_chunk_id = StringName(String(centre_chunk.get("chunk_id", "")))
	if _centre_chunk_id != EXPECTED_CENTRE_CHUNK_ID:
		_manifest_status = "Unexpected centre chunk"
		push_error(
			"TerrainChunkTest expected centre chunk %s but found %s."
			% [EXPECTED_CENTRE_CHUNK_ID, _centre_chunk_id]
		)
		return false

	var seam_value: Variant = manifest.get("seam_validation")
	if seam_value is Dictionary:
		var seam_data: Dictionary = seam_value
		_manifest_seams_passed = bool(seam_data.get("passed", false))
	else:
		_manifest_seams_passed = false
		push_warning("TerrainChunkTest manifest has no seam_validation object.")

	if not _manifest_seams_passed:
		push_warning(
			"TerrainChunkTest manifest reports failed or unavailable seam validation."
		)

	_manifest_status = "Manifest validated"
	print("TerrainChunkTest manifest validation passed.")
	print("Centre chunk: %s" % _centre_chunk_id)
	print("Manifest seam validation: %s" % _passed_text(_manifest_seams_passed))
	return true


func _load_all_chunks(manifest: Dictionary) -> void:
	var chunks: Array = manifest["chunks"]
	var minimum_x: float = INF
	var maximum_x: float = -INF
	var minimum_z: float = INF
	var maximum_z: float = -INF

	for entry_value: Variant in chunks:
		if not entry_value is Dictionary:
			push_warning("TerrainChunkTest skipped a non-Dictionary chunk entry.")
			continue

		var entry: Dictionary = entry_value
		if not _validate_chunk_entry(entry):
			continue

		var bounds: Dictionary = entry["bounds"]
		minimum_x = minf(minimum_x, float(bounds["min_x"]))
		maximum_x = maxf(maximum_x, float(bounds["max_x"]))
		minimum_z = minf(minimum_z, float(bounds["min_z"]))
		maximum_z = maxf(maximum_z, float(bounds["max_z"]))
		_load_chunk(entry)

	var total_width_x: float = maximum_x - minimum_x
	var total_width_z: float = maximum_z - minimum_z
	if (
		not is_equal_approx(total_width_x, EXPECTED_TOTAL_SIZE_METRES)
		or not is_equal_approx(total_width_z, EXPECTED_TOTAL_SIZE_METRES)
	):
		push_warning(
			(
				"TerrainChunkTest grid bounds are %.3f x %.3f m; expected 768 x 768 m."
				% [total_width_x, total_width_z]
			)
		)
	else:
		print("TerrainChunkTest total grid area validated: 768 x 768 metres.")

	print(
		(
			"TerrainChunkTest loaded %d LOD0, %d LOD1, and %d collision chunks."
			% [_loaded_lod0_count, _loaded_lod1_count, _loaded_collision_count]
		)
	)


func _validate_chunk_entry(entry: Dictionary) -> bool:
	var chunk_id: String = String(entry.get("chunk_id", ""))
	if chunk_id.is_empty():
		push_warning("TerrainChunkTest skipped a chunk without chunk_id.")
		return false

	if not _is_numeric_vector3(entry.get("global_position")):
		push_warning("%s has an invalid global_position." % chunk_id)
		return false

	var grid_value: Variant = entry.get("grid_coordinates")
	if not grid_value is Dictionary:
		push_warning("%s has no grid_coordinates object." % chunk_id)
		return false

	var grid: Dictionary = grid_value
	if not _is_number(grid.get("x")) or not _is_number(grid.get("z")):
		push_warning("%s has invalid grid coordinates." % chunk_id)
		return false

	var bounds_value: Variant = entry.get("bounds")
	if not bounds_value is Dictionary:
		push_warning("%s has no bounds object." % chunk_id)
		return false

	var bounds: Dictionary = bounds_value
	for key: String in ["min_x", "max_x", "min_y", "max_y", "min_z", "max_z"]:
		if not _is_number(bounds.get(key)):
			push_warning("%s has invalid bounds.%s." % [chunk_id, key])
			return false

	for path_key: String in ["lod0_path", "lod1_path", "collision_path"]:
		if String(entry.get(path_key, "")).is_empty():
			push_warning("%s has no %s." % [chunk_id, path_key])
			return false

	var global_position: Vector3 = _vector3_from_array(entry["global_position"])
	var expected_position: Vector3 = Vector3(
		float(grid["x"]) * EXPECTED_CHUNK_SIZE_METRES,
		0.0,
		float(grid["z"]) * EXPECTED_CHUNK_SIZE_METRES
	)
	if not global_position.is_equal_approx(expected_position):
		push_warning(
			(
				"%s manifest position %s does not match grid-derived position %s."
				% [chunk_id, global_position, expected_position]
			)
		)
		return false

	return true


func _load_chunk(entry: Dictionary) -> void:
	var chunk_id: StringName = StringName(String(entry["chunk_id"]))
	var chunk_root: Node3D = Node3D.new()
	chunk_root.name = String(chunk_id)
	chunk_root.position = _vector3_from_array(entry["global_position"])
	_terrain_chunks.add_child(chunk_root)

	var lod0_container: Node3D = _create_container(chunk_root, "VisualLOD0")
	var lod1_container: Node3D = _create_container(chunk_root, "VisualLOD1")
	var collision_container: Node3D = _create_container(chunk_root, "Collision")
	lod1_container.visible = false

	var lod0_instance: Node = _instantiate_glb(String(entry["lod0_path"]), chunk_id, "LOD0")
	if lod0_instance != null:
		lod0_container.add_child(lod0_instance)
		_loaded_lod0_count += 1

	var lod1_instance: Node = _instantiate_glb(String(entry["lod1_path"]), chunk_id, "LOD1")
	if lod1_instance != null:
		lod1_container.add_child(lod1_instance)
		_loaded_lod1_count += 1

	var collision_shape_count: int = _create_collision_from_glb(
		String(entry["collision_path"]),
		chunk_id,
		collision_container
	)
	if collision_shape_count > 0:
		_loaded_collision_count += 1

	_chunk_records[chunk_id] = {
		"root": chunk_root,
		"lod0": lod0_container,
		"lod1": lod1_container,
		"collision": collision_container,
		"bounds": entry["bounds"],
	}

	print(
		"Loaded %s at %s with %d collision shape(s)."
		% [chunk_id, chunk_root.position, collision_shape_count]
	)


func _create_container(parent_node: Node3D, container_name: String) -> Node3D:
	var container: Node3D = Node3D.new()
	container.name = container_name
	parent_node.add_child(container)
	return container


func _instantiate_glb(path: String, chunk_id: StringName, purpose: String) -> Node:
	if not ResourceLoader.exists(path):
		push_warning("%s %s file is missing: %s" % [chunk_id, purpose, path])
		return null

	var loaded_resource: Resource = ResourceLoader.load(path)
	if not loaded_resource is PackedScene:
		push_warning("%s %s did not import as a PackedScene: %s" % [chunk_id, purpose, path])
		return null

	var packed_scene: PackedScene = loaded_resource as PackedScene
	var instance: Node = packed_scene.instantiate()
	instance.name = purpose
	return instance


func _create_collision_from_glb(
	path: String,
	chunk_id: StringName,
	collision_container: Node3D
) -> int:
	var collision_source: Node = _instantiate_glb(path, chunk_id, "CollisionSource")
	if collision_source == null:
		return 0

	collision_container.add_child(collision_source)
	if collision_source is Node3D:
		(collision_source as Node3D).visible = false

	var mesh_instances: Array[MeshInstance3D] = []
	_collect_mesh_instances(collision_source, mesh_instances)
	if mesh_instances.is_empty():
		push_warning("%s collision GLB contains no MeshInstance3D." % chunk_id)
		collision_source.queue_free()
		return 0

	var static_body: StaticBody3D = StaticBody3D.new()
	static_body.name = "StaticBody3D"
	static_body.collision_layer = TERRAIN_COLLISION_LAYER
	static_body.collision_mask = TERRAIN_COLLISION_LAYER
	collision_container.add_child(static_body)

	var shape_count: int = 0
	for mesh_instance: MeshInstance3D in mesh_instances:
		if mesh_instance.mesh == null:
			push_warning("%s collision mesh instance has no Mesh." % chunk_id)
			continue

		var shape: Shape3D = mesh_instance.mesh.create_trimesh_shape()
		if shape == null:
			push_warning("%s could not create a trimesh collision shape." % chunk_id)
			continue

		var collision_shape: CollisionShape3D = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D_%02d" % shape_count
		collision_shape.shape = shape
		collision_shape.transform = (
			static_body.global_transform.affine_inverse()
			* mesh_instance.global_transform
		)
		static_body.add_child(collision_shape)
		shape_count += 1

	collision_source.queue_free()
	if shape_count == 0:
		static_body.queue_free()

	return shape_count


func _collect_mesh_instances(
	node: Node,
	results: Array[MeshInstance3D]
) -> void:
	if node is MeshInstance3D:
		results.append(node as MeshInstance3D)

	for child_node: Node in node.get_children():
		_collect_mesh_instances(child_node, results)


func _configure_player_spawn() -> void:
	if not _chunk_records.has(_centre_chunk_id):
		push_warning(
			"TerrainChunkTest could not calculate a spawn because the centre chunk failed to load."
		)
		_safe_player_transform = _player.global_transform
		return

	var centre_record: Dictionary = _chunk_records[_centre_chunk_id]
	var bounds: Dictionary = centre_record["bounds"]
	var spawn_position: Vector3 = Vector3(
		(float(bounds["min_x"]) + float(bounds["max_x"])) * 0.5,
		float(bounds["max_y"]) + player_height_above_centre_chunk,
		(float(bounds["min_z"]) + float(bounds["max_z"])) * 0.5
	)

	_safe_player_transform = _player.global_transform
	_safe_player_transform.origin = spawn_position
	_player.global_transform = _safe_player_transform
	_player.velocity = Vector3.ZERO
	print("TerrainChunkTest player spawn: %s" % spawn_position)


func _toggle_visual_lod() -> void:
	_current_lod_index = 1 - _current_lod_index

	for record_value: Variant in _chunk_records.values():
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		var lod0_container: Node3D = record.get("lod0") as Node3D
		var lod1_container: Node3D = record.get("lod1") as Node3D
		var lod1_is_available: bool = (
			lod1_container != null and lod1_container.get_child_count() > 0
		)
		if lod0_container != null:
			lod0_container.visible = _current_lod_index == 0 or not lod1_is_available
		if lod1_container != null:
			lod1_container.visible = _current_lod_index == 1 and lod1_is_available

	print("TerrainChunkTest visual LOD changed to %s." % _current_lod_name())
	_update_debug_label()


func _on_fall_recovery_area_body_entered(body: Node3D) -> void:
	if body != _player and not body.is_in_group(PLAYER_GROUP):
		return

	var player_body: CharacterBody3D = body as CharacterBody3D
	if player_body == null:
		push_warning("TerrainChunkTest fall volume received a non-CharacterBody3D player.")
		return

	player_body.global_transform = _safe_player_transform
	player_body.velocity = Vector3.ZERO
	print("TerrainChunkTest recovered the player to the centre test chunk.")


func _on_debug_update_timer_timeout() -> void:
	_update_debug_label()


func _update_debug_label() -> void:
	if _debug_label == null:
		return

	var player_position_text: String = "Unavailable"
	if _player != null:
		var position: Vector3 = _player.global_position
		player_position_text = "(%.1f, %.1f, %.1f)" % [position.x, position.y, position.z]

	_debug_label.text = (
		"Floor 1 Terrain Chunk Import Test\n"
		+ "LOD0 loaded: %d / %d\n" % [_loaded_lod0_count, EXPECTED_CHUNK_COUNT]
		+ "LOD1 loaded: %d / %d\n" % [_loaded_lod1_count, EXPECTED_CHUNK_COUNT]
		+ "Collision loaded: %d / %d\n" % [_loaded_collision_count, EXPECTED_CHUNK_COUNT]
		+ "Current visual LOD: %s\n" % _current_lod_name()
		+ "Centre chunk: %s\n" % _centre_chunk_id
		+ "Manifest seams: %s\n" % _passed_text(_manifest_seams_passed)
		+ "Manifest status: %s\n" % _manifest_status
		+ "Player world position: %s\n" % player_position_text
		+ "F4: switch every chunk between LOD0 and LOD1"
	)


func _current_lod_name() -> String:
	if _current_lod_index == 1:
		return "LOD1"
	return "LOD0"


func _passed_text(value: bool) -> String:
	if value:
		return "PASSED"
	return "FAILED / UNAVAILABLE"


func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and not value is bool


func _is_numeric_vector3(value: Variant) -> bool:
	if not value is Array:
		return false
	var values: Array = value
	if values.size() != 3:
		return false
	return _is_number(values[0]) and _is_number(values[1]) and _is_number(values[2])


func _vector3_from_array(value: Variant) -> Vector3:
	var values: Array = value
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var terrain_node: Node = get_node_or_null(terrain_chunks_path)
	if terrain_node is Node3D:
		_terrain_chunks = terrain_node as Node3D
	else:
		push_error("TerrainChunkTest could not find TerrainChunks at: %s" % terrain_chunks_path)
		is_valid = false

	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		push_error("TerrainChunkTest could not find Player at: %s" % player_path)
		is_valid = false

	var fall_area_node: Node = get_node_or_null(fall_recovery_area_path)
	if fall_area_node is Area3D:
		_fall_recovery_area = fall_area_node as Area3D
	else:
		push_error(
			"TerrainChunkTest could not find FallRecoveryArea at: %s"
			% fall_recovery_area_path
		)
		is_valid = false

	var debug_label_node: Node = get_node_or_null(debug_label_path)
	if debug_label_node is Label:
		_debug_label = debug_label_node as Label
	else:
		push_error("TerrainChunkTest could not find DebugLabel at: %s" % debug_label_path)
		is_valid = false

	var debug_timer_node: Node = get_node_or_null(debug_timer_path)
	if debug_timer_node is Timer:
		_debug_timer = debug_timer_node as Timer
	else:
		push_error("TerrainChunkTest could not find DebugUpdateTimer at: %s" % debug_timer_path)
		is_valid = false

	return is_valid
