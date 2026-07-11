class_name FloorChunkStreamer
extends Node3D

# gdlint: disable=max-returns
# gdlint: disable=max-public-methods
# gdlint: disable=max-file-lines

## Reusable manifest-driven outdoor terrain chunk streamer.
##
## The streamer owns the terrain registry and runtime chunk roots. It selects
## visual LOD and collision independently from the player's floor-based grid
## coordinate, requests PackedScene resources in background threads, prevents
## duplicate requests and instances, and unloads roots outside the configured
## retention radius.

signal manifest_loaded(chunk_count: int)
signal current_chunk_changed(
	grid_coordinate: Vector2i, chunk_id: StringName, coordinate_exists: bool
)
signal streaming_state_changed
signal streaming_warning(message: String)

enum ChunkLifecycle {
	UNLOADED,
	REQUESTED,
	LOADING,
	ACTIVE,
	UNLOADING,
	FAILED,
}

enum VisualLod {
	NONE = -1,
	LOD0 = 0,
	LOD1 = 1,
}

enum ResourcePurpose {
	LOD0,
	LOD1,
	COLLISION,
}

const DEFAULT_MANIFEST_PATH: String = (
	"res://AincradProject/assets/environments/floor_001/terrain/"
	+ "test_chunks/terrain_test_manifest.json"
)
const EXPECTED_FLOOR_ID: String = "floor_001"
const EXPECTED_UNITS_PER_METRE: float = 1.0
const EXPECTED_CHUNK_SIZE_METRES: float = 256.0
const TERRAIN_COLLISION_LAYER: int = 1
const INVALID_GRID_COORDINATE: Vector2i = Vector2i(2147483647, 2147483647)

@export_category("Required Nodes")
@export_file("*.json") var manifest_path: String = DEFAULT_MANIFEST_PATH
@export var player_path: NodePath = NodePath("../Player")
@export var loaded_chunks_path: NodePath = NodePath("LoadedChunks")
@export var update_timer_path: NodePath = NodePath("StreamingUpdateTimer")

@export_category("Streaming Radii")
@export_range(0, 8, 1) var lod0_radius_chunks: int = 0
@export_range(0, 8, 1) var lod1_visual_radius_chunks: int = 1
@export_range(0, 8, 1) var collision_radius_chunks: int = 1
@export_range(0, 12, 1) var unload_radius_chunks: int = 2

@export_category("Loading")
@export_range(0.05, 2.0, 0.05) var update_interval_seconds: float = 0.20
@export_range(1, 32, 1) var maximum_new_requests_per_update: int = 6
@export var use_sub_threads: bool = false

var _player: CharacterBody3D = null
var _loaded_chunks: Node3D = null
var _update_timer: Timer = null

var _manifest_ready: bool = false
var _manifest_status: String = "Manifest not loaded"
var _manifest_seams_passed: bool = false
var _chunk_size_metres: float = 256.0
var _centre_grid_coordinate: Vector2i = Vector2i.ZERO
var _centre_chunk_id: StringName = &""

var _registry_by_grid: Dictionary = {}
var _grid_by_chunk_id: Dictionary = {}
var _active_chunks: Dictionary = {}
var _chunk_targets: Dictionary = {}

var _request_queue: Array[Dictionary] = []
var _queued_paths: Dictionary = {}
var _threaded_requests: Dictionary = {}
var _resource_cache: Dictionary = {}
var _failed_paths: Dictionary = {}

var _current_grid_coordinate: Vector2i = INVALID_GRID_COORDINATE
var _current_chunk_id: StringName = &""
var _current_coordinate_exists: bool = false
var _force_recalculation: bool = true
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_validate_exported_settings()
	_update_timer.wait_time = update_interval_seconds
	_update_timer.timeout.connect(_on_streaming_update_timer_timeout)

	var manifest: Dictionary = _load_manifest()
	if manifest.is_empty() or not _build_registry(manifest):
		return

	_manifest_ready = true
	_manifest_status = "Manifest registry ready"
	manifest_loaded.emit(_registry_by_grid.size())
	_update_timer.start()
	call_deferred("force_streaming_update")


func force_streaming_update() -> void:
	if not _setup_is_valid or not _manifest_ready:
		return

	_force_recalculation = true
	_update_streaming_cycle()


func is_manifest_ready() -> bool:
	return _manifest_ready


func get_chunk_size_metres() -> float:
	return _chunk_size_metres


func get_grid_coordinate(world_position: Vector3) -> Vector2i:
	return Vector2i(
		floori(world_position.x / _chunk_size_metres), floori(world_position.z / _chunk_size_metres)
	)


func get_current_grid_coordinate() -> Vector2i:
	return _current_grid_coordinate


func get_current_chunk_id() -> StringName:
	return _current_chunk_id


func current_coordinate_exists() -> bool:
	return _current_coordinate_exists


func has_grid_coordinate(grid_coordinate: Vector2i) -> bool:
	return _registry_by_grid.has(grid_coordinate)


func get_chunk_id_at(grid_coordinate: Vector2i) -> StringName:
	if not _registry_by_grid.has(grid_coordinate):
		return &""
	var entry: Dictionary = _registry_by_grid[grid_coordinate]
	return StringName(String(entry.get("chunk_id", "")))


func get_chunk_entry_at(grid_coordinate: Vector2i) -> Dictionary:
	if not _registry_by_grid.has(grid_coordinate):
		return {}
	var entry: Dictionary = _registry_by_grid[grid_coordinate]
	return entry.duplicate(true)


func get_centre_grid_coordinate() -> Vector2i:
	return _centre_grid_coordinate


func get_centre_chunk_id() -> StringName:
	return _centre_chunk_id


func get_spawn_position_for_chunk(
	grid_coordinate: Vector2i, height_above_chunk: float = 8.0
) -> Vector3:
	if not _registry_by_grid.has(grid_coordinate):
		return Vector3.ZERO

	var entry: Dictionary = _registry_by_grid[grid_coordinate]
	var bounds: Dictionary = entry["bounds"]
	return Vector3(
		(float(bounds["min_x"]) + float(bounds["max_x"])) * 0.5,
		float(bounds["max_y"]) + maxf(height_above_chunk, 0.5),
		(float(bounds["min_z"]) + float(bounds["max_z"])) * 0.5
	)


func get_debug_snapshot() -> Dictionary:
	var lod0_count: int = 0
	var lod1_count: int = 0
	var collision_count: int = 0
	var loaded_ids: Array[String] = []

	for record_value: Variant in _active_chunks.values():
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		var visual_lod: int = int(record.get("visual_lod", VisualLod.NONE))
		if visual_lod == VisualLod.LOD0:
			lod0_count += 1
		elif visual_lod == VisualLod.LOD1:
			lod1_count += 1
		if bool(record.get("collision_active", false)):
			collision_count += 1
		loaded_ids.append(String(record.get("chunk_id", "")))

	loaded_ids.sort()
	return {
		"manifest_ready": _manifest_ready,
		"manifest_status": _manifest_status,
		"manifest_seams_passed": _manifest_seams_passed,
		"registry_chunk_count": _registry_by_grid.size(),
		"chunk_size_metres": _chunk_size_metres,
		"player_position": _player.global_position if _player != null else Vector3.ZERO,
		"current_grid": _current_grid_coordinate,
		"current_chunk_id": _current_chunk_id,
		"current_coordinate_exists": _current_coordinate_exists,
		"loaded_chunk_count": _active_chunks.size(),
		"lod0_chunk_count": lod0_count,
		"lod1_chunk_count": lod1_count,
		"collision_chunk_count": collision_count,
		"loading_request_count": _request_queue.size() + _threaded_requests.size(),
		"failed_load_count": _failed_paths.size(),
		"loaded_chunk_ids": loaded_ids,
	}


func _on_streaming_update_timer_timeout() -> void:
	_update_streaming_cycle()


func _update_streaming_cycle() -> void:
	_poll_threaded_requests()

	if _player == null:
		return

	var player_grid: Vector2i = get_grid_coordinate(_player.global_position)
	if _force_recalculation or player_grid != _current_grid_coordinate:
		_force_recalculation = false
		_recalculate_targets(player_grid)

	_start_queued_requests()


func _recalculate_targets(player_grid: Vector2i) -> void:
	var previous_grid: Vector2i = _current_grid_coordinate
	_current_grid_coordinate = player_grid
	_current_coordinate_exists = _registry_by_grid.has(player_grid)
	_current_chunk_id = get_chunk_id_at(player_grid)

	if previous_grid != player_grid:
		current_chunk_changed.emit(
			_current_grid_coordinate, _current_chunk_id, _current_coordinate_exists
		)
		if _current_coordinate_exists:
			print(
				(
					"FloorChunkStreamer entered %s at grid %s."
					% [_current_chunk_id, _format_grid(player_grid)]
				)
			)
		else:
			_warn(
				(
					"FloorChunkStreamer player coordinate %s is outside the test manifest."
					% _format_grid(player_grid)
				)
			)

	var new_targets: Dictionary = {}
	for coordinate_value: Variant in _registry_by_grid.keys():
		var coordinate: Vector2i = coordinate_value
		var distance: int = _chebyshev_distance(coordinate, player_grid)
		var desired_lod: int = VisualLod.NONE
		if distance <= lod0_radius_chunks:
			desired_lod = VisualLod.LOD0
		elif distance <= lod1_visual_radius_chunks:
			desired_lod = VisualLod.LOD1

		var collision_required: bool = distance <= collision_radius_chunks
		new_targets[coordinate] = {
			"visual_lod": desired_lod,
			"collision": collision_required,
			"distance": distance,
		}

	_chunk_targets = new_targets
	_apply_all_targets()
	streaming_state_changed.emit()


func _apply_all_targets() -> void:
	for coordinate_value: Variant in _registry_by_grid.keys():
		var coordinate: Vector2i = coordinate_value
		var target: Dictionary = _chunk_targets.get(coordinate, {})
		var desired_lod: int = int(target.get("visual_lod", VisualLod.NONE))
		var collision_required: bool = bool(target.get("collision", false))
		var distance: int = int(target.get("distance", 999999))

		if desired_lod != VisualLod.NONE or collision_required:
			_ensure_chunk_root(coordinate)
			_ensure_visual_target(coordinate, desired_lod)
			_ensure_collision_target(coordinate, collision_required)
			continue

		if not _active_chunks.has(coordinate):
			continue

		_remove_visual(coordinate)
		_remove_collision(coordinate)
		if distance > unload_radius_chunks:
			_unload_chunk(coordinate)


func _ensure_chunk_root(coordinate: Vector2i) -> Dictionary:
	if _active_chunks.has(coordinate):
		return _active_chunks[coordinate]

	var entry: Dictionary = _registry_by_grid[coordinate]
	var chunk_id: StringName = StringName(String(entry["chunk_id"]))
	var chunk_root: Node3D = Node3D.new()
	chunk_root.name = String(chunk_id)
	chunk_root.position = _vector3_from_array(entry["global_position"])
	_loaded_chunks.add_child(chunk_root)

	var visual_container: Node3D = Node3D.new()
	visual_container.name = "Visual"
	chunk_root.add_child(visual_container)

	var collision_container: Node3D = Node3D.new()
	collision_container.name = "Collision"
	chunk_root.add_child(collision_container)

	var record: Dictionary = {
		"chunk_id": chunk_id,
		"root": chunk_root,
		"visual_container": visual_container,
		"collision_container": collision_container,
		"visual_node": null,
		"visual_lod": VisualLod.NONE,
		"collision_node": null,
		"collision_active": false,
		"lifecycle": ChunkLifecycle.UNLOADED,
	}
	_active_chunks[coordinate] = record
	return record


func _ensure_visual_target(coordinate: Vector2i, desired_lod: int) -> void:
	if desired_lod == VisualLod.NONE:
		_remove_visual(coordinate)
		return

	var record: Dictionary = _ensure_chunk_root(coordinate)
	if int(record.get("visual_lod", VisualLod.NONE)) == desired_lod:
		var current_node: Node = record.get("visual_node") as Node
		if is_instance_valid(current_node):
			return

	var entry: Dictionary = _registry_by_grid[coordinate]
	var purpose: int = ResourcePurpose.LOD0
	var path_key: String = "lod0_path"
	if desired_lod == VisualLod.LOD1:
		purpose = ResourcePurpose.LOD1
		path_key = "lod1_path"

	var resource_path: String = String(entry.get(path_key, ""))
	_request_or_apply_resource(coordinate, purpose, resource_path)


func _ensure_collision_target(coordinate: Vector2i, collision_required: bool) -> void:
	if not collision_required:
		_remove_collision(coordinate)
		return

	var record: Dictionary = _ensure_chunk_root(coordinate)
	if bool(record.get("collision_active", false)):
		var current_node: Node = record.get("collision_node") as Node
		if is_instance_valid(current_node):
			return

	var entry: Dictionary = _registry_by_grid[coordinate]
	_request_or_apply_resource(
		coordinate, ResourcePurpose.COLLISION, String(entry.get("collision_path", ""))
	)


func _request_or_apply_resource(coordinate: Vector2i, purpose: int, resource_path: String) -> void:
	if resource_path.is_empty():
		_mark_resource_failed(coordinate, purpose, resource_path, "Path is empty")
		return

	if _resource_cache.has(resource_path):
		var cached_resource: Resource = _resource_cache[resource_path] as Resource
		_apply_loaded_resource(coordinate, purpose, resource_path, cached_resource)
		return

	if _failed_paths.has(resource_path):
		return

	if _queued_paths.has(resource_path) or _threaded_requests.has(resource_path):
		return

	(
		_request_queue
		. append(
			{
				"coordinate": coordinate,
				"purpose": purpose,
				"path": resource_path,
			}
		)
	)
	_queued_paths[resource_path] = true
	_set_chunk_lifecycle(coordinate, ChunkLifecycle.REQUESTED)


func _start_queued_requests() -> void:
	var request_count: int = mini(maximum_new_requests_per_update, _request_queue.size())
	for _request_index: int in range(request_count):
		var request: Dictionary = _request_queue.pop_front()
		var resource_path: String = String(request["path"])
		_queued_paths.erase(resource_path)

		if not ResourceLoader.exists(resource_path, "PackedScene"):
			_mark_resource_failed(
				request["coordinate"],
				int(request["purpose"]),
				resource_path,
				"Resource does not exist or has not finished importing"
			)
			continue

		var request_error: Error = ResourceLoader.load_threaded_request(
			resource_path, "PackedScene", use_sub_threads
		)
		if request_error != OK and request_error != ERR_BUSY:
			_mark_resource_failed(
				request["coordinate"],
				int(request["purpose"]),
				resource_path,
				"Threaded request failed: %s" % error_string(request_error)
			)
			continue

		_threaded_requests[resource_path] = request
		_set_chunk_lifecycle(request["coordinate"], ChunkLifecycle.LOADING)

	if request_count > 0:
		streaming_state_changed.emit()


func _poll_threaded_requests() -> void:
	if _threaded_requests.is_empty():
		return

	var completed_paths: Array[String] = []
	for path_value: Variant in _threaded_requests.keys():
		var resource_path: String = String(path_value)
		var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
			resource_path
		)

		if load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue

		var request: Dictionary = _threaded_requests[resource_path]
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_resource: Resource = ResourceLoader.load_threaded_get(resource_path)
			if loaded_resource is PackedScene:
				if _request_is_still_relevant(request):
					_resource_cache[resource_path] = loaded_resource
					_apply_loaded_resource(
						request["coordinate"],
						int(request["purpose"]),
						resource_path,
						loaded_resource
					)
			else:
				_mark_resource_failed(
					request["coordinate"],
					int(request["purpose"]),
					resource_path,
					"Threaded result is not a PackedScene"
				)
		else:
			_mark_resource_failed(
				request["coordinate"],
				int(request["purpose"]),
				resource_path,
				"Threaded loading status: %s" % _thread_status_name(load_status)
			)

		completed_paths.append(resource_path)

	for resource_path: String in completed_paths:
		_threaded_requests.erase(resource_path)

	if not completed_paths.is_empty():
		streaming_state_changed.emit()


func _request_is_still_relevant(request: Dictionary) -> bool:
	var coordinate: Vector2i = request["coordinate"]
	var purpose: int = int(request["purpose"])
	var target: Dictionary = _chunk_targets.get(coordinate, {})
	if purpose == ResourcePurpose.LOD0:
		return int(target.get("visual_lod", VisualLod.NONE)) == VisualLod.LOD0
	if purpose == ResourcePurpose.LOD1:
		return int(target.get("visual_lod", VisualLod.NONE)) == VisualLod.LOD1
	if purpose == ResourcePurpose.COLLISION:
		return bool(target.get("collision", false))
	return false


func _apply_loaded_resource(
	coordinate: Vector2i, purpose: int, resource_path: String, loaded_resource: Resource
) -> void:
	if not loaded_resource is PackedScene:
		_mark_resource_failed(
			coordinate, purpose, resource_path, "Loaded resource is not a PackedScene"
		)
		return

	var target: Dictionary = _chunk_targets.get(coordinate, {})
	if purpose == ResourcePurpose.LOD0:
		if int(target.get("visual_lod", VisualLod.NONE)) != VisualLod.LOD0:
			return
		_install_visual(coordinate, loaded_resource as PackedScene, VisualLod.LOD0)
	elif purpose == ResourcePurpose.LOD1:
		if int(target.get("visual_lod", VisualLod.NONE)) != VisualLod.LOD1:
			return
		_install_visual(coordinate, loaded_resource as PackedScene, VisualLod.LOD1)
	elif purpose == ResourcePurpose.COLLISION:
		if not bool(target.get("collision", false)):
			return
		_install_collision(coordinate, loaded_resource as PackedScene)


func _install_visual(coordinate: Vector2i, packed_scene: PackedScene, visual_lod: int) -> void:
	var record: Dictionary = _ensure_chunk_root(coordinate)
	_remove_visual(coordinate)

	var visual_container: Node3D = record["visual_container"] as Node3D
	var visual_instance: Node = packed_scene.instantiate()
	visual_instance.name = "LOD0" if visual_lod == VisualLod.LOD0 else "LOD1"
	visual_container.add_child(visual_instance)
	record["visual_node"] = visual_instance
	record["visual_lod"] = visual_lod
	record["lifecycle"] = ChunkLifecycle.ACTIVE
	_active_chunks[coordinate] = record

	print(
		(
			"FloorChunkStreamer activated %s for %s."
			% [_visual_lod_name(visual_lod), record["chunk_id"]]
		)
	)


func _install_collision(coordinate: Vector2i, packed_scene: PackedScene) -> void:
	var entry: Dictionary = _registry_by_grid[coordinate]
	var collision_path: String = String(entry["collision_path"])
	var record: Dictionary = _ensure_chunk_root(coordinate)
	_remove_collision(coordinate)

	var collision_container: Node3D = record["collision_container"] as Node3D
	var collision_source: Node = packed_scene.instantiate()
	collision_source.name = "CollisionSource"
	collision_container.add_child(collision_source)
	if collision_source is Node3D:
		(collision_source as Node3D).visible = false

	var mesh_instances: Array[MeshInstance3D] = []
	_collect_mesh_instances(collision_source, mesh_instances)
	if mesh_instances.is_empty():
		collision_container.remove_child(collision_source)
		collision_source.queue_free()
		_mark_resource_failed(
			coordinate,
			ResourcePurpose.COLLISION,
			collision_path,
			"Collision scene contains no MeshInstance3D"
		)
		return

	var static_body: StaticBody3D = StaticBody3D.new()
	static_body.name = "StaticBody3D"
	static_body.collision_layer = TERRAIN_COLLISION_LAYER
	static_body.collision_mask = TERRAIN_COLLISION_LAYER
	collision_container.add_child(static_body)

	var shape_count: int = 0
	for mesh_instance: MeshInstance3D in mesh_instances:
		if mesh_instance.mesh == null:
			continue

		var shape: Shape3D = mesh_instance.mesh.create_trimesh_shape()
		if shape == null:
			continue

		var collision_shape: CollisionShape3D = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D_%02d" % shape_count
		collision_shape.shape = shape
		collision_shape.transform = (
			static_body.global_transform.affine_inverse() * mesh_instance.global_transform
		)
		static_body.add_child(collision_shape)
		shape_count += 1

	collision_container.remove_child(collision_source)
	collision_source.queue_free()
	if shape_count == 0:
		collision_container.remove_child(static_body)
		static_body.queue_free()
		_mark_resource_failed(
			coordinate,
			ResourcePurpose.COLLISION,
			collision_path,
			"No trimesh collision shapes could be created"
		)
		return

	record["collision_node"] = static_body
	record["collision_active"] = true
	record["lifecycle"] = ChunkLifecycle.ACTIVE
	_active_chunks[coordinate] = record
	print(
		(
			"FloorChunkStreamer activated collision for %s with %d shape(s)."
			% [record["chunk_id"], shape_count]
		)
	)


func _remove_visual(coordinate: Vector2i) -> void:
	if not _active_chunks.has(coordinate):
		return
	var record: Dictionary = _active_chunks[coordinate]
	var previous_lod: int = int(record.get("visual_lod", VisualLod.NONE))
	if _registry_by_grid.has(coordinate):
		var entry: Dictionary = _registry_by_grid[coordinate]
		if previous_lod == VisualLod.LOD0:
			_resource_cache.erase(String(entry.get("lod0_path", "")))
		elif previous_lod == VisualLod.LOD1:
			_resource_cache.erase(String(entry.get("lod1_path", "")))
	var visual_node: Node = record.get("visual_node") as Node
	if is_instance_valid(visual_node):
		var parent_node: Node = visual_node.get_parent()
		if parent_node != null:
			parent_node.remove_child(visual_node)
		visual_node.queue_free()
	record["visual_node"] = null
	record["visual_lod"] = VisualLod.NONE
	_active_chunks[coordinate] = record


func _remove_collision(coordinate: Vector2i) -> void:
	if not _active_chunks.has(coordinate):
		return
	var record: Dictionary = _active_chunks[coordinate]
	if _registry_by_grid.has(coordinate):
		var entry: Dictionary = _registry_by_grid[coordinate]
		_resource_cache.erase(String(entry.get("collision_path", "")))
	var collision_node: Node = record.get("collision_node") as Node
	if is_instance_valid(collision_node):
		var parent_node: Node = collision_node.get_parent()
		if parent_node != null:
			parent_node.remove_child(collision_node)
		collision_node.queue_free()
	record["collision_node"] = null
	record["collision_active"] = false
	_active_chunks[coordinate] = record


func _unload_chunk(coordinate: Vector2i) -> void:
	if not _active_chunks.has(coordinate):
		return

	var record: Dictionary = _active_chunks[coordinate]
	record["lifecycle"] = ChunkLifecycle.UNLOADING
	_cancel_queued_requests_for_coordinate(coordinate)
	_remove_visual(coordinate)
	_remove_collision(coordinate)

	var chunk_root: Node = record.get("root") as Node
	if is_instance_valid(chunk_root):
		var parent_node: Node = chunk_root.get_parent()
		if parent_node != null:
			parent_node.remove_child(chunk_root)
		chunk_root.queue_free()

	_active_chunks.erase(coordinate)
	print("FloorChunkStreamer unloaded chunk at grid %s." % _format_grid(coordinate))


func _cancel_queued_requests_for_coordinate(coordinate: Vector2i) -> void:
	var retained_queue: Array[Dictionary] = []
	for request: Dictionary in _request_queue:
		if request.get("coordinate") == coordinate:
			_queued_paths.erase(String(request.get("path", "")))
			continue
		retained_queue.append(request)
	_request_queue = retained_queue


func _set_chunk_lifecycle(coordinate: Vector2i, lifecycle: int) -> void:
	if not _active_chunks.has(coordinate):
		return
	var record: Dictionary = _active_chunks[coordinate]
	record["lifecycle"] = lifecycle
	_active_chunks[coordinate] = record


func _mark_resource_failed(
	coordinate: Vector2i, purpose: int, resource_path: String, reason: String
) -> void:
	var failure_key: String = resource_path
	if failure_key.is_empty():
		failure_key = "%s:%d" % [_format_grid(coordinate), purpose]
	_failed_paths[failure_key] = reason
	_set_chunk_lifecycle(coordinate, ChunkLifecycle.FAILED)
	_warn(
		(
			"FloorChunkStreamer failed %s for grid %s: %s. Path: %s"
			% [
				_resource_purpose_name(purpose),
				_format_grid(coordinate),
				reason,
				resource_path,
			]
		)
	)


func _load_manifest() -> Dictionary:
	if not FileAccess.file_exists(manifest_path):
		_manifest_status = "Manifest missing"
		_warn("FloorChunkStreamer could not find manifest: %s" % manifest_path)
		return {}

	var manifest_file: FileAccess = FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null:
		_manifest_status = "Manifest could not be opened"
		_warn(
			(
				"FloorChunkStreamer could not open manifest: %s"
				% error_string(FileAccess.get_open_error())
			)
		)
		return {}

	var manifest_text: String = manifest_file.get_as_text()
	var read_error: Error = manifest_file.get_error()
	manifest_file.close()
	if read_error != OK:
		_manifest_status = "Manifest read failed"
		_warn("FloorChunkStreamer manifest read failed: %s" % error_string(read_error))
		return {}

	if manifest_text.strip_edges().is_empty():
		_manifest_status = "Manifest is empty"
		_warn("FloorChunkStreamer manifest is empty.")
		return {}

	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(manifest_text)
	if parse_error != OK:
		_manifest_status = "Manifest JSON is invalid"
		_warn(
			(
				"FloorChunkStreamer JSON error at line %d: %s"
				% [parser.get_error_line(), parser.get_error_message()]
			)
		)
		return {}

	if not parser.data is Dictionary:
		_manifest_status = "Manifest root is not an object"
		_warn("FloorChunkStreamer expected a Dictionary at the JSON root.")
		return {}

	return parser.data


func _build_registry(manifest: Dictionary) -> bool:
	if String(manifest.get("floor_id", "")) != EXPECTED_FLOOR_ID:
		_manifest_status = "Unexpected floor ID"
		_warn("FloorChunkStreamer manifest floor_id must be floor_001.")
		return false

	if not _is_number(manifest.get("units_per_metre")):
		_manifest_status = "Missing unit scale"
		_warn("FloorChunkStreamer manifest is missing units_per_metre.")
		return false
	if not is_equal_approx(float(manifest["units_per_metre"]), EXPECTED_UNITS_PER_METRE):
		_manifest_status = "Incorrect unit scale"
		_warn("FloorChunkStreamer requires one Godot unit per metre.")
		return false

	if not _is_number(manifest.get("chunk_size_m")):
		_manifest_status = "Missing chunk size"
		_warn("FloorChunkStreamer manifest is missing chunk_size_m.")
		return false
	_chunk_size_metres = float(manifest["chunk_size_m"])
	if not is_equal_approx(_chunk_size_metres, EXPECTED_CHUNK_SIZE_METRES):
		_manifest_status = "Unexpected chunk size"
		_warn("FloorChunkStreamer expected 256 m chunks but found %.3f m." % _chunk_size_metres)
		return false

	var chunks_value: Variant = manifest.get("chunks")
	if not chunks_value is Array or (chunks_value as Array).is_empty():
		_manifest_status = "Chunk list is missing"
		_warn("FloorChunkStreamer manifest chunks must be a non-empty Array.")
		return false

	_registry_by_grid.clear()
	_grid_by_chunk_id.clear()
	for entry_value: Variant in chunks_value as Array:
		if not entry_value is Dictionary:
			_warn("FloorChunkStreamer skipped a non-Dictionary chunk entry.")
			continue
		var entry: Dictionary = entry_value
		if not _validate_registry_entry(entry):
			continue

		var grid: Dictionary = entry["grid_coordinates"]
		var coordinate: Vector2i = Vector2i(int(grid["x"]), int(grid["z"]))
		var chunk_id: StringName = StringName(String(entry["chunk_id"]))
		if _registry_by_grid.has(coordinate):
			_warn(
				(
					"FloorChunkStreamer duplicate grid coordinate %s was skipped."
					% _format_grid(coordinate)
				)
			)
			continue
		if _grid_by_chunk_id.has(chunk_id):
			_warn("FloorChunkStreamer duplicate chunk ID %s was skipped." % chunk_id)
			continue

		_registry_by_grid[coordinate] = entry.duplicate(true)
		_grid_by_chunk_id[chunk_id] = coordinate

	if _registry_by_grid.is_empty():
		_manifest_status = "No valid chunk entries"
		_warn("FloorChunkStreamer found no valid chunks in the manifest.")
		return false

	var test_grid_value: Variant = manifest.get("test_grid")
	if test_grid_value is Dictionary:
		var test_grid: Dictionary = test_grid_value
		var centre_value: Variant = test_grid.get("centre_chunk")
		if centre_value is Dictionary:
			var centre_data: Dictionary = centre_value
			if _is_number(centre_data.get("x")) and _is_number(centre_data.get("z")):
				_centre_grid_coordinate = Vector2i(int(centre_data["x"]), int(centre_data["z"]))
				_centre_chunk_id = StringName(String(centre_data.get("chunk_id", "")))

	if not _registry_by_grid.has(_centre_grid_coordinate):
		_centre_grid_coordinate = _registry_by_grid.keys()[0]
		_centre_chunk_id = get_chunk_id_at(_centre_grid_coordinate)

	var seam_value: Variant = manifest.get("seam_validation")
	_manifest_seams_passed = false
	if seam_value is Dictionary:
		var seam_data: Dictionary = seam_value
		_manifest_seams_passed = bool(seam_data.get("passed", false))
	if not _manifest_seams_passed:
		_warn("FloorChunkStreamer manifest reports failed or missing seam validation.")

	print(
		(
			"FloorChunkStreamer registry built: %d chunks, %.1f m cells, centre %s."
			% [_registry_by_grid.size(), _chunk_size_metres, _centre_chunk_id]
		)
	)
	return true


func _validate_registry_entry(entry: Dictionary) -> bool:
	var chunk_id: String = String(entry.get("chunk_id", ""))
	if chunk_id.is_empty():
		_warn("FloorChunkStreamer skipped an entry without chunk_id.")
		return false

	var grid_value: Variant = entry.get("grid_coordinates")
	if not grid_value is Dictionary:
		_warn("%s is missing grid_coordinates." % chunk_id)
		return false
	var grid: Dictionary = grid_value
	if not _is_number(grid.get("x")) or not _is_number(grid.get("z")):
		_warn("%s has invalid grid coordinates." % chunk_id)
		return false

	if not _is_numeric_vector3(entry.get("global_position")):
		_warn("%s has an invalid global_position." % chunk_id)
		return false

	var coordinate: Vector2i = Vector2i(int(grid["x"]), int(grid["z"]))
	var expected_position: Vector3 = Vector3(
		float(coordinate.x) * _chunk_size_metres, 0.0, float(coordinate.y) * _chunk_size_metres
	)
	var manifest_position: Vector3 = _vector3_from_array(entry["global_position"])
	if not manifest_position.is_equal_approx(expected_position):
		_warn(
			(
				"%s position %s does not match grid position %s."
				% [chunk_id, manifest_position, expected_position]
			)
		)
		return false

	var bounds_value: Variant = entry.get("bounds")
	if not bounds_value is Dictionary:
		_warn("%s has no bounds object." % chunk_id)
		return false
	var bounds: Dictionary = bounds_value
	for key: String in ["min_x", "max_x", "min_y", "max_y", "min_z", "max_z"]:
		if not _is_number(bounds.get(key)):
			_warn("%s has invalid bounds.%s." % [chunk_id, key])
			return false

	if (
		not is_equal_approx(float(bounds["max_x"]) - float(bounds["min_x"]), _chunk_size_metres)
		or not is_equal_approx(float(bounds["max_z"]) - float(bounds["min_z"]), _chunk_size_metres)
	):
		_warn("%s does not cover exactly one chunk footprint." % chunk_id)
		return false

	for path_key: String in ["lod0_path", "lod1_path", "collision_path"]:
		if String(entry.get(path_key, "")).is_empty():
			_warn("%s is missing %s." % [chunk_id, path_key])
			return false

	return true


func _validate_exported_settings() -> void:
	lod0_radius_chunks = maxi(lod0_radius_chunks, 0)
	lod1_visual_radius_chunks = maxi(lod1_visual_radius_chunks, lod0_radius_chunks)
	collision_radius_chunks = maxi(collision_radius_chunks, 0)
	unload_radius_chunks = maxi(
		unload_radius_chunks, maxi(lod1_visual_radius_chunks, collision_radius_chunks)
	)
	update_interval_seconds = maxf(update_interval_seconds, 0.05)
	maximum_new_requests_per_update = maxi(maximum_new_requests_per_update, 1)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true
	var player_node: Node = get_node_or_null(player_path)
	if player_node is CharacterBody3D:
		_player = player_node as CharacterBody3D
	else:
		push_error("FloorChunkStreamer could not find Player at: %s" % player_path)
		is_valid = false

	var loaded_chunks_node: Node = get_node_or_null(loaded_chunks_path)
	if loaded_chunks_node is Node3D:
		_loaded_chunks = loaded_chunks_node as Node3D
	else:
		push_error("FloorChunkStreamer could not find LoadedChunks at: %s" % loaded_chunks_path)
		is_valid = false

	var timer_node: Node = get_node_or_null(update_timer_path)
	if timer_node is Timer:
		_update_timer = timer_node as Timer
	else:
		push_error("FloorChunkStreamer could not find Timer at: %s" % update_timer_path)
		is_valid = false

	return is_valid


func _collect_mesh_instances(node: Node, results: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		results.append(node as MeshInstance3D)
	for child_node: Node in node.get_children():
		_collect_mesh_instances(child_node, results)


func _chebyshev_distance(first: Vector2i, second: Vector2i) -> int:
	return maxi(absi(first.x - second.x), absi(first.y - second.y))


func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and not value is bool


func _is_numeric_vector3(value: Variant) -> bool:
	if not value is Array:
		return false
	var values: Array = value
	return (
		values.size() == 3
		and _is_number(values[0])
		and _is_number(values[1])
		and _is_number(values[2])
	)


func _vector3_from_array(value: Variant) -> Vector3:
	var values: Array = value
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _format_grid(coordinate: Vector2i) -> String:
	return "(%+d, %+d)" % [coordinate.x, coordinate.y]


func _visual_lod_name(visual_lod: int) -> String:
	if visual_lod == VisualLod.LOD0:
		return "LOD0"
	if visual_lod == VisualLod.LOD1:
		return "LOD1"
	return "None"


func _resource_purpose_name(purpose: int) -> String:
	if purpose == ResourcePurpose.LOD0:
		return "LOD0"
	if purpose == ResourcePurpose.LOD1:
		return "LOD1"
	if purpose == ResourcePurpose.COLLISION:
		return "collision"
	return "unknown resource"


func _thread_status_name(status: ResourceLoader.ThreadLoadStatus) -> String:
	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			return "invalid resource"
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return "in progress"
		ResourceLoader.THREAD_LOAD_FAILED:
			return "failed"
		ResourceLoader.THREAD_LOAD_LOADED:
			return "loaded"
	return "unknown"


func _warn(message: String) -> void:
	push_warning(message)
	streaming_warning.emit(message)
