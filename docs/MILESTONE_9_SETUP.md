# Milestone 9 Setup — Gold, Loot Drops, and Shop NPC

**Engine:** Godot 4.7  
**Milestone:** M9  
**Save format:** Version 3, with versions 1 and 2 still supported

## Added systems

- `PlayerWallet` owns the player's non-negative gold balance.
- Each valid wild-boar death grants the killing player 12 gold in addition to
  the existing 40 XP and quest progress.
- Each boar life performs one 50-percent Boar Tusk drop roll.
- Temporary world pickups add items automatically through `Area3D.body_entered`.
- A primitive shopkeeper opens a modal shop UI through the existing interaction
  system.
- The Iron Sword costs 50 gold and deals 45 damage through the existing combat
  equipment integration.
- Save version 3 stores wallet data while versions 1 and 2 safely load with zero
  gold.

## New player hierarchy

```text
Player
├── HealthComponent
├── PlayerProgression
├── PlayerQuestLog
├── PlayerInventory
├── PlayerWallet
├── existing movement / combat / interaction nodes
├── existing HUD scenes
├── GoldUI
├── InventoryUI
├── ShopUI
└── InteractionUI
```

## Important Inspector values

### PlayerWallet

```text
Starting Gold: 0
```

### PlayerInventory

```text
Maximum Slots: 16
Registered definitions:
- Training Sword
- Bronze Sword
- Boar Tusk
- Iron Sword
```

### BoarEnemy rewards

```text
Experience Reward: 40
Gold Reward: 12
Loot Item ID: boar_tusk
Loot Quantity: 1
Loot Drop Chance: 0.5
Loot Random Seed: 1337
Loot Pickup Scene: world_item_pickup.tscn
```

A seed of 1337 makes the prototype drop sequence repeatable for testing. Set the
seed to 0 later for a newly randomized sequence each run.

### ShopUI

```text
Shop Item ID: iron_sword
Purchase Price: 50
Wallet Path: ../PlayerWallet
Inventory Path: ../PlayerInventory
Player Controller Path: ..
Player Combat Path: ../PlayerCombat
Player Interactor Path: ../PlayerInteractor
Inventory UI Path: ../InventoryUI
```

## Shop controls

```text
E: interact with shopkeeper and open shop
Up / Down: select shop entry
Enter: purchase
Escape: close shop before mouse capture changes
```

While the shop is open, movement, attacks, and interactions are disabled. The
inventory hotkey is also blocked until the shop closes.

## Purchase validation order

1. Resolve the Iron Sword definition.
2. Reject the purchase if already owned.
3. Confirm inventory capacity before spending.
4. Confirm at least 50 gold.
5. Spend exactly 50 gold.
6. Add exactly one Iron Sword.
7. Refund the full price if the final add unexpectedly fails.

## Save compatibility

Version 3 adds:

```json
"wallet": {
  "current_gold": 36
}
```

Versions 1 and 2 continue loading. Missing wallet data becomes 0 gold. Inventory
save data already uses stable IDs, so Boar Tusks, Iron Sword, and equipped weapon
are restored without changing the inventory schema.

Temporary world pickups are not saved. Existing pickups listen for
`SaveManager.load_completed` and remove themselves after any successful load.

## Complete local test checklist

### Gold rewards

- [ ] Start with `Gold: 0`.
- [ ] Defeat one boar and confirm 40 XP plus exactly 12 gold.
- [ ] Confirm active Boar Hunt progress still increases once.
- [ ] Confirm a defeated boar cannot grant gold twice.
- [ ] Confirm a respawned boar can grant another 12 gold.
- [ ] Confirm the training dummy grants no gold.

### Loot drops

- [ ] Defeat several boars and confirm the seeded 50-percent sequence produces
      both drops and non-drops.
- [ ] Confirm a drop appears near the defeated boar.
- [ ] Walk into the pickup without pressing E.
- [ ] Confirm one Boar Tusk enters the inventory.
- [ ] Confirm additional tusks stack up to 99.
- [ ] Fill inventory capacity and confirm an uncollected pickup remains.
- [ ] Load a save while a pickup exists and confirm the pickup disappears.

### Shop

- [ ] Confirm the new shopkeeper appears near the other NPCs.
- [ ] Interact with E and confirm the welcome message and shop UI.
- [ ] Confirm movement, attacks, interactions, and inventory opening are blocked.
- [ ] Press Escape and confirm the shop closes before mouse capture changes.
- [ ] Attempt purchase below 50 gold and confirm no gold is removed.
- [ ] Earn at least 50 gold and purchase Iron Sword.
- [ ] Confirm exactly 50 gold is removed.
- [ ] Confirm Iron Sword appears once in inventory.
- [ ] Try again and confirm no duplicate and no additional gold loss.

### Combat and equipment

- [ ] Equip Iron Sword in inventory.
- [ ] Confirm one attack deals 45 damage.
- [ ] Confirm existing Training Sword still deals 25.
- [ ] Confirm existing Bronze Sword still deals 35.
- [ ] Confirm attack cooldowns and one-hit-per-swing behavior remain unchanged.

### Saving and loading

- [ ] Save with gold, Boar Tusks, and Iron Sword owned.
- [ ] Restart and load.
- [ ] Confirm gold is restored exactly.
- [ ] Confirm tusk quantity is restored.
- [ ] Confirm Iron Sword and equipped weapon are restored.
- [ ] Load a version-2 save and confirm it uses 0 gold without crashing.
- [ ] Load a version-1 save and confirm all older fallback behavior still works.

### Regression

- [ ] Movement, camera, jump, sprint, and gravity work.
- [ ] Sign, test NPC, chest, and quest NPC interactions work.
- [ ] Health, progression, quest, inventory, and save UIs work.
- [ ] Training dummy, boar AI, boar attack, death, XP, quest progress, and respawn work.
- [ ] No new parser, missing-node, missing-resource, or runtime errors appear.
