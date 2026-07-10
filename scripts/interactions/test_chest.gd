class_name TestChest
extends Interactable

## One-use primitive chest that grants one configured inventory item.

@export_category("Reward")
@export var reward_item_id: StringName = &"bronze_sword"
@export_multiline var reward_obtained_message: String = "Obtained Bronze Sword"
@export_multiline var already_owned_message: String = "You already own the Bronze Sword."
@export_multiline var inventory_full_message: String = (
	"Your inventory is full. Make space and try again."
)

@export_category("Existing Chest Presentation")
@export_multiline var opened_message: String = "You opened the chest."
@export_range(0.05, 2.0, 0.05) var opening_duration_seconds: float = 0.35
@export_range(1.0, 150.0, 1.0) var lid_open_angle_degrees: float = 105.0

var _is_open: bool = false
var _lid_pivot: Node3D = null


func _ready() -> void:
	var lid_node: Node = get_node_or_null("LidPivot")
	if lid_node is Node3D:
		_lid_pivot = lid_node as Node3D
	else:
		push_error(
			"TestChest requires a Node3D child named 'LidPivot'."
		)


func is_interaction_available(_interactor: Node3D) -> bool:
	return not _is_open


func interact(interactor: Node3D) -> String:
	var result_message: String = ""

	if _is_open:
		result_message = "The chest is already open."
	else:
		var inventory: PlayerInventory = _find_player_inventory(interactor)
		if inventory == null:
			push_warning(
				"TestChest could not find PlayerInventory for the interacting player."
			)
			result_message = "The chest could not give its reward."
		elif reward_item_id.is_empty():
			push_warning("TestChest has no reward_item_id configured.")
			result_message = "The chest reward is not configured."
		elif inventory.has_item(reward_item_id):
			_is_open = true
			_open_lid()
			result_message = already_owned_message
		else:
			var added_quantity: int = inventory.add_item(reward_item_id, 1)
			if added_quantity != 1:
				result_message = inventory_full_message
			else:
				_is_open = true
				_open_lid()
				result_message = reward_obtained_message
				if result_message.is_empty():
					result_message = opened_message

	return result_message


func _find_player_inventory(interactor: Node) -> PlayerInventory:
	var player: Node = _find_player_from_node(interactor)
	if player == null:
		player = get_tree().get_first_node_in_group(&"players")

	if player == null:
		return null

	for child_node: Node in player.get_children():
		if child_node is PlayerInventory:
			return child_node as PlayerInventory

	return null


func _find_player_from_node(start_node: Node) -> Node:
	var current_node: Node = start_node
	while current_node != null:
		if current_node.is_in_group(&"players"):
			return current_node
		current_node = current_node.get_parent()

	return null


func _open_lid() -> void:
	if _lid_pivot == null:
		push_warning("The chest opened, but its lid node is missing.")
		return

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		_lid_pivot,
		"rotation:x",
		deg_to_rad(lid_open_angle_degrees),
		opening_duration_seconds
	)
