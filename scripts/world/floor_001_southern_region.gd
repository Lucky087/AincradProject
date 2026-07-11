class_name Floor001SouthernRegion
extends Node3D

# gdlint: disable=max-returns

## Permanent production shell for the real southern region of Floor 1.
##
## This scene owns regional terrain streaming, environment, stable markers,
## safe-zone data, content containers, and boundary hooks. It deliberately does
## not own player progression, inventory, global quests, SaveManager, or menus.

signal region_configuration_ready(region_id: StringName)
signal region_configuration_failed(message: String)
signal safe_zone_entered(safe_zone_id: StringName, body: Node3D)
signal safe_zone_exited(safe_zone_id: StringName, body: Node3D)

const DEFAULT_CONFIGURATION_PATH: String = (
	"res://AincradProject/data/floors/floor_001_southern_region.json"
)
const EXPECTED_REGION_ID: StringName = &"region_floor_001_southern"
const EXPECTED_FLOOR_ID: String = "floor_001"
const EXPECTED_DATASET_ID: String = "floor_001_southern_region_v1"
const POSITION_TOLERANCE_METRES: float = 0.05

@export_category("Region Data")
@export_file("*.json") var configuration_path: String = DEFAULT_CONFIGURATION_PATH

@export_category("Required Nodes")
@export var terrain_streamer_path: NodePath = NodePath("Terrain/TerrainStreamer")
@export var safe_zone_area_path: NodePath = NodePath("SafeZones/StartingCityGateSafeZone")
@export var safe_zone_shape_path: NodePath = NodePath(
	"SafeZones/StartingCityGateSafeZone/CollisionShape3D"
)
@export var spawn_markers_path: NodePath = NodePath("SpawnMarkers")
@export var landmark_markers_path: NodePath = NodePath("LandmarkMarkers")
@export var streaming_markers_path: NodePath = NodePath("StreamingMarkers")
@export var region_metadata_path: NodePath = NodePath("RegionMetadata")

var _configuration: Dictionary = {}
var _terrain_streamer: FloorChunkStreamer = null
var _safe_zone_area: Area3D = null
var _safe_zone_shape: CollisionShape3D = null
var _region_metadata: Node = null
var _markers_by_id: Dictionary = {}
var _safe_zone_body_ids: Dictionary = {}
var _safe_zone_id: StringName = &""
var _region_id: StringName = &""
var _configuration_ready: bool = false


func _ready() -> void:
	if not _resolve_required_nodes():
		_report_configuration_failure("Required production-region nodes are missing.")
		return

	_configuration = _load_json_dictionary(configuration_path)
	if _configuration.is_empty():
		_report_configuration_failure("Region configuration could not be loaded.")
		return

	if not _register_stable_markers():
		_report_configuration_failure("Stable marker registration failed.")
		return
	if not _validate_configuration():
		return
	if not _configure_safe_zone_from_data():
		return

	_safe_zone_area.body_entered.connect(_on_safe_zone_body_entered)
	_safe_zone_area.body_exited.connect(_on_safe_zone_body_exited)
	_region_id = StringName(String(_configuration.get("region_id", "")))
	_region_metadata.set_meta("region_id", _region_id)
	_region_metadata.set_meta("floor_id", String(_configuration.get("floor_id", "")))
	_region_metadata.set_meta(
		"terrain_dataset_id", String(_configuration.get("terrain_dataset_id", ""))
	)
	_configuration_ready = true
	region_configuration_ready.emit(_region_id)


func is_configuration_ready() -> bool:
	return _configuration_ready


func get_region_id() -> StringName:
	return _region_id


func get_configuration() -> Dictionary:
	return _configuration.duplicate(true)


func get_terrain_streamer() -> FloorChunkStreamer:
	return _terrain_streamer


func assign_streaming_target(target: Node3D) -> void:
	if _terrain_streamer == null:
		push_error("Floor001SouthernRegion cannot assign a target before setup.")
		return
	_terrain_streamer.set_streaming_target(target)


func get_marker(marker_id: StringName) -> Marker3D:
	if not _markers_by_id.has(marker_id):
		return null
	var marker: Marker3D = _markers_by_id[marker_id] as Marker3D
	return marker if is_instance_valid(marker) else null


func get_player_spawn_marker() -> Marker3D:
	var marker_id: StringName = StringName(String(_configuration.get("player_spawn_marker_id", "")))
	return get_marker(marker_id)


func get_checkpoint_marker() -> Marker3D:
	var marker_id: StringName = StringName(String(_configuration.get("checkpoint_marker_id", "")))
	return get_marker(marker_id)


func get_safe_zone_id() -> StringName:
	return _safe_zone_id


func is_body_inside_safe_zone(body: Node3D) -> bool:
	if body == null:
		return false
	return _safe_zone_body_ids.has(body.get_instance_id())


func is_position_inside_safe_zone(world_position: Vector3) -> bool:
	if _configuration.is_empty():
		return false
	var safe_zone_value: Variant = _configuration.get("safe_zone", {})
	if not safe_zone_value is Dictionary:
		return false
	var safe_zone: Dictionary = safe_zone_value
	var centre: Vector3 = _vector3_from_array(safe_zone.get("centre", []))
	var radius: float = float(safe_zone.get("radius_m", 0.0))
	var height: float = float(safe_zone.get("height_m", 0.0))
	var horizontal_delta: Vector2 = Vector2(
		world_position.x - centre.x, world_position.z - centre.z
	)
	return horizontal_delta.length() <= radius and absf(world_position.y - centre.y) <= height * 0.5


func contains_horizontal_position(world_position: Vector3) -> bool:
	var bounds_value: Variant = _configuration.get("region_bounds", {})
	if not bounds_value is Dictionary:
		return false
	var bounds: Dictionary = bounds_value
	var minimum: Vector3 = _vector3_from_array(bounds.get("min", []))
	var maximum: Vector3 = _vector3_from_array(bounds.get("max", []))
	return (
		world_position.x >= minimum.x
		and world_position.x <= maximum.x
		and world_position.z >= minimum.z
		and world_position.z <= maximum.z
	)


func _resolve_required_nodes() -> bool:
	var valid: bool = true
	var streamer_node: Node = get_node_or_null(terrain_streamer_path)
	if streamer_node is FloorChunkStreamer:
		_terrain_streamer = streamer_node as FloorChunkStreamer
	else:
		push_error("Floor001SouthernRegion could not find TerrainStreamer.")
		valid = false

	var safe_zone_node: Node = get_node_or_null(safe_zone_area_path)
	if safe_zone_node is Area3D:
		_safe_zone_area = safe_zone_node as Area3D
	else:
		push_error("Floor001SouthernRegion could not find the safe-zone Area3D.")
		valid = false

	var safe_shape_node: Node = get_node_or_null(safe_zone_shape_path)
	if safe_shape_node is CollisionShape3D:
		_safe_zone_shape = safe_shape_node as CollisionShape3D
	else:
		push_error("Floor001SouthernRegion could not find the safe-zone shape.")
		valid = false

	_region_metadata = get_node_or_null(region_metadata_path)
	if _region_metadata == null:
		push_error("Floor001SouthernRegion could not find RegionMetadata.")
		valid = false

	for path: NodePath in [spawn_markers_path, landmark_markers_path, streaming_markers_path]:
		if get_node_or_null(path) == null:
			push_error("Floor001SouthernRegion could not find marker container: %s" % path)
			valid = false
	return valid


func _register_stable_markers() -> bool:
	_markers_by_id.clear()
	var containers: Array[Node] = []
	for path: NodePath in [spawn_markers_path, landmark_markers_path, streaming_markers_path]:
		var container: Node = get_node_or_null(path)
		if container != null:
			containers.append(container)

	var valid: bool = true
	for container: Node in containers:
		for child: Node in container.get_children():
			if not child is Marker3D:
				continue
			var marker: Marker3D = child as Marker3D
			var stable_id_text: String = String(marker.get_meta("stable_id", ""))
			if stable_id_text.is_empty():
				push_error("Marker %s is missing stable_id metadata." % marker.get_path())
				valid = false
				continue
			var stable_id: StringName = StringName(stable_id_text)
			if _markers_by_id.has(stable_id):
				push_error("Duplicate stable marker ID: %s" % stable_id_text)
				valid = false
				continue
			_markers_by_id[stable_id] = marker
	return valid


func _validate_configuration() -> bool:
	if StringName(String(_configuration.get("region_id", ""))) != EXPECTED_REGION_ID:
		return _configuration_error("Unexpected stable region ID.")
	if String(_configuration.get("floor_id", "")) != EXPECTED_FLOOR_ID:
		return _configuration_error("Unexpected Floor ID.")
	if String(_configuration.get("terrain_dataset_id", "")) != EXPECTED_DATASET_ID:
		return _configuration_error("Unexpected terrain dataset ID.")
	if not is_equal_approx(float(_configuration.get("chunk_size_m", 0.0)), 256.0):
		return _configuration_error("Region chunk size must be 256 metres.")

	var manifest_path: String = String(_configuration.get("terrain_manifest_path", ""))
	if manifest_path != _terrain_streamer.manifest_path:
		return _configuration_error("Region JSON and TerrainStreamer manifest paths differ.")
	if not FileAccess.file_exists(manifest_path):
		return _configuration_error("Southern terrain manifest is missing.")

	var marker_definitions: Array = []
	for key: String in ["spawn_markers", "landmark_markers"]:
		var definitions_value: Variant = _configuration.get(key, [])
		if not definitions_value is Array:
			return _configuration_error("%s must be an array." % key)
		for definition_value: Variant in definitions_value:
			marker_definitions.append(definition_value)

	for definition_value: Variant in marker_definitions:
		if not definition_value is Dictionary:
			return _configuration_error("Marker definition is not a dictionary.")
		var definition: Dictionary = definition_value
		var marker_id: StringName = StringName(String(definition.get("marker_id", "")))
		var marker: Marker3D = get_marker(marker_id)
		if marker == null:
			return _configuration_error("Configuration marker is missing: %s" % marker_id)
		var expected_position: Vector3 = _vector3_from_array(definition.get("position", []))
		if marker.position.distance_to(expected_position) > POSITION_TOLERANCE_METRES:
			return _configuration_error("Marker position differs from JSON: %s" % String(marker_id))

	var required_spawn_id: StringName = StringName(
		String(_configuration.get("player_spawn_marker_id", ""))
	)
	var required_checkpoint_id: StringName = StringName(
		String(_configuration.get("checkpoint_marker_id", ""))
	)
	if get_marker(required_spawn_id) == null or get_marker(required_checkpoint_id) == null:
		return _configuration_error("Required fallback markers are missing.")
	return true


func _configure_safe_zone_from_data() -> bool:
	var safe_zone_value: Variant = _configuration.get("safe_zone", {})
	if not safe_zone_value is Dictionary:
		return _configuration_error("Safe-zone configuration is missing.")
	var safe_zone: Dictionary = safe_zone_value
	_safe_zone_id = StringName(String(safe_zone.get("safe_zone_id", "")))
	if _safe_zone_id == &"":
		return _configuration_error("Safe zone has no stable ID.")
	var centre: Vector3 = _vector3_from_array(safe_zone.get("centre", []))
	var radius: float = float(safe_zone.get("radius_m", 0.0))
	var height: float = float(safe_zone.get("height_m", 0.0))
	if radius <= 0.0 or height <= 0.0:
		return _configuration_error("Safe-zone dimensions must be positive.")
	if not _safe_zone_shape.shape is CylinderShape3D:
		return _configuration_error("Safe-zone collision must use CylinderShape3D.")

	_safe_zone_area.position = centre
	_safe_zone_area.set_meta("safe_zone_id", _safe_zone_id)
	var cylinder: CylinderShape3D = _safe_zone_shape.shape as CylinderShape3D
	cylinder.radius = radius
	cylinder.height = height
	return true


func _on_safe_zone_body_entered(body: Node3D) -> void:
	_safe_zone_body_ids[body.get_instance_id()] = true
	safe_zone_entered.emit(_safe_zone_id, body)


func _on_safe_zone_body_exited(body: Node3D) -> void:
	_safe_zone_body_ids.erase(body.get_instance_id())
	safe_zone_exited.emit(_safe_zone_id, body)


func _load_json_dictionary(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		push_error("Floor001SouthernRegion JSON does not exist: %s" % path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Floor001SouthernRegion could not open JSON: %s" % path)
		return {}
	var parser: JSON = JSON.new()
	var error: Error = parser.parse(file.get_as_text())
	if error != OK:
		push_error(
			(
				"Floor001SouthernRegion JSON parse failed at line %d: %s"
				% [parser.get_error_line(), parser.get_error_message()]
			)
		)
		return {}
	if not parser.data is Dictionary:
		push_error("Floor001SouthernRegion expected a dictionary JSON root.")
		return {}
	return parser.data as Dictionary


func _vector3_from_array(value: Variant) -> Vector3:
	if not value is Array:
		return Vector3.ZERO
	var values: Array = value
	if values.size() != 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _configuration_error(message: String) -> bool:
	_report_configuration_failure(message)
	return false


func _report_configuration_failure(message: String) -> void:
	push_error("Floor001SouthernRegion: %s" % message)
	region_configuration_failed.emit(message)
