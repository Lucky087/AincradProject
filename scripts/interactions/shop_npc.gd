class_name ShopNpc
extends Interactable

## Primitive shopkeeper that opens the player's existing ShopUI.

@export var player_group: StringName = &"players"
@export var speaker_name: String = "Shopkeeper"
@export_multiline var welcome_dialogue: String = "Welcome. Take a look at my wares."


func is_interaction_available(interactor: Node3D) -> bool:
	var shop_ui: ShopUI = _find_shop_ui(interactor)
	return shop_ui != null and not shop_ui.is_shop_open()


func get_interaction_prompt(_interactor: Node3D) -> String:
	return "Press E to browse shop"


func interact(interactor: Node3D) -> String:
	var shop_ui: ShopUI = _find_shop_ui(interactor)
	if shop_ui == null:
		push_error("ShopNpc could not resolve ShopUI on the interacting player.")
		return "%s: The shop is unavailable right now." % speaker_name

	# Open after PlayerInteractor finishes its current interaction refresh.
	shop_ui.call_deferred("open_shop")
	return "%s: %s" % [speaker_name, welcome_dialogue]


func _find_shop_ui(interactor: Node) -> ShopUI:
	var player_root: Node = _find_player_root(interactor)
	if player_root == null:
		return null

	for child_node: Node in player_root.get_children():
		if child_node is ShopUI:
			return child_node as ShopUI
	return null


func _find_player_root(start_node: Node) -> Node:
	var current_node: Node = start_node
	while current_node != null:
		if current_node.is_in_group(player_group):
			return current_node
		current_node = current_node.get_parent()
	return null
