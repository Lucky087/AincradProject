class_name InventoryUI
extends CanvasLayer

## Keyboard-controlled presentation for PlayerInventory.
##
## The UI owns only selection and visibility state. All item ownership and
## equipment state remains inside PlayerInventory.

const TOGGLE_INVENTORY_ACTION: StringName = &"toggle_inventory"
const UNEQUIP_KEY: Key = KEY_U
const ITEM_LIST_PATH: NodePath = NodePath(
	(
		"InventoryRoot/CenterContainer/InventoryPanel/MarginContainer/"
		+ "MainVBox/ContentHBox/ItemsVBox/ItemList"
	)
)
const DESCRIPTION_LABEL_PATH: NodePath = NodePath(
	(
		"InventoryRoot/CenterContainer/InventoryPanel/MarginContainer/"
		+ "MainVBox/ContentHBox/DetailsVBox/DetailsPanel/DetailsMargin/DetailsContent/DescriptionLabel"
	)
)
const DAMAGE_LABEL_PATH: NodePath = NodePath(
	(
		"InventoryRoot/CenterContainer/InventoryPanel/MarginContainer/"
		+ "MainVBox/ContentHBox/DetailsVBox/DetailsPanel/DetailsMargin/DetailsContent/DamageLabel"
	)
)

@export_category("Player Nodes")
@export var inventory_path: NodePath
@export var player_controller_path: NodePath
@export var player_combat_path: NodePath
@export var player_interactor_path: NodePath

var _inventory: PlayerInventory = null
var _player_controller: PlayerController = null
var _player_combat: PlayerCombat = null
var _player_interactor: PlayerInteractor = null
var _inventory_root: Control = null
var _item_list: ItemList = null
var _description_label: Label = null
var _damage_label: Label = null
var _setup_is_valid: bool = false
var _is_open: bool = false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	_setup_is_valid = _validate_input_action() and _setup_is_valid

	if not _setup_is_valid:
		set_process_input(false)
		return

	_inventory.inventory_changed.connect(_on_inventory_changed)
	_inventory.equipment_changed.connect(_on_equipment_changed)
	_item_list.item_selected.connect(_on_item_selected)
	_inventory_root.visible = false
	_refresh_inventory()


func _exit_tree() -> void:
	if _is_open:
		_set_gameplay_controls_enabled(true)


func _input(event: InputEvent) -> void:
	if not _setup_is_valid:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.echo:
			return

	if event.is_action_pressed(TOGGLE_INVENTORY_ACTION):
		if _is_open:
			close_inventory()
		else:
			open_inventory()
		get_viewport().set_input_as_handled()
		return

	if not _is_open:
		return

	if _is_escape_event(event):
		close_inventory()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(&"ui_accept"):
		_equip_selected_weapon()
		get_viewport().set_input_as_handled()
		return

	if _is_unequip_event(event):
		_inventory.unequip_weapon()
		get_viewport().set_input_as_handled()


## Opens the inventory, releases the mouse, and disables gameplay input.
func open_inventory() -> void:
	if not _setup_is_valid or _is_open:
		return

	_is_open = true
	_previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_gameplay_controls_enabled(false)
	_inventory_root.visible = true
	_refresh_inventory()
	_item_list.grab_focus()


## Closes the inventory and restores normal player controls.
func close_inventory() -> void:
	if not _is_open:
		return

	_is_open = false
	_inventory_root.visible = false
	_set_gameplay_controls_enabled(true)
	Input.mouse_mode = _previous_mouse_mode


func is_inventory_open() -> bool:
	return _is_open


func _refresh_inventory() -> void:
	if _inventory == null or _item_list == null:
		return

	var selected_item_id: StringName = _get_selected_item_id()
	var equipped_item_id: StringName = _inventory.get_equipped_weapon_id()
	var target_selection_index: int = -1
	var equipped_selection_index: int = -1
	_item_list.clear()

	var slots: Array[Dictionary] = _inventory.get_slots_snapshot()
	for slot: Dictionary in slots:
		var item_id: StringName = _read_slot_item_id(slot)
		var quantity: int = _read_slot_quantity(slot)
		var definition: ItemDefinition = _inventory.get_item_definition(item_id)
		if definition == null:
			continue

		var item_text: String = definition.display_name
		if quantity > 1:
			item_text += " x%d" % quantity
		if item_id == equipped_item_id:
			item_text += " — Equipped"

		var item_index: int = _item_list.add_item(item_text)
		_item_list.set_item_metadata(item_index, String(item_id))

		if item_id == selected_item_id:
			target_selection_index = item_index
		if item_id == equipped_item_id:
			equipped_selection_index = item_index

	if _item_list.item_count == 0:
		var empty_index: int = _item_list.add_item("(Empty)")
		_item_list.set_item_disabled(empty_index, true)
		_item_list.set_item_metadata(empty_index, "")
		_description_label.text = "No items are currently stored."
		_damage_label.text = "Damage: —"
		return

	if target_selection_index < 0:
		target_selection_index = equipped_selection_index
	if target_selection_index < 0:
		target_selection_index = 0

	_item_list.select(target_selection_index)
	_update_selected_item_details(target_selection_index)


func _update_selected_item_details(item_index: int) -> void:
	if item_index < 0 or item_index >= _item_list.item_count:
		_description_label.text = "Select an item to view its description."
		_damage_label.text = "Damage: —"
		return

	var item_id: StringName = _get_item_id_at_index(item_index)
	var definition: ItemDefinition = _inventory.get_item_definition(item_id)
	if definition == null:
		_description_label.text = "Select an item to view its description."
		_damage_label.text = "Damage: —"
		return

	_description_label.text = definition.description
	if definition.item_category == ItemDefinition.ItemCategory.WEAPON:
		_damage_label.text = "Damage: %d" % int(round(definition.weapon_damage))
	else:
		_damage_label.text = "Damage: —"


func _equip_selected_weapon() -> void:
	var selected_item_id: StringName = _get_selected_item_id()
	if selected_item_id.is_empty():
		return

	_inventory.equip_weapon(selected_item_id)


func _set_gameplay_controls_enabled(is_enabled: bool) -> void:
	_player_controller.set_movement_input_enabled(is_enabled)
	_player_combat.set_combat_input_enabled(is_enabled)
	_player_interactor.set_interaction_input_enabled(is_enabled)


func _get_selected_item_id() -> StringName:
	if _item_list == null:
		return &""

	var selected_indices: PackedInt32Array = _item_list.get_selected_items()
	if selected_indices.is_empty():
		return &""

	return _get_item_id_at_index(selected_indices[0])


func _get_item_id_at_index(item_index: int) -> StringName:
	var metadata: Variant = _item_list.get_item_metadata(item_index)
	if metadata is StringName:
		return metadata as StringName
	if metadata is String:
		return StringName(metadata as String)
	return &""


func _on_inventory_changed() -> void:
	_refresh_inventory()


func _on_equipment_changed(
	_equipped_weapon_id: StringName, _weapon_definition: ItemDefinition
) -> void:
	_refresh_inventory()


func _on_item_selected(item_index: int) -> void:
	_update_selected_item_details(item_index)


func _is_escape_event(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false

	var key_event: InputEventKey = event as InputEventKey
	return (
		key_event.pressed
		and (key_event.keycode == KEY_ESCAPE or key_event.physical_keycode == KEY_ESCAPE)
	)


func _is_unequip_event(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false

	var key_event: InputEventKey = event as InputEventKey
	return (
		key_event.pressed
		and (key_event.keycode == UNEQUIP_KEY or key_event.physical_keycode == UNEQUIP_KEY)
	)


func _read_slot_item_id(slot: Dictionary) -> StringName:
	var value: Variant = slot.get("item_id", &"")
	if value is StringName:
		return value as StringName
	if value is String:
		return StringName(value as String)
	return &""


func _read_slot_quantity(slot: Dictionary) -> int:
	var value: Variant = slot.get("quantity", 0)
	if value is int or value is float:
		return maxi(int(value), 0)
	return 0


func _validate_input_action() -> bool:
	if InputMap.has_action(TOGGLE_INVENTORY_ACTION):
		return true

	push_error("Missing Input Map action: %s" % TOGGLE_INVENTORY_ACTION)
	return false


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var inventory_node: Node = get_node_or_null(inventory_path)
	if inventory_node is PlayerInventory:
		_inventory = inventory_node as PlayerInventory
	else:
		push_error("InventoryUI could not find PlayerInventory at: %s" % inventory_path)
		is_valid = false

	var controller_node: Node = get_node_or_null(player_controller_path)
	if controller_node is PlayerController:
		_player_controller = controller_node as PlayerController
	else:
		push_error("InventoryUI could not find PlayerController at: %s" % player_controller_path)
		is_valid = false

	var combat_node: Node = get_node_or_null(player_combat_path)
	if combat_node is PlayerCombat:
		_player_combat = combat_node as PlayerCombat
	else:
		push_error("InventoryUI could not find PlayerCombat at: %s" % player_combat_path)
		is_valid = false

	var interactor_node: Node = get_node_or_null(player_interactor_path)
	if interactor_node is PlayerInteractor:
		_player_interactor = interactor_node as PlayerInteractor
	else:
		push_error("InventoryUI could not find PlayerInteractor at: %s" % player_interactor_path)
		is_valid = false

	var root_node: Node = get_node_or_null("InventoryRoot")
	if root_node is Control:
		_inventory_root = root_node as Control
	else:
		push_error("InventoryUI is missing InventoryRoot.")
		is_valid = false

	var item_list_node: Node = get_node_or_null(ITEM_LIST_PATH)
	if item_list_node is ItemList:
		_item_list = item_list_node as ItemList
	else:
		push_error("InventoryUI is missing ItemList.")
		is_valid = false

	var description_node: Node = get_node_or_null(DESCRIPTION_LABEL_PATH)
	if description_node is Label:
		_description_label = description_node as Label
	else:
		push_error("InventoryUI is missing DescriptionLabel.")
		is_valid = false

	var damage_node: Node = get_node_or_null(DAMAGE_LABEL_PATH)
	if damage_node is Label:
		_damage_label = damage_node as Label
	else:
		push_error("InventoryUI is missing DamageLabel.")
		is_valid = false

	return is_valid
