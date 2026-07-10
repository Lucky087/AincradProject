class_name ShopUI
extends CanvasLayer

# gdlint: disable=max-returns

## Keyboard-controlled one-item shop presentation.
##
## Wallet and inventory remain the authoritative owners of currency and items.
## The UI validates the complete transaction before spending any gold.

@export_category("Shop Item")
@export var shop_item_id: StringName = &"iron_sword"
@export_range(0, 1000000, 1) var purchase_price: int = 50

@export_category("Player Nodes")
@export var wallet_path: NodePath
@export var inventory_path: NodePath
@export var player_controller_path: NodePath
@export var player_combat_path: NodePath
@export var player_interactor_path: NodePath
@export var inventory_ui_path: NodePath

var _wallet: PlayerWallet = null
var _inventory: PlayerInventory = null
var _player_controller: PlayerController = null
var _player_combat: PlayerCombat = null
var _player_interactor: PlayerInteractor = null
var _inventory_ui: InventoryUI = null
var _shop_root: Control = null
var _item_list: ItemList = null
var _gold_label: Label = null
var _price_label: Label = null
var _damage_label: Label = null
var _description_label: Label = null
var _message_label: Label = null
var _setup_is_valid: bool = false
var _is_open: bool = false
var _purchase_in_progress: bool = false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		set_process_input(false)
		return

	_wallet.gold_changed.connect(_on_gold_changed)
	_inventory.inventory_changed.connect(_on_inventory_changed)
	_shop_root.visible = false
	_refresh_shop()


func _exit_tree() -> void:
	if _is_open:
		_set_gameplay_controls_enabled(true)
		if _inventory_ui != null:
			_inventory_ui.set_external_open_blocked(false)


func _input(event: InputEvent) -> void:
	if not _setup_is_valid or not _is_open:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.echo:
			return

	if _is_escape_event(event):
		close_shop()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(&"ui_accept"):
		_try_purchase_selected_item()
		get_viewport().set_input_as_handled()


## Opens the shop, releases the mouse, and disables gameplay input.
func open_shop() -> void:
	if not _setup_is_valid or _is_open:
		return

	_is_open = true
	_previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_inventory_ui.set_external_open_blocked(true)
	_set_gameplay_controls_enabled(false)
	_shop_root.visible = true
	_message_label.text = ""
	_refresh_shop()
	_item_list.grab_focus()


## Closes the shop and restores normal controls.
func close_shop() -> void:
	if not _is_open:
		return

	_is_open = false
	_shop_root.visible = false
	_inventory_ui.set_external_open_blocked(false)
	_set_gameplay_controls_enabled(true)
	Input.mouse_mode = _previous_mouse_mode


func is_shop_open() -> bool:
	return _is_open


func _try_purchase_selected_item() -> void:
	if _purchase_in_progress:
		return

	var definition: ItemDefinition = _inventory.get_item_definition(shop_item_id)
	if definition == null:
		_message_label.text = "This item is unavailable."
		push_warning("ShopUI could not find item definition '%s'." % shop_item_id)
		return

	if _inventory.has_item(shop_item_id):
		_message_label.text = "You already own the Iron Sword."
		return

	if not _inventory.can_add_item(shop_item_id, 1):
		_message_label.text = "Inventory full."
		return

	if not _wallet.can_afford(purchase_price):
		_message_label.text = "Not enough gold."
		return

	_purchase_in_progress = true
	if not _wallet.spend_gold(purchase_price):
		_message_label.text = "Purchase failed."
		_purchase_in_progress = false
		return

	var added_quantity: int = _inventory.add_item(shop_item_id, 1)
	if added_quantity != 1:
		_wallet.add_gold(purchase_price)
		if added_quantity > 0:
			_inventory.remove_item(shop_item_id, added_quantity)
		_message_label.text = "Purchase failed. Gold refunded."
		_purchase_in_progress = false
		return

	_message_label.text = "Purchased %s." % definition.display_name
	_purchase_in_progress = false
	_refresh_shop()


func _refresh_shop() -> void:
	if _wallet == null or _inventory == null:
		return

	_gold_label.text = "Your Gold: %d" % _wallet.get_current_gold()
	_price_label.text = "Price: %d gold" % purchase_price

	var definition: ItemDefinition = _inventory.get_item_definition(shop_item_id)
	_item_list.clear()
	if definition == null:
		_item_list.add_item("Unavailable item")
		_description_label.text = "The configured shop item could not be found."
		_damage_label.text = "Damage: —"
		return

	var item_text: String = definition.display_name
	if _inventory.has_item(shop_item_id):
		item_text += " — Owned"
	var item_index: int = _item_list.add_item(item_text)
	_item_list.select(item_index)
	_description_label.text = definition.description
	_damage_label.text = "Damage: %d" % int(round(definition.weapon_damage))


func _set_gameplay_controls_enabled(is_enabled: bool) -> void:
	_player_controller.set_movement_input_enabled(is_enabled)
	_player_combat.set_combat_input_enabled(is_enabled)
	_player_interactor.set_interaction_input_enabled(is_enabled)


func _on_gold_changed(
	_previous_gold: int,
	_current_gold: int,
	_change_amount: int
) -> void:
	_refresh_shop()


func _on_inventory_changed() -> void:
	_refresh_shop()


func _is_escape_event(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key_event: InputEventKey = event as InputEventKey
	return (
		key_event.pressed
		and (key_event.keycode == KEY_ESCAPE or key_event.physical_keycode == KEY_ESCAPE)
	)


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var wallet_node: Node = get_node_or_null(wallet_path)
	if wallet_node is PlayerWallet:
		_wallet = wallet_node as PlayerWallet
	else:
		push_error("ShopUI could not find PlayerWallet at: %s" % wallet_path)
		is_valid = false

	var inventory_node: Node = get_node_or_null(inventory_path)
	if inventory_node is PlayerInventory:
		_inventory = inventory_node as PlayerInventory
	else:
		push_error("ShopUI could not find PlayerInventory at: %s" % inventory_path)
		is_valid = false

	var controller_node: Node = get_node_or_null(player_controller_path)
	if controller_node is PlayerController:
		_player_controller = controller_node as PlayerController
	else:
		push_error("ShopUI could not find PlayerController at: %s" % player_controller_path)
		is_valid = false

	var combat_node: Node = get_node_or_null(player_combat_path)
	if combat_node is PlayerCombat:
		_player_combat = combat_node as PlayerCombat
	else:
		push_error("ShopUI could not find PlayerCombat at: %s" % player_combat_path)
		is_valid = false

	var interactor_node: Node = get_node_or_null(player_interactor_path)
	if interactor_node is PlayerInteractor:
		_player_interactor = interactor_node as PlayerInteractor
	else:
		push_error("ShopUI could not find PlayerInteractor at: %s" % player_interactor_path)
		is_valid = false

	var inventory_ui_node: Node = get_node_or_null(inventory_ui_path)
	if inventory_ui_node is InventoryUI:
		_inventory_ui = inventory_ui_node as InventoryUI
	else:
		push_error("ShopUI could not find InventoryUI at: %s" % inventory_ui_path)
		is_valid = false

	var shop_root_node: Node = get_node_or_null("ShopRoot")
	if shop_root_node is Control:
		_shop_root = shop_root_node as Control
	else:
		push_error("ShopUI is missing ShopRoot.")
		is_valid = false

	var item_list_node: Node = get_node_or_null(
		"ShopRoot/CenterContainer/ShopPanel/MarginContainer/MainVBox/ItemList"
	)
	if item_list_node is ItemList:
		_item_list = item_list_node as ItemList
	else:
		push_error("ShopUI is missing ItemList.")
		is_valid = false

	_gold_label = _resolve_label("GoldLabel", is_valid)
	_price_label = _resolve_label("PriceLabel", is_valid)
	_damage_label = _resolve_label("DamageLabel", is_valid)
	_description_label = _resolve_label("DescriptionLabel", is_valid)
	_message_label = _resolve_label("MessageLabel", is_valid)
	if (
		_gold_label == null
		or _price_label == null
		or _damage_label == null
		or _description_label == null
		or _message_label == null
	):
		is_valid = false

	return is_valid


func _resolve_label(label_name: String, _current_validity: bool) -> Label:
	var label_node: Node = find_child(label_name, true, false)
	if label_node is Label:
		return label_node as Label
	push_error("ShopUI is missing %s." % label_name)
	return null
