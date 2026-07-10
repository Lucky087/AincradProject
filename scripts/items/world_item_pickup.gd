class_name WorldItemPickup
extends Area3D

## Temporary world pickup that adds one stable item ID to a player's inventory.
##
## Pickups are intentionally not saved. Any active pickup removes itself after a
## successful game load so transient enemy drops cannot survive save restoration.

@export_category("Item")
@export var item_id: StringName = &"boar_tusk"
@export_range(1, 999, 1) var quantity: int = 1

@export_category("Collection")
@export var player_group: StringName = &"players"

@export_category("Required Nodes")
@export var item_label_path: NodePath = NodePath("ItemLabel")

var _item_label: Label3D = null
var _intended_player: Node = null
var _is_collecting: bool = false
var _setup_is_valid: bool = false


## Configures the drop before it enters the scene tree.
func configure_pickup(
	configured_item_id: StringName,
	configured_quantity: int,
	intended_player: Node
) -> void:
	item_id = configured_item_id
	quantity = maxi(configured_quantity, 1)
	_intended_player = intended_player


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		monitoring = false
		return

	body_entered.connect(_on_body_entered)
	_connect_to_save_manager()
	_refresh_label()


func _on_body_entered(body: Node3D) -> void:
	if _is_collecting or quantity <= 0:
		return

	var player_root: Node = _find_player_root(body)
	if player_root == null:
		return

	if is_instance_valid(_intended_player) and player_root != _intended_player:
		return

	var inventory: PlayerInventory = _find_player_inventory(player_root)
	if inventory == null:
		push_warning("WorldItemPickup found a player without PlayerInventory.")
		return

	_is_collecting = true
	var added_quantity: int = inventory.add_item(item_id, quantity)
	if added_quantity <= 0:
		_is_collecting = false
		_refresh_label("Inventory full")
		return

	quantity -= added_quantity
	if quantity <= 0:
		queue_free()
		return

	_is_collecting = false
	_refresh_label()


func _on_game_loaded(_save_path: String) -> void:
	queue_free()


func _refresh_label(temporary_message: String = "") -> void:
	if _item_label == null:
		return

	if not temporary_message.is_empty():
		_item_label.text = temporary_message
		return

	var display_name: String = String(item_id).capitalize()
	var inventory: PlayerInventory = _find_player_inventory(_intended_player)
	if inventory != null:
		var definition: ItemDefinition = inventory.get_item_definition(item_id)
		if definition != null:
			display_name = definition.display_name

	_item_label.text = display_name
	if quantity > 1:
		_item_label.text += " x%d" % quantity


func _connect_to_save_manager() -> void:
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if save_manager == null:
		push_warning("WorldItemPickup could not find SaveManager; load cleanup is unavailable.")
		return

	if not save_manager.has_signal("load_completed"):
		push_warning("WorldItemPickup found SaveManager without load_completed signal.")
		return

	var callback: Callable = Callable(self, "_on_game_loaded")
	if not save_manager.is_connected("load_completed", callback):
		save_manager.connect("load_completed", callback)


func _find_player_root(start_node: Node) -> Node:
	var current_node: Node = start_node
	while current_node != null:
		if current_node.is_in_group(player_group):
			return current_node
		current_node = current_node.get_parent()
	return null


func _find_player_inventory(player_root: Node) -> PlayerInventory:
	if player_root == null or not is_instance_valid(player_root):
		return null

	for child_node: Node in player_root.get_children():
		if child_node is PlayerInventory:
			return child_node as PlayerInventory
	return null


func _resolve_required_nodes() -> bool:
	if item_id.is_empty():
		push_error("WorldItemPickup has no item_id configured.")
		return false

	var label_node: Node = get_node_or_null(item_label_path)
	if label_node is Label3D:
		_item_label = label_node as Label3D
	else:
		push_error("WorldItemPickup could not find ItemLabel at: %s" % item_label_path)
		return false

	return true
