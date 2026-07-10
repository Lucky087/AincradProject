# Milestone 8 Setup — Inventory, Items, and Weapon Equipment

**Engine:** Godot 4.7  
**Language:** Fully typed GDScript  
**Save format:** Version 2, backward-compatible with version 1  
**Last updated:** 2026-07-11

---

## 1. What This Milestone Adds

Milestone 8 adds a reusable item-definition layer, a player-owned inventory,
one weapon equipment slot, a keyboard inventory screen, a Bronze Sword reward
inside the existing chest, combat damage derived from equipment, and inventory
save/load support.

It does not add armour, consumable effects, crafting, shops, gold, random loot,
drag-and-drop, icons, or multiplayer inventory.

All earlier movement, interaction, health, combat, enemy, progression, quest,
and save behaviour remains in place.

---

## 2. New Files

```text
res://AincradProject/scripts/items/item_definition.gd
res://AincradProject/scripts/components/player_inventory.gd
res://AincradProject/scripts/ui/inventory_ui.gd
res://AincradProject/data/items/training_sword.tres
res://AincradProject/data/items/bronze_sword.tres
res://AincradProject/scenes/ui/inventory_ui.tscn
res://AincradProject/docs/MILESTONE_8_SETUP.md
```

Godot should generate new `.uid` files for the three new scripts after opening
the project. Do not create, edit, or delete those UID files manually.

---

## 3. Modified Files

```text
res://project.godot
res://AincradProject/scenes/player/player.tscn
res://AincradProject/scenes/interactions/test_chest.tscn
res://AincradProject/scripts/player/player_controller.gd
res://AincradProject/scripts/player/player_combat.gd
res://AincradProject/scripts/interactions/player_interactor.gd
res://AincradProject/scripts/interactions/test_chest.gd
res://AincradProject/scripts/systems/save_manager.gd
res://AincradProject/docs/CURRENT_TASKS.md
res://AincradProject/docs/DECISION_LOG.md
```

No existing file or folder was moved, renamed, deleted, duplicated, or
reorganized.

---

## 4. ItemDefinition Resource Structure

`ItemDefinition` is design data, not live player state.

Each resource supports:

```text
item_id
 display_name
 description
 item_category
 maximum_stack_size
 can_be_equipped
 equipment_slot
 weapon_damage
```

Supported categories:

```text
Weapon
Consumable
Material
Quest Item
Miscellaneous
```

Current equipment slots:

```text
None
Weapon
```

Only the Weapon slot is functional in this milestone.

### Training Sword

```text
Path:          data/items/training_sword.tres
Item ID:       training_sword
Name:          Training Sword
Description:   A basic sword used by new players.
Category:      Weapon
Maximum stack: 1
Slot:          Weapon
Damage:        25
```

### Bronze Sword

```text
Path:          data/items/bronze_sword.tres
Item ID:       bronze_sword
Name:          Bronze Sword
Description:   A stronger bronze sword made for beginner adventurers.
Category:      Weapon
Maximum stack: 1
Slot:          Weapon
Damage:        35
```

Stable item IDs are stored in saves. Display names and file paths are not used
as ownership identifiers.

---

## 5. PlayerInventory Data Structure

The player now contains one direct component:

```text
Player
└── PlayerInventory
```

Important Inspector values:

```text
Maximum Slots:         16
Item Definitions:      Training Sword, Bronze Sword
Starter Weapon ID:     training_sword
Equip Starter Weapon:  On
```

Runtime slots contain only:

```gdscript
{
    "item_id": StringName,
    "quantity": int,
}
```

The equipped weapon is stored separately as one stable item ID.

Important public methods include:

```gdscript
add_item(item_id, quantity) -> int
remove_item(item_id, quantity) -> int
has_item(item_id, quantity) -> bool
get_item_quantity(item_id) -> int
equip_weapon(item_id) -> bool
unequip_weapon() -> bool
get_equipped_weapon() -> ItemDefinition
get_equipped_weapon_id() -> StringName
get_equipped_weapon_damage() -> float
get_slots_snapshot() -> Array[Dictionary]
get_save_data() -> Dictionary
load_save_data(data) -> void
```

Signals:

```gdscript
inventory_changed
equipment_changed(equipped_weapon_id, weapon_definition)
```

A new game starts with exactly one Training Sword and equips it. The internal
add operation rechecks stack limits and refuses duplicate non-stackable weapons.

---

## 6. Combat Integration

The existing `PlayerCombat` scene node and attack system remain in use.

Its new Inspector value is:

```text
Inventory Path: ../PlayerInventory
```

The existing `attack_damage` exported property is preserved for compatibility,
but its live value is synchronized from `PlayerInventory`:

```text
Training Sword equipped: 25 damage
Bronze Sword equipped:   35 damage
No weapon equipped:       0 damage; attack cannot start
```

The existing ShapeCast3D, swing tween, hit timing, cooldown, and one-hit-per-
target-per-swing dictionary remain unchanged.

Equipment changes emit a signal, so combat damage refreshes immediately without
`_process()` polling.

---

## 7. Existing Chest Reward

The existing `TestChest` scene is still used.

Important Inspector values:

```text
Reward Item ID:          bronze_sword
Reward Obtained Message: Obtained Bronze Sword
Already Owned Message:   You already own the Bronze Sword.
Inventory Full Message:  Your inventory is full. Make space and try again.
```

Interaction flow:

1. The chest receives the existing E interaction.
2. It finds the interacting player through the existing `players` group.
3. It finds the player's direct `PlayerInventory` child.
4. If Bronze Sword is not owned, it attempts to add one.
5. A successful reward opens the existing lid and displays the obtained message.
6. If Bronze Sword is already owned, the lid opens but no duplicate is added.
7. If the inventory cannot accept the reward, the lid remains closed so it can be
   attempted later.

The chest does not use a hard-coded world path to the player.

---

## 8. Inventory UI Hierarchy

```text
InventoryUI (CanvasLayer, layer 30)
└── InventoryRoot (full-screen Control, hidden by default)
    ├── DimBackground
    └── CenterContainer
        └── InventoryPanel
            └── MarginContainer
                └── MainVBox
                    ├── TitleLabel
                    ├── TitleSeparator
                    ├── ContentHBox
                    │   ├── ItemsVBox
                    │   │   ├── ItemsLabel
                    │   │   └── ItemList
                    │   └── DetailsVBox
                    │       ├── DetailsLabel
                    │       └── DetailsPanel
                    │           └── DetailsMargin
                    │               └── DetailsContent
                    │                   ├── DescriptionLabel
                    │                   └── DamageLabel
                    └── InstructionsLabel
```

The UI is hidden when closed, so it does not permanently cover health,
progression, quest, interaction, or save-status interfaces.

### Controls

```text
I:       Open or close inventory
Up/Down: Select an item
Enter:   Equip selected weapon
U:       Unequip current weapon
Escape:  Close inventory before mouse capture changes
```

When open:

- Mouse becomes visible.
- Movement, jump, and sprint input are disabled.
- Active sword swings are cancelled and attack input is disabled.
- Interaction targeting and E input are disabled.
- Gravity remains active so opening the inventory in the air does not freeze the
  CharacterBody3D.
- The ItemList retains keyboard focus.

Closing restores gameplay input and the mouse mode that was active before the
inventory opened.

---

## 9. Input Map

`project.godot` already contains:

```text
Action: toggle_inventory
Physical key: I
```

To verify manually:

1. Open **Project → Project Settings → Input Map**.
2. Find `toggle_inventory`.
3. Expand it.
4. Confirm physical key I is assigned.

The action must keep the exact name `toggle_inventory`.

---

## 10. Save Version 2

Milestone 8 changes:

```text
SAVE_VERSION = 2
OLDEST_SUPPORTED_SAVE_VERSION = 1
```

The new section is:

```json
"inventory": {
  "items": [
    {
      "item_id": "training_sword",
      "quantity": 1
    },
    {
      "item_id": "bronze_sword",
      "quantity": 1
    }
  ],
  "equipped_weapon_id": "bronze_sword"
}
```

Health, position, progression, and quest sections remain unchanged.

### Loading version 2

`PlayerInventory`:

- Clears current runtime inventory.
- Revalidates every saved item ID.
- Ignores unknown IDs with warnings.
- Reapplies stack and slot limits.
- Rejects duplicate non-stackable weapons.
- Restores the equipped weapon only if it is owned and equippable.
- Emits inventory and equipment signals.

Those signals refresh the Inventory UI and combat damage immediately.

### Loading version 1

Version 1 contains no inventory section. It remains supported.

When a version-1 save is loaded, `PlayerInventory` applies its new-game default:

```text
One Training Sword
Training Sword equipped
```

It clears the inventory before adding the starter, so loading does not add a
second Training Sword.

---

## 11. Complete Testing Checklist

### A. Project and regression startup

- [ ] Open the folder containing `project.godot` in Godot 4.7.
- [ ] Allow Godot to generate UIDs for the three new scripts normally.
- [ ] Confirm no parser, missing-resource, or missing-node errors appear.
- [ ] Confirm WASD, camera, jumping, sprinting, and Escape mouse capture work.
- [ ] Confirm sign, test NPC, quest NPC, chest targeting, and interaction prompt work.
- [ ] Confirm health, progression, quest, and save-status UI remain visible normally.
- [ ] Confirm training dummy and boar behaviour remain functional.

### B. New-game starter weapon

- [ ] Start without loading a save.
- [ ] Press I.
- [ ] Confirm one Training Sword appears.
- [ ] Confirm it says `Equipped`.
- [ ] Confirm no second Training Sword exists.
- [ ] Close inventory.
- [ ] Hit the 100-HP training dummy once and confirm it reaches 75 HP.
- [ ] Defeat a fresh 100-HP boar and confirm it requires four successful hits.

### C. Chest reward and duplicate prevention

- [ ] Approach the existing chest and press E.
- [ ] Confirm the lid opens.
- [ ] Confirm `Obtained Bronze Sword` appears.
- [ ] Press I and confirm exactly one Bronze Sword exists.
- [ ] Confirm Training Sword still exists.
- [ ] Attempt repeated chest interaction and confirm no second Bronze Sword is added.
- [ ] Restart without loading, open the chest after a save that already owns Bronze
  Sword, and confirm the already-owned path adds no duplicate.

### D. Inventory controls and input blocking

- [ ] Press I and confirm the full-screen inventory opens.
- [ ] Use Up and Down to change selection.
- [ ] Confirm description and damage update for the selected item.
- [ ] While inventory is open, confirm WASD does not move the player.
- [ ] Confirm Space does not jump.
- [ ] Confirm Shift does not sprint.
- [ ] Confirm left click does not attack.
- [ ] Confirm E does not interact.
- [ ] Press Escape and confirm inventory closes.
- [ ] Confirm Escape did not also toggle mouse capture on that same press.
- [ ] Confirm all gameplay controls work after closing.

### E. Bronze Sword equipment

- [ ] Open inventory and select Bronze Sword.
- [ ] Press Enter.
- [ ] Confirm Bronze Sword displays `Equipped`.
- [ ] Confirm Training Sword no longer displays `Equipped`.
- [ ] Attack a full-health training dummy once and confirm it reaches 65 HP.
- [ ] Confirm a 100-HP boar requires three successful 35-damage hits.
- [ ] Equip Training Sword again and confirm damage immediately returns to 25.

### F. Unequipped weapon

- [ ] Open inventory and press U.
- [ ] Confirm no item displays `Equipped`.
- [ ] Close inventory and attempt an attack.
- [ ] Confirm no target takes damage.
- [ ] Reopen inventory, equip either sword, and confirm attacks work again.

### G. Version-2 save and load

- [ ] Own both swords.
- [ ] Equip Bronze Sword.
- [ ] Press K and confirm `Game saved`.
- [ ] Restart the game.
- [ ] Press L and confirm `Game loaded`.
- [ ] Press I and confirm both swords remain exactly once.
- [ ] Confirm Bronze Sword remains equipped.
- [ ] Confirm the next attack deals 35 damage.
- [ ] Confirm position, health, progression, and quest state still restore.

### H. Version-1 compatibility

- [ ] Back up the current save.
- [ ] Use a valid Milestone 7 version-1 save without an inventory section.
- [ ] Press L.
- [ ] Confirm the game does not crash.
- [ ] Confirm position, health, progression, and quest state restore normally.
- [ ] Open inventory and confirm exactly one Training Sword is equipped.
- [ ] Confirm no duplicate starter item appears after loading again.

### I. Damaged and unknown inventory data

- [ ] Add an unknown item ID to a test version-2 save.
- [ ] Load it and confirm the unknown item is skipped with a warning.
- [ ] Confirm known items still restore.
- [ ] Set an invalid equipped weapon ID and confirm it is ignored safely.
- [ ] Remove the inventory field from a version-2 test save and confirm starter
  defaults are applied rather than crashing.

Milestone 8 is complete only after the complete checklist passes locally.
