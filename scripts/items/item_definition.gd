class_name ItemDefinition
extends Resource

## Immutable design data for one reusable item type.
##
## Runtime ownership and quantities belong to PlayerInventory. Save data uses
## item_id rather than Resource paths so item files can be reorganized later.

enum ItemCategory {
	WEAPON,
	CONSUMABLE,
	MATERIAL,
	QUEST_ITEM,
	MISCELLANEOUS,
}

enum EquipmentSlot {
	NONE,
	WEAPON,
}

@export_category("Identity")
@export var item_id: StringName = &""
@export var display_name: String = "Unnamed Item"
@export_multiline var description: String = ""

@export_category("Inventory")
@export var item_category: ItemCategory = ItemCategory.MISCELLANEOUS
@export_range(1, 999, 1) var maximum_stack_size: int = 1

@export_category("Equipment")
@export var can_be_equipped: bool = false
@export var equipment_slot: EquipmentSlot = EquipmentSlot.NONE
@export_range(0.0, 10000.0, 0.1) var weapon_damage: float = 0.0


## Returns true when the definition has the minimum data required by inventory.
func is_valid_definition() -> bool:
	return not item_id.is_empty() and maximum_stack_size > 0


## Returns whether this definition represents an equippable weapon.
func is_equippable_weapon() -> bool:
	return (
		item_category == ItemCategory.WEAPON
		and can_be_equipped
		and equipment_slot == EquipmentSlot.WEAPON
	)
