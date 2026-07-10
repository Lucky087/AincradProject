class_name PlayerInventory
extends Node

## Owns one player's item stacks and equipped weapon.
##
## Item design data comes from registered ItemDefinition resources. Runtime
## inventory state and save data use stable item IDs rather than node or
## Resource-path references.

signal inventory_changed
signal equipment_changed(equipped_weapon_id: StringName, weapon_definition: ItemDefinition)

@export_category("Capacity")
@export_range(1, 100, 1) var maximum_slots: int = 16

@export_category("Item Registry")
@export var item_definitions: Array[ItemDefinition] = []

@export_category("New Game Defaults")
@export var starter_weapon_id: StringName = &"training_sword"
@export var equip_starter_weapon: bool = true

var _definitions_by_id: Dictionary[StringName, ItemDefinition] = {}
var _slots: Array[Dictionary] = []
var _equipped_weapon_id: StringName = &""


func _ready() -> void:
	_build_definition_registry()
	if _slots.is_empty():
		reset_to_starter_inventory(false)


## Adds up to quantity items and returns the amount actually added.
func add_item(item_id: StringName, quantity: int = 1) -> int:
	var added_quantity: int = _add_item_internal(item_id, quantity)
	if added_quantity > 0:
		inventory_changed.emit()
	return added_quantity


## Removes up to quantity items and returns the amount actually removed.
func remove_item(item_id: StringName, quantity: int = 1) -> int:
	if quantity <= 0 or item_id.is_empty():
		return 0

	var remaining_quantity: int = quantity
	var removed_quantity: int = 0

	for slot_index: int in range(_slots.size() - 1, -1, -1):
		var slot: Dictionary = _slots[slot_index]
		if _get_slot_item_id(slot) != item_id:
			continue

		var current_quantity: int = _get_slot_quantity(slot)
		var amount_to_remove: int = mini(current_quantity, remaining_quantity)
		current_quantity -= amount_to_remove
		remaining_quantity -= amount_to_remove
		removed_quantity += amount_to_remove

		if current_quantity <= 0:
			_slots.remove_at(slot_index)
		else:
			slot["quantity"] = current_quantity
			_slots[slot_index] = slot

		if remaining_quantity <= 0:
			break

	if removed_quantity <= 0:
		return 0

	var equipment_was_removed: bool = _equipped_weapon_id == item_id and not has_item(item_id)
	if equipment_was_removed:
		_equipped_weapon_id = &""

	inventory_changed.emit()
	if equipment_was_removed:
		_emit_equipment_changed()

	return removed_quantity


## Returns whether at least quantity of item_id is owned.
func has_item(item_id: StringName, quantity: int = 1) -> bool:
	if quantity <= 0:
		return true
	return get_item_quantity(item_id) >= quantity


## Returns the total quantity across every stack for an item ID.
func get_item_quantity(item_id: StringName) -> int:
	var total_quantity: int = 0
	for slot: Dictionary in _slots:
		if _get_slot_item_id(slot) == item_id:
			total_quantity += _get_slot_quantity(slot)
	return total_quantity


## Equips an owned weapon and returns whether the operation succeeded.
func equip_weapon(item_id: StringName) -> bool:
	var definition: ItemDefinition = get_item_definition(item_id)
	if definition == null:
		push_warning("PlayerInventory cannot equip unknown item ID '%s'." % item_id)
		return false

	if not definition.is_equippable_weapon():
		push_warning("PlayerInventory item '%s' is not an equippable weapon." % item_id)
		return false

	if not has_item(item_id):
		push_warning("PlayerInventory cannot equip unowned item '%s'." % item_id)
		return false

	if _equipped_weapon_id == item_id:
		return true

	_equipped_weapon_id = item_id
	_emit_equipment_changed()
	return true


## Clears the equipped weapon slot.
func unequip_weapon() -> bool:
	if _equipped_weapon_id.is_empty():
		return false

	_equipped_weapon_id = &""
	_emit_equipment_changed()
	return true


## Returns the currently equipped weapon definition, or null when unarmed.
func get_equipped_weapon() -> ItemDefinition:
	if _equipped_weapon_id.is_empty():
		return null

	if not has_item(_equipped_weapon_id):
		return null

	var definition: ItemDefinition = get_item_definition(_equipped_weapon_id)
	if definition == null or not definition.is_equippable_weapon():
		return null

	return definition


func get_equipped_weapon_id() -> StringName:
	return _equipped_weapon_id


func get_equipped_weapon_damage() -> float:
	var equipped_weapon: ItemDefinition = get_equipped_weapon()
	if equipped_weapon == null:
		return 0.0
	return maxf(equipped_weapon.weapon_damage, 0.0)


func has_equipped_weapon() -> bool:
	return get_equipped_weapon() != null


## Returns a registered item definition by stable ID.
func get_item_definition(item_id: StringName) -> ItemDefinition:
	_ensure_definition_registry()
	return _definitions_by_id.get(item_id, null)


## Returns a deep copy of the current slot ID and quantity data.
func get_slots_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for slot: Dictionary in _slots:
		snapshot.append(slot.duplicate(true))
	return snapshot


func get_used_slot_count() -> int:
	return _slots.size()


## Returns whether the complete quantity can be added without partial insertion.
func can_add_item(item_id: StringName, quantity: int = 1) -> bool:
	if quantity <= 0:
		return true

	var definition: ItemDefinition = get_item_definition(item_id)
	if definition == null or not definition.is_valid_definition():
		return false

	if (
		definition.is_equippable_weapon()
		and definition.maximum_stack_size == 1
		and has_item(item_id)
	):
		return false

	var available_capacity: int = 0
	var maximum_stack: int = maxi(definition.maximum_stack_size, 1)
	for slot: Dictionary in _slots:
		if _get_slot_item_id(slot) == item_id:
			available_capacity += maxi(
				maximum_stack - _get_slot_quantity(slot),
				0
			)

	var empty_slot_count: int = maxi(maximum_slots - _slots.size(), 0)
	available_capacity += empty_slot_count * maximum_stack
	return available_capacity >= quantity


## Restores the configured new-game starter weapon without creating duplicates.
func reset_to_starter_inventory(emit_signals: bool = true) -> void:
	_slots.clear()
	_equipped_weapon_id = &""
	_ensure_definition_registry()

	if starter_weapon_id.is_empty():
		push_warning("PlayerInventory has no starter_weapon_id configured.")
	else:
		var added_quantity: int = _add_item_internal(starter_weapon_id, 1)
		if added_quantity != 1:
			push_warning("PlayerInventory could not add starter weapon '%s'." % starter_weapon_id)
		elif equip_starter_weapon:
			_equipped_weapon_id = starter_weapon_id

	if emit_signals:
		inventory_changed.emit()
		_emit_equipment_changed()


## Returns stable inventory state for SaveManager.
func get_save_data() -> Dictionary:
	var saved_items: Array[Dictionary] = []
	for slot: Dictionary in _slots:
		(
			saved_items
			. append(
				{
					"item_id": String(_get_slot_item_id(slot)),
					"quantity": _get_slot_quantity(slot),
				}
			)
		)

	return {
		"items": saved_items,
		"equipped_weapon_id": String(_equipped_weapon_id),
	}


## Restores inventory data. Missing inventory data uses new-game defaults.
func load_save_data(data: Dictionary) -> void:
	_ensure_definition_registry()

	if not data.has("items"):
		push_warning("PlayerInventory found no saved items; applying starter inventory defaults.")
		reset_to_starter_inventory()
		return

	var items_value: Variant = data["items"]
	if not items_value is Array:
		push_warning(
			"PlayerInventory expected saved 'items' to be an Array; applying starter defaults."
		)
		reset_to_starter_inventory()
		return

	_slots.clear()
	_equipped_weapon_id = &""

	var saved_items: Array = items_value as Array
	for saved_entry_value: Variant in saved_items:
		if not saved_entry_value is Dictionary:
			push_warning("PlayerInventory skipped a saved item entry that was not a Dictionary.")
			continue

		var saved_entry: Dictionary = saved_entry_value as Dictionary
		var saved_item_id: StringName = _read_saved_item_id(saved_entry)
		var saved_quantity: int = _read_saved_quantity(saved_entry)
		if saved_item_id.is_empty() or saved_quantity <= 0:
			continue

		if get_item_definition(saved_item_id) == null:
			push_warning("PlayerInventory skipped unknown saved item ID '%s'." % saved_item_id)
			continue

		var added_quantity: int = _add_item_internal(saved_item_id, saved_quantity)
		if added_quantity < saved_quantity:
			push_warning(
				(
					"PlayerInventory restored %d of %d '%s' because slot or stack limits were reached."
					% [added_quantity, saved_quantity, saved_item_id]
				)
			)

	var saved_equipped_id: StringName = _read_saved_equipped_weapon_id(data)
	if not saved_equipped_id.is_empty():
		var equipped_definition: ItemDefinition = get_item_definition(saved_equipped_id)
		if (
			equipped_definition != null
			and equipped_definition.is_equippable_weapon()
			and has_item(saved_equipped_id)
		):
			_equipped_weapon_id = saved_equipped_id
		else:
			push_warning(
				"PlayerInventory ignored invalid equipped weapon ID '%s'." % saved_equipped_id
			)

	inventory_changed.emit()
	_emit_equipment_changed()


func _add_item_internal(item_id: StringName, quantity: int) -> int:
	if quantity <= 0 or item_id.is_empty():
		return 0

	var definition: ItemDefinition = get_item_definition(item_id)
	if definition == null:
		push_warning("PlayerInventory cannot add unknown item ID '%s'." % item_id)
		return 0

	if not definition.is_valid_definition():
		push_warning("PlayerInventory item definition '%s' is invalid." % item_id)
		return 0

	if (
		definition.is_equippable_weapon()
		and definition.maximum_stack_size == 1
		and has_item(item_id)
	):
		return 0

	var remaining_quantity: int = quantity
	var added_quantity: int = 0
	var maximum_stack: int = maxi(definition.maximum_stack_size, 1)

	for slot_index: int in range(_slots.size()):
		var slot: Dictionary = _slots[slot_index]
		if _get_slot_item_id(slot) != item_id:
			continue

		var current_quantity: int = _get_slot_quantity(slot)
		var available_space: int = maximum_stack - current_quantity
		if available_space <= 0:
			continue

		var amount_to_add: int = mini(available_space, remaining_quantity)
		slot["quantity"] = current_quantity + amount_to_add
		_slots[slot_index] = slot
		remaining_quantity -= amount_to_add
		added_quantity += amount_to_add

		if remaining_quantity <= 0:
			break

	while remaining_quantity > 0 and _slots.size() < maximum_slots:
		var new_stack_quantity: int = mini(maximum_stack, remaining_quantity)
		(
			_slots
			. append(
				{
					"item_id": item_id,
					"quantity": new_stack_quantity,
				}
			)
		)
		remaining_quantity -= new_stack_quantity
		added_quantity += new_stack_quantity

	return added_quantity


func _build_definition_registry() -> void:
	_definitions_by_id.clear()

	for definition: ItemDefinition in item_definitions:
		if definition == null:
			push_warning("PlayerInventory skipped a null item definition.")
			continue

		if not definition.is_valid_definition():
			push_warning("PlayerInventory skipped an invalid item definition.")
			continue

		if _definitions_by_id.has(definition.item_id):
			push_warning(
				"PlayerInventory found duplicate item definition ID '%s'." % definition.item_id
			)
			continue

		_definitions_by_id[definition.item_id] = definition


func _ensure_definition_registry() -> void:
	if _definitions_by_id.is_empty() and not item_definitions.is_empty():
		_build_definition_registry()


func _emit_equipment_changed() -> void:
	equipment_changed.emit(_equipped_weapon_id, get_equipped_weapon())


func _get_slot_item_id(slot: Dictionary) -> StringName:
	var value: Variant = slot.get("item_id", &"")
	if value is StringName:
		return value as StringName
	if value is String:
		return StringName(value as String)
	return &""


func _get_slot_quantity(slot: Dictionary) -> int:
	var value: Variant = slot.get("quantity", 0)
	if value is int or value is float:
		return maxi(int(value), 0)
	return 0


func _read_saved_item_id(saved_entry: Dictionary) -> StringName:
	var value: Variant = saved_entry.get("item_id", "")
	if value is StringName:
		return value as StringName
	if value is String:
		return StringName(value as String)

	push_warning("PlayerInventory skipped a saved item with an invalid item_id.")
	return &""


func _read_saved_quantity(saved_entry: Dictionary) -> int:
	var value: Variant = saved_entry.get("quantity", 0)
	if value is int or value is float:
		return maxi(int(value), 0)

	push_warning("PlayerInventory skipped a saved item with an invalid quantity.")
	return 0


func _read_saved_equipped_weapon_id(data: Dictionary) -> StringName:
	var value: Variant = data.get("equipped_weapon_id", "")
	if value is StringName:
		return value as StringName
	if value is String:
		return StringName(value as String)

	push_warning("PlayerInventory ignored an invalid equipped_weapon_id value.")
	return &""
