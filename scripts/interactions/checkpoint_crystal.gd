class_name CheckpointCrystal
extends Interactable

## Reusable primitive checkpoint that activates one PlayerRespawn location.

@export_category("Checkpoint")
@export var checkpoint_id: StringName = &"test_world_safe_zone"
@export var player_group: StringName = &"players"
@export var respawn_point_path: NodePath = NodePath("RespawnPoint")
@export_multiline var activated_message: String = "Checkpoint activated"
@export_multiline var already_active_message: String = "Checkpoint already active"

@export_category("Visual Nodes")
@export var inactive_visual_path: NodePath = NodePath("CrystalVisual/InactiveCrystal")
@export var active_visual_path: NodePath = NodePath("CrystalVisual/ActiveCrystal")
@export var status_label_path: NodePath = NodePath("StatusLabel")

var _respawn_point: Marker3D = null
var _inactive_visual: MeshInstance3D = null
var _active_visual: MeshInstance3D = null
var _status_label: Label3D = null
var _is_active: bool = false
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	set_checkpoint_active(false)
	call_deferred("_refresh_from_current_player")


func is_interaction_available(interactor: Node3D) -> bool:
	var respawn_component: PlayerRespawn = _find_player_respawn(interactor)
	return (
		_setup_is_valid
		and respawn_component != null
		and not respawn_component.is_player_dead()
		and not respawn_component.is_checkpoint_active(checkpoint_id)
	)


func get_interaction_prompt(_interactor: Node3D) -> String:
	return "Press E to activate checkpoint"


func interact(interactor: Node3D) -> String:
	var respawn_component: PlayerRespawn = _find_player_respawn(interactor)
	if respawn_component == null:
		push_error("CheckpointCrystal could not resolve PlayerRespawn on the player.")
		return "The checkpoint could not be activated."

	if respawn_component.is_checkpoint_active(checkpoint_id):
		set_checkpoint_active(true)
		return already_active_message

	if not respawn_component.activate_checkpoint(
		checkpoint_id,
		_respawn_point.global_transform
	):
		return "The checkpoint could not be activated."

	set_checkpoint_active(true)
	return activated_message


## Updates this checkpoint's primitive active/inactive presentation.
func set_checkpoint_active(is_active: bool) -> void:
	_is_active = is_active
	if _inactive_visual != null:
		_inactive_visual.visible = not _is_active
	if _active_visual != null:
		_active_visual.visible = _is_active
	if _status_label != null:
		if _is_active:
			_status_label.text = "Active Checkpoint"
		else:
			_status_label.text = "Checkpoint"


func is_active_checkpoint() -> bool:
	return _is_active


func _refresh_from_current_player() -> void:
	var player_node: Node = get_tree().get_first_node_in_group(player_group)
	var respawn_component: PlayerRespawn = _find_direct_respawn_component(player_node)
	if respawn_component == null:
		return
	set_checkpoint_active(respawn_component.is_checkpoint_active(checkpoint_id))


func _find_player_respawn(start_node: Node) -> PlayerRespawn:
	var player_root: Node = _find_player_root(start_node)
	if player_root == null:
		player_root = get_tree().get_first_node_in_group(player_group)
	return _find_direct_respawn_component(player_root)


func _find_direct_respawn_component(player_root: Node) -> PlayerRespawn:
	if player_root == null:
		return null
	for child_node: Node in player_root.get_children():
		if child_node is PlayerRespawn:
			return child_node as PlayerRespawn
	return null


func _find_player_root(start_node: Node) -> Node:
	var current_node: Node = start_node
	while current_node != null:
		if current_node.is_in_group(player_group):
			return current_node
		current_node = current_node.get_parent()
	return null


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true
	if checkpoint_id.is_empty():
		push_error("CheckpointCrystal requires a stable checkpoint_id.")
		is_valid = false

	var respawn_node: Node = get_node_or_null(respawn_point_path)
	if respawn_node is Marker3D:
		_respawn_point = respawn_node as Marker3D
	else:
		push_error("CheckpointCrystal could not find RespawnPoint at: %s" % respawn_point_path)
		is_valid = false

	var inactive_node: Node = get_node_or_null(inactive_visual_path)
	if inactive_node is MeshInstance3D:
		_inactive_visual = inactive_node as MeshInstance3D
	else:
		push_error(
			"CheckpointCrystal could not find InactiveCrystal at: %s"
			% inactive_visual_path
		)
		is_valid = false

	var active_node: Node = get_node_or_null(active_visual_path)
	if active_node is MeshInstance3D:
		_active_visual = active_node as MeshInstance3D
	else:
		push_error(
			"CheckpointCrystal could not find ActiveCrystal at: %s"
			% active_visual_path
		)
		is_valid = false

	var label_node: Node = get_node_or_null(status_label_path)
	if label_node is Label3D:
		_status_label = label_node as Label3D
	else:
		push_error("CheckpointCrystal could not find StatusLabel at: %s" % status_label_path)
		is_valid = false

	return is_valid
