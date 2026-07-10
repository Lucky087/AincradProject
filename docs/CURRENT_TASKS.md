# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M10 — Player Death, Respawning, and Checkpoints
**Current phase:** Death/respawn/checkpoint implementation package created; local Godot verification remains
**Last updated:** 2026-07-11

---

## 1. Status Legend

```text
[ ] Not started
[~] In progress
[x] Complete
[!] Blocked
[-] Intentionally postponed
```

---

## 2. Current Milestone Goal

Add reusable player death, safe checkpoint, respawn, fade, temporary damage
immunity, enemy disengagement, and checkpoint persistence without replacing the
existing player or changing persistent progression/economy ownership.

The milestone should prove that:

- `PlayerRespawn` owns temporary death and checkpoint state.
- Lethal health damage disables movement, camera input, combat, and interaction.
- Inventory and shop close before the death screen appears.
- The same player instance respawns after a 3-second wait and black fade.
- Active checkpoints use stable IDs and separate respawn marker transforms.
- The original player spawn remains the fallback checkpoint.
- Health resets to maximum and velocity is cleared on respawn.
- The player receives 2 seconds of movement-compatible damage immunity.
- The boar cancels attacks, releases the dead target, and returns to spawn.
- Save version 4 stores checkpoint data while versions 1–3 remain loadable.
- Every M1–M9 feature remains functional and unchanged by death.

Permanent death, penalties, corpse retrieval, multiple lives, multiplayer
respawning, main menus, detailed graphics, and external assets remain outside
this milestone.

---

## 3. M0 — Project Foundation

- [x] Create the five core project documents.
- [x] Define the Floor 1 vertical-slice scope.
- [x] Define naming and architecture rules.
- [x] Use Godot 4.7 and typed GDScript.
- [x] Select the Compatibility renderer for early greybox work.
- [x] Record the beginner-facing path structure.
- [x] Preserve the existing repository and project folder layout.
- [ ] Make a focused local Git commit for the completed milestone.

---

## 4. M1 — Third-Person Greybox

### Implementation

- [x] Create the runnable main scene.
- [x] Create the primitive greybox world.
- [x] Create the `CharacterBody3D` player.
- [x] Add camera-relative WASD movement.
- [x] Add mouse camera control.
- [x] Add gravity and jumping.
- [x] Add hold-to-sprint.
- [x] Add player-facing rotation.
- [x] Add Escape mouse capture toggling.
- [x] Add collision floor, cubes, ramps, lighting, and environment.

### Local verification

- [~] Continue verifying M1 behaviour while testing later milestones.
- [ ] Confirm movement, jumping, gravity, sprinting, camera, and collision remain correct.
- [ ] Confirm no new critical debugger errors affect M1.

---

## 5. M2 — Reusable Third-Person Interaction

### Implementation

- [x] Create the reusable `Interactable` base class.
- [x] Add camera-targeted interaction detection.
- [x] Add maximum interaction distance.
- [x] Add the interaction prompt and short-message UI.
- [x] Add the readable sign.
- [x] Add the primitive NPC.
- [x] Add the one-use chest.
- [x] Bind `interact` to E.
- [x] Preserve `player_controller.gd`.

### Local verification

- [~] Continue verifying M2 while testing M3.
- [ ] Confirm sign, NPC, and chest interactions still work.
- [ ] Confirm the prompt still appears and disappears correctly.
- [ ] Confirm the chest still opens only once.
- [ ] Confirm no new critical debugger errors affect M2.

---

## 6. M3 — Health and Basic Sword Combat

### Reusable health component

- [x] Create `res://AincradProject/scripts/components/health_component.gd`.
- [x] Use typed current-health and maximum-health values.
- [x] Add typed health-changed, damage-taken, health-restored, and died signals.
- [x] Add damage, healing, reset, health-ratio, and alive-state methods.
- [x] Keep the component independent from player, enemy, UI, saving, and multiplayer code.
- [x] Add a `HealthComponent` to the player.
- [x] Add a `HealthComponent` to the training dummy.

### Player sword combat

- [x] Create `res://AincradProject/scripts/player/player_combat.gd`.
- [x] Leave `player_controller.gd` unchanged.
- [x] Add a primitive sword beneath the existing `VisualRoot`.
- [x] Add one visible sword-swing tween.
- [x] Add a forward `ShapeCast3D` attack boundary.
- [x] Apply damage through `HealthComponent` rather than a dummy-specific method.
- [x] Prevent one health component from being damaged more than once per swing.
- [x] Add a short recovery and cooldown.
- [x] Prevent attacking while the mouse is released.
- [x] Prevent attacking when the player's health component is dead.

### Combat collision boundaries

- [x] Name collision layer 1 `World`.
- [x] Name collision layer 2 `Interactable`.
- [x] Reserve collision layer 3 for `Hurtbox` areas.
- [x] Set the player attack shape to detect only hurtbox layer 3.
- [x] Keep the interaction ray on its existing world/interactable mask.
- [x] Keep ordinary player movement collision unchanged.

### Training dummy

- [x] Create `res://AincradProject/scripts/enemies/training_dummy.gd`.
- [x] Create `res://AincradProject/scenes/enemies/training_dummy.tscn`.
- [x] Use only Godot primitive meshes and shapes.
- [x] Add a physical body collision shape.
- [x] Add a separate layer-3 hurtbox `Area3D`.
- [x] Display current dummy health with a `Label3D`.
- [x] Add visible hit feedback.
- [x] Disable the hurtbox after defeat.
- [x] Reset the dummy after three seconds for repeated tests.
- [x] Add one dummy to the existing greybox world.

### Player health UI

- [x] Create `res://AincradProject/scenes/ui/health_ui.tscn`.
- [x] Create `res://AincradProject/scripts/ui/health_ui.gd`.
- [x] Connect the UI to a reusable `HealthComponent` through a NodePath.
- [x] Display numeric HP and a progress bar.
- [x] Keep the health UI separate from the interaction UI.
- [x] Add missing-node error handling.

### Input

- [x] Add the `player_attack_primary` Input Map action.
- [x] Bind `player_attack_primary` to the left mouse button.
- [x] Preserve all existing movement, mouse-capture, and interaction actions.

### File safety

- [x] Preserve every existing folder.
- [x] Preserve every existing file except the explicitly required modifications.
- [x] Do not move, rename, delete, duplicate, or reorganize existing content.
- [x] Do not manually edit or delete any `.uid` file.
- [x] Create only the allowed new `scripts/components/` folder and milestone files.

### Local verification still required

- [~] Open the project in Godot 4.7 and allow new script UIDs to be generated normally.
- [ ] Confirm all new scripts parse without errors.
- [ ] Confirm all scenes load without missing-resource errors.
- [ ] Confirm the HP panel appears at the upper-left corner.
- [ ] Confirm the HP panel initially reads `HP: 100 / 100`.
- [ ] Confirm the primitive sword is visible on the player.
- [ ] Hold the mouse captured and press the left mouse button.
- [ ] Confirm the sword visibly swings once.
- [ ] Confirm repeated clicks during the swing do not start overlapping attacks.
- [ ] Stand outside attack range and confirm the dummy takes no damage.
- [ ] Stand close and face the dummy.
- [ ] Attack once and confirm the dummy changes from 100 HP to 75 HP.
- [ ] Confirm one swing removes only 25 HP even if several hurtbox checks occur.
- [ ] Attack four times and confirm the dummy is defeated.
- [ ] Confirm the dummy hurtbox stops accepting damage while defeated.
- [ ] Wait three seconds and confirm the dummy returns to 100 HP.
- [ ] Confirm WASD, camera, jump, sprint, gravity, and Escape still work.
- [ ] Confirm E interactions with the sign, NPC, and chest still work.
- [ ] Confirm no critical errors appear in the debugger.

M3 is complete after these local checks pass.

---

## 7. M4 — First Enemy

### Primitive boar scene

- [x] Create `res://AincradProject/scenes/enemies/boar_enemy.tscn`.
- [x] Create `res://AincradProject/scripts/enemies/boar_enemy.gd`.
- [x] Use `CharacterBody3D` as the root.
- [x] Use only Godot primitive meshes and collision shapes.
- [x] Reuse the existing `HealthComponent`.
- [x] Reuse collision layer 3 for the boar hurtbox.
- [x] Add body collision on the existing World layer.
- [x] Add a test-facing health and state `Label3D`.
- [x] Avoid creating an unnecessary enemy-base abstraction for only one moving enemy.

### Targeting and movement

- [x] Add the existing player root to the `players` group without changing its scripts.
- [x] Resolve the player through the group instead of a fragile absolute scene path.
- [x] Add configurable detection, disengage, and leash ranges.
- [x] Keep the boar idle while the player is far away.
- [x] Chase the player in `_physics_process()`.
- [x] Stop at a configurable attack distance.
- [x] Return toward the original spawn if the player escapes or the leash is exceeded.
- [x] Stop at the spawn and return to idle.
- [x] Use direct greybox movement without requiring a navigation mesh for this open test area.
- [x] Search again at a limited interval if the player reference becomes unavailable.

### Enemy attack

- [x] Add a visible primitive lunge animation.
- [x] Add an attack cooldown timer.
- [x] Apply damage through the player's existing `HealthComponent`.
- [x] Apply damage only once during each attack sequence.
- [x] Recheck maximum hit distance at the actual damage moment.
- [x] Ray-check the World layer so solid bodies can block the hit.
- [x] Stop attacking if the target is dead, missing, too far away, or blocked.

### Hit, death, and respawn

- [x] Connect to the existing typed health signals.
- [x] Add a brief hit reaction that interrupts the current attack.
- [x] Stop movement and attacks after death.
- [x] Disable body collision and the hurtbox while defeated.
- [x] Add a configurable respawn timer.
- [x] Restore the original transform, visuals, collision, hurtbox, and health on respawn.

### World and file safety

- [x] Add one boar beneath a new `HostileEnemies` node in the existing test world.
- [x] Preserve the player, training dummy, interactables, greybox geometry, light, and environment.
- [x] Leave `player_controller.gd`, `player_combat.gd`, and all existing public health methods and signals unchanged.
- [x] Preserve all existing files and folders except the explicitly required modifications.
- [x] Do not manually edit or delete any `.uid` file.
- [x] Add `docs/MILESTONE_4_SETUP.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and let Godot generate the new script UID normally.
- [ ] Confirm all scripts parse without errors.
- [ ] Confirm the boar appears near `(-10, 0, -8)`.
- [ ] Confirm the boar remains idle while the player is outside detection range.
- [ ] Confirm the boar begins chasing after the player approaches.
- [ ] Confirm the boar stops rather than standing directly inside the player.
- [ ] Confirm the lunge damages the player once.
- [ ] Confirm the health UI decreases by 12 HP for one successful attack.
- [ ] Confirm one attack never applies repeated damage during the same lunge.
- [ ] Move away during the windup and confirm excessive distance prevents damage.
- [ ] Put a solid greybox object between the boar and player and confirm the hit is blocked.
- [ ] Escape beyond disengage range and confirm the boar returns to spawn.
- [ ] Hit the boar and confirm the brief reaction is visible.
- [ ] Confirm each sword hit removes 25 HP through the existing combat system.
- [ ] Defeat the boar with four sword hits.
- [ ] Confirm it stops moving and attacking while defeated.
- [ ] Wait five seconds and confirm it respawns at full health at its original position.
- [ ] Confirm the training dummy still takes damage and resets.
- [ ] Confirm sign, NPC, and chest interactions still work.
- [ ] Confirm WASD, camera, jump, sprint, gravity, Escape, and the HP UI still work.
- [ ] Confirm no critical debugger errors appear.

M4 is complete after these local checks pass.

---

## 8. M5 — Experience and Levelling

### Reusable player progression

- [x] Create `res://AincradProject/scripts/components/player_progression.gd`.
- [x] Add typed current-level, current-experience, next-level requirement, and maximum-level state.
- [x] Start at Level 1 with 0 XP by default.
- [x] Use the replaceable formula `base_experience_per_level × current level`.
- [x] Configure the default base requirement as 100 XP.
- [x] Add `add_experience(amount)` with support for several level-ups from one reward.
- [x] Carry excess experience into the next level.
- [x] Add typed `experience_changed` and `levelled_up` signals.
- [x] Add typed getters and an experience-progress ratio.
- [x] Add useful level-up debug output.
- [x] Add the component to the existing player scene without modifying player movement or combat scripts.

### Boar experience reward

- [x] Add a configurable integer `experience_reward` to the existing boar.
- [x] Set the default reward to 40 XP.
- [x] Use the existing `HealthComponent.died(source)` killing source.
- [x] Resolve the responsible player by walking from the source to a `players` group member.
- [x] Find the player's direct `PlayerProgression` child without a fragile world path.
- [x] Award XP only from the boar's existing death callback.
- [x] Prevent duplicate rewards with one per-life reward gate.
- [x] Reset the reward gate only when the boar respawns.
- [x] Do not award XP when the boar is removed or freed for another reason.
- [x] Leave the training dummy unchanged so it gives no XP.

### Progression UI

- [x] Create `res://AincradProject/scenes/ui/progression_ui.tscn`.
- [x] Create `res://AincradProject/scripts/ui/progression_ui.gd`.
- [x] Place the progression panel beneath the existing health panel.
- [x] Show current level.
- [x] Show current XP and the next-level requirement.
- [x] Show an experience progress bar.
- [x] Show `Level Up!` briefly after a level increase.
- [x] Update only through progression signals rather than `_process()`.
- [x] Add required-node validation and clear errors.
- [x] Keep the existing health and interaction UI scenes unchanged.

### Stat growth decision

- [x] Review the existing `HealthComponent`.
- [x] Confirm it has no safe public method for changing maximum health at runtime.
- [x] Leave maximum health unchanged rather than modifying or bypassing its interface.
- [ ] Add a safe maximum-health API and optional `+5 HP per level` in a future dedicated task.

### File safety

- [x] Preserve all existing files and folders.
- [x] Do not move, rename, delete, duplicate, or reorganize project content.
- [x] Do not manually edit or delete existing `.uid` files.
- [x] Modify only the player scene, boar script, boar scene, and required documentation.
- [x] Add `docs/MILESTONE_5_SETUP.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and let Godot create new script UIDs normally.
- [ ] Confirm every script parses without errors.
- [ ] Confirm the progression panel appears below the existing health panel.
- [ ] Confirm the initial display reads `Level 1` and `XP: 0 / 100`.
- [ ] Defeat the boar once and confirm `XP: 40 / 100`.
- [ ] Wait for respawn, defeat it again, and confirm `XP: 80 / 100`.
- [ ] Wait for respawn, defeat it a third time, and confirm Level 2 with `XP: 20 / 200`.
- [ ] Confirm `Level Up!` appears briefly on the third defeat.
- [ ] Confirm the Output panel prints a useful level-up message.
- [ ] Confirm one boar death never gives 80 XP or more from duplicate callbacks.
- [ ] Confirm a respawned boar can give 40 XP again.
- [ ] Confirm the training dummy gives no XP.
- [ ] Confirm the player still receives boar damage and the health UI updates.
- [ ] Confirm sword attacks still damage both the boar and training dummy.
- [ ] Confirm boar detection, chasing, attacking, returning, death, and respawn still work.
- [ ] Confirm sign, NPC, and chest interactions still work.
- [ ] Confirm WASD, camera, jumping, sprinting, gravity, and Escape still work.
- [ ] Confirm no critical debugger errors appear.

M5 is complete after these local checks pass.

---

## 9. M6 — First Quest

### Reusable quest data and state

- [x] Create `res://AincradProject/scripts/quests/quest_definition.gd`.
- [x] Create `res://AincradProject/data/quests/boar_hunt.tres`.
- [x] Use the stable quest ID `boar_hunt`.
- [x] Use the stable objective ID `wild_boar`.
- [x] Store title, description, objective label, objective target, and XP reward in the resource.
- [x] Create `res://AincradProject/scripts/components/player_quest_log.gd`.
- [x] Support Not Started, Active, Ready to Turn In, and Completed states.
- [x] Add typed state, progress, and reward signals.
- [x] Add reusable registration, acceptance, objective-progress, and turn-in methods.
- [x] Prevent progress before acceptance and after the objective is ready.
- [x] Prevent the quest reward from being granted more than once.
- [x] Add the quest log to the existing player scene.

### Quest giver

- [x] Create `res://AincradProject/scripts/interactions/quest_npc.gd`.
- [x] Create `res://AincradProject/scenes/interactions/quest_npc.tscn`.
- [x] Inherit from the existing `Interactable` base class.
- [x] Use the existing E interaction input, camera ray, distance check, prompt, and message UI.
- [x] Use only Godot primitive meshes and shapes.
- [x] Present the quest offer on the first interaction.
- [x] Accept the quest on the second interaction.
- [x] Show state-dependent active, ready, and completed dialogue.
- [x] Turn in the quest only after 3 / 3 progress.
- [x] Add the new NPC near the player start without replacing the existing test NPC.

### Boar integration

- [x] Add the stable exported enemy ID `wild_boar` to the existing boar.
- [x] Preserve the normal configurable 40 XP reward.
- [x] Resolve the killing player from the existing damage source and `players` group.
- [x] Find that player's direct `PlayerQuestLog` child without an absolute world path.
- [x] Report one `wild_boar` objective event from the existing death callback.
- [x] Add a per-life quest-progress gate.
- [x] Reset the quest-progress gate only when the boar respawns.
- [x] Leave the training dummy unchanged so it never counts.
- [x] Preserve boar detection, movement, attack, hit, death, return, respawn, and XP behavior.

### Quest UI

- [x] Create `res://AincradProject/scripts/ui/quest_ui.gd`.
- [x] Create `res://AincradProject/scenes/ui/quest_ui.tscn`.
- [x] Place the tracker below the existing progression panel.
- [x] Hide the tracker before acceptance.
- [x] Show `Boar Hunt` and `Defeat wild boars: X / 3` while active.
- [x] Show `Return to the quest giver` at 3 / 3.
- [x] Show a brief completion message after turn-in, then hide.
- [x] Update from quest signals without `_process()` polling.
- [x] Validate required quest-log and UI node references.

### File safety and documentation

- [x] Preserve every existing folder and path.
- [x] Do not move, rename, delete, duplicate, or reorganize existing content.
- [x] Do not manually edit or delete any existing `.uid` file.
- [x] Modify only the player scene, test world, boar script, boar scene, and required documentation.
- [x] Add `docs/MILESTONE_6_SETUP.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and let Godot generate new script UIDs normally.
- [ ] Confirm all scripts parse without errors.
- [ ] Confirm all new resources and scenes load without missing references.
- [ ] Defeat a boar before acceptance and confirm it gives 40 XP but no quest progress.
- [ ] Talk to the Road Warden once and confirm the offer appears.
- [ ] Talk again and confirm Boar Hunt is accepted at 0 / 3.
- [ ] Defeat three respawning boars and confirm 1 / 3, 2 / 3, then 3 / 3.
- [ ] Confirm the tracker changes to `Return to the quest giver`.
- [ ] Confirm the 100 XP quest reward is not automatic.
- [ ] Return to the Road Warden and confirm exactly 100 XP is awarded.
- [ ] Talk again and confirm no duplicate reward is granted.
- [ ] Confirm the training dummy never changes quest progress.
- [ ] Confirm all M1–M5 behavior remains functional.
- [ ] Confirm no critical debugger errors appear.

M6 is complete after these local checks pass.

---

## 10. M7 — Save and Load System

### SaveManager

- [x] Create `res://AincradProject/scripts/systems/save_manager.gd`.
- [x] Register it as the `SaveManager` Autoload.
- [x] Keep the typed class name separate as `SaveManagerService`.
- [x] Save to `user://savegame.json`.
- [x] Add `save_version = 1`.
- [x] Find the player through the existing `players` group.
- [x] Validate the player and required direct child components.
- [x] Use `FileAccess` and `JSON` safely.
- [x] Reject empty, damaged, non-dictionary, and unsupported-version files.
- [x] Print useful warnings and the globalized save path.
- [x] Avoid `_process()` polling.

### Input actions

- [x] Add `save_game` to K.
- [x] Add `load_game` to L.
- [x] Use `_unhandled_input()`.
- [x] Ignore keyboard echo so each action runs once per press.

### Health persistence

- [x] Add `HealthComponent.get_save_data()`.
- [x] Add `HealthComponent.load_save_data(data)`.
- [x] Save current and maximum health.
- [x] Validate numeric values and clamp safely.
- [x] Emit `health_changed` after loading.
- [x] Do not replay damage, heal, or death events during loading.

### Progression persistence

- [x] Add `PlayerProgression.get_save_data()`.
- [x] Add `PlayerProgression.load_save_data(data)`.
- [x] Save current level, current XP, and maximum level.
- [x] Recalculate the existing XP requirement after loading.
- [x] Normalize oversized or invalid XP safely.
- [x] Emit `experience_changed` after loading.
- [x] Do not replay `levelled_up` during loading.

### Quest persistence

- [x] Add `PlayerQuestLog.get_save_data()`.
- [x] Add `PlayerQuestLog.load_save_data(data)`.
- [x] Save stable quest IDs, readable states, progress, and reward gates.
- [x] Skip unknown saved quest IDs with a warning.
- [x] Normalize completed state and reward ownership together.
- [x] Guarantee a completed quest cannot become rewardable after loading.
- [x] Add a dedicated `quest_data_loaded` UI-refresh signal.
- [x] Avoid replaying the normal quest-completion message on load.

### Save-status UI

- [x] Create `res://AincradProject/scripts/ui/save_status_ui.gd`.
- [x] Create `res://AincradProject/scenes/ui/save_status_ui.tscn`.
- [x] Add it to the existing player scene without replacing other UI.
- [x] Connect to the SaveManager status signal.
- [x] Show success, missing-file, read-error, version, and player errors.
- [x] Hide messages automatically after two seconds.

### File safety and documentation

- [x] Preserve every existing folder and path.
- [x] Do not move, rename, delete, duplicate, or reorganize existing content.
- [x] Do not manually create, edit, or delete `.uid` files.
- [x] Modify only the required project, player, component, UI, and document files.
- [x] Add `docs/MILESTONE_7_SETUP.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and let Godot generate new script UIDs normally.
- [ ] Confirm every script parses without errors.
- [ ] Confirm `SaveManager` appears under Remote scene-tree root.
- [ ] Confirm K displays `Game saved` exactly once.
- [ ] Confirm L displays `Game loaded` exactly once.
- [ ] Complete position, health, and 40-XP restart test.
- [ ] Complete active Boar Hunt 2 / 3 restart test.
- [ ] Complete claimed Boar Hunt reward protection test.
- [ ] Complete missing-file test.
- [ ] Complete empty-JSON and damaged-JSON tests.
- [ ] Complete unsupported-version test.
- [ ] Complete unknown-quest-ID test.
- [ ] Confirm all M1–M6 behavior remains functional.
- [ ] Confirm no critical debugger errors appear.

M7 is complete after all local checks pass.

---

## 11. M8 — Inventory, Items, and Weapon Equipment

### Item definitions

- [x] Create `res://AincradProject/scripts/items/item_definition.gd`.
- [x] Support Weapon, Consumable, Material, Quest Item, and Miscellaneous categories.
- [x] Support stable item ID, display name, description, stack limit, equipment flag,
  equipment slot, and weapon damage.
- [x] Create `data/items/training_sword.tres` with 25 damage.
- [x] Create `data/items/bronze_sword.tres` with 35 damage.
- [x] Keep Resource definitions separate from runtime ownership.

### Player inventory

- [x] Create `res://AincradProject/scripts/components/player_inventory.gd`.
- [x] Add `PlayerInventory` as a direct player child.
- [x] Register the two item definitions in the component Inspector.
- [x] Configure 16 inventory slots.
- [x] Add stable ID and quantity stacks.
- [x] Enforce each definition's maximum stack size.
- [x] Prevent duplicate non-stackable weapons.
- [x] Add item, remove item, ownership, quantity, equip, and unequip interfaces.
- [x] Add inventory and equipment signals.
- [x] Give a new player exactly one equipped Training Sword.
- [x] Add component-owned save and load interfaces.

### Combat integration

- [x] Preserve the existing attack signals, ShapeCast3D hit window, cooldown, and
  duplicate-hit protection.
- [x] Resolve `PlayerInventory` through an exported NodePath.
- [x] Read attack damage from the equipped weapon.
- [x] Keep Training Sword damage at 25.
- [x] Change damage to 35 immediately when Bronze Sword is equipped.
- [x] Prevent damage while no weapon is equipped.
- [x] Add a public combat-input gate for inventory mode.

### Chest reward

- [x] Preserve the existing `TestChest` scene and lid animation.
- [x] Configure the existing chest to grant `bronze_sword` once.
- [x] Find the interacting player's inventory through the player group/interface.
- [x] Refuse duplicate Bronze Swords.
- [x] Leave the chest closed when the reward cannot fit so the player can retry.
- [x] Display reward, already-owned, and inventory-full messages.

### Inventory UI and controls

- [x] Create `res://AincradProject/scripts/ui/inventory_ui.gd`.
- [x] Create `res://AincradProject/scenes/ui/inventory_ui.tscn`.
- [x] Add the UI beside the existing HUD without replacing it.
- [x] Add `toggle_inventory` and bind it to physical I.
- [x] Display item names, quantities, equipped marker, description, and damage.
- [x] Use keyboard selection and Enter to equip.
- [x] Use U to unequip for the required unarmed test.
- [x] Use I or Escape to close.
- [x] Disable movement, combat, and interaction input while open.
- [x] Restore prior mouse mode and gameplay input when closed.
- [x] Avoid `_process()` polling; refresh through signals.

### Save compatibility

- [x] Increase the save format to version 2.
- [x] Save item IDs, quantities, and equipped weapon ID.
- [x] Keep health, position, progression, and quest data unchanged.
- [x] Continue accepting version 1 save files.
- [x] Apply starter inventory defaults when version 1 has no inventory data.
- [x] Skip unknown saved item IDs with warnings.
- [x] Refresh inventory UI and combat damage through equipment signals after load.

### File safety and documentation

- [x] Preserve every existing folder and path.
- [x] Do not move, rename, delete, duplicate, or reorganize existing content.
- [x] Do not manually create, edit, or delete `.uid` files.
- [x] Create only the allowed `scripts/items/` folder; no alternate code roots.
- [x] Add `docs/MILESTONE_8_SETUP.md`.
- [x] Update `docs/CURRENT_TASKS.md` and `docs/DECISION_LOG.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and allow new script UIDs to be generated.
- [ ] Confirm all scripts and scenes parse without errors in Godot.
- [ ] Confirm new game starts with one Training Sword equipped.
- [ ] Confirm Training Sword still deals 25 damage and a 100-HP boar takes four hits.
- [ ] Open the chest and confirm exactly one Bronze Sword is added.
- [ ] Confirm repeat chest interaction cannot add a duplicate.
- [ ] Open inventory with I and verify keyboard selection.
- [ ] Equip Bronze Sword with Enter and confirm 35 damage.
- [ ] Unequip with U and confirm attacks apply no damage.
- [ ] Confirm movement, combat, and interaction are disabled while inventory is open.
- [ ] Confirm Escape closes inventory without changing mouse capture first.
- [ ] Save with Bronze Sword equipped, restart, load, and confirm equipment/damage.
- [ ] Load a Milestone 7 version-1 save and confirm safe starter defaults.
- [ ] Confirm all M1–M7 behavior remains functional.
- [ ] Confirm no critical debugger errors appear.

M8 is complete after all local checks pass.

---

## 12. M9 — Gold, Loot Drops, and Shop NPC

### Player wallet and HUD

- [x] Create `scripts/components/player_wallet.gd`.
- [x] Add `PlayerWallet` as a direct player child with zero starting gold.
- [x] Add non-negative add, spend, affordability, save, and load interfaces.
- [x] Add a typed gold-changed signal.
- [x] Create `scenes/ui/gold_ui.tscn` and `scripts/ui/gold_ui.gd`.
- [x] Place the gold display at the upper-right without replacing existing HUD.

### Boar rewards and loot

- [x] Preserve the existing 40 XP and quest-progress paths.
- [x] Add a configurable 12-gold reward to the killing player.
- [x] Limit gold to one award per spawned boar life.
- [x] Reset the gold gate only when the boar respawns.
- [x] Create the `boar_tusk` material definition with maximum stack 99.
- [x] Create one primitive `WorldItemPickup` Area3D scene.
- [x] Add a configurable 50-percent per-life drop roll.
- [x] Add deterministic seed injection for repeatable local testing.
- [x] Restrict a spawned drop to the player responsible for the killing hit.
- [x] Remove pickups only after inventory insertion succeeds.
- [x] Remove active temporary pickups after a successful save load.

### Shop and Iron Sword

- [x] Create the 45-damage `iron_sword` item definition.
- [x] Register Boar Tusk and Iron Sword in `PlayerInventory`.
- [x] Add `PlayerInventory.can_add_item()` for full transaction validation.
- [x] Create a primitive shopkeeper without replacing existing NPCs.
- [x] Open the shop through the existing E interaction system.
- [x] Create a keyboard-controlled modal shop UI.
- [x] Display player gold, price, damage, description, and purchase status.
- [x] Disable movement, combat, interaction, and inventory opening while shopping.
- [x] Close the shop with Escape before mouse capture changes.
- [x] Validate ownership, slot capacity, and affordability before spending.
- [x] Remove exactly 50 gold and add exactly one Iron Sword on success.
- [x] Refund gold if the final inventory insertion unexpectedly fails.
- [x] Prevent duplicate purchases and repeated-key transactions.

### Save compatibility

- [x] Increase the save writer to version 3.
- [x] Save wallet data through `PlayerWallet.get_save_data()`.
- [x] Restore wallet data through `PlayerWallet.load_save_data()`.
- [x] Continue accepting versions 1 and 2.
- [x] Use zero gold when an older save has no wallet section.
- [x] Preserve existing player, health, progression, quest, inventory, and equipment data.

### File safety and documentation

- [x] Preserve every existing file and folder path.
- [x] Create only files inside approved existing folders.
- [x] Do not manually create, edit, or delete `.uid` files.
- [x] Add `docs/MILESTONE_9_SETUP.md`.
- [x] Update `docs/CURRENT_TASKS.md` and `docs/DECISION_LOG.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and allow new script UIDs to be generated.
- [ ] Confirm the player starts with Gold: 0.
- [ ] Confirm each boar death grants exactly 12 gold once.
- [ ] Confirm existing 40 XP and quest progress still work.
- [ ] Confirm the deterministic 50-percent sequence produces drops and non-drops.
- [ ] Confirm Boar Tusk pickups collect automatically and stack correctly.
- [ ] Confirm pickups remain when inventory insertion fails.
- [ ] Confirm existing pickups disappear after loading.
- [ ] Confirm the shop blocks gameplay controls and inventory opening.
- [ ] Confirm an unaffordable purchase removes no gold.
- [ ] Confirm Iron Sword costs exactly 50 gold and cannot duplicate.
- [ ] Confirm Iron Sword deals 45 damage through existing combat.
- [ ] Save and reload gold, tusks, Iron Sword, and equipped weapon.
- [ ] Load version-1 and version-2 saves without crashing and confirm zero-gold fallback.
- [ ] Confirm all M1–M8 behavior remains functional.
- [ ] Confirm no critical debugger errors appear.

M9 is complete after all local checks pass.

---

## 13. M10 — Player Death, Respawning, and Checkpoints

### Player death and respawn component

- [x] Create `scripts/components/player_respawn.gd`.
- [x] Add `PlayerRespawn` as a direct player child.
- [x] Observe the existing `HealthComponent.died` signal.
- [x] Preserve the existing player scene instance instead of replacing it.
- [x] Close inventory and shop if they are open.
- [x] Disable movement, camera mouse input, attacks, and interactions while dead.
- [x] Clear player velocity at death and again at respawn.
- [x] Wait 3 seconds before the black fade.
- [x] Move the same player to the active checkpoint at full black.
- [x] Restore health to maximum.
- [x] Fade back and restore normal controls.
- [x] Add typed death, respawn, checkpoint, and protection signals.

### Death UI and protection

- [x] Create `scenes/ui/death_ui.tscn` and `scripts/ui/death_ui.gd`.
- [x] Display `You Died` and the safe-area respawn message.
- [x] Add a separate full-screen fade overlay.
- [x] Keep all existing HUD scenes in place beneath the death UI.
- [x] Add a temporary `Respawn protection` indicator.
- [x] Use the existing health invulnerability property for 2 seconds.
- [x] Keep player movement enabled during post-respawn protection.

### Checkpoint system

- [x] Create `scenes/interactions/checkpoint_crystal.tscn`.
- [x] Create `scripts/interactions/checkpoint_crystal.gd`.
- [x] Reuse the existing `Interactable` base and E interaction path.
- [x] Use stable ID `test_world_safe_zone`.
- [x] Use a child `RespawnPoint` marker instead of the collision-body origin.
- [x] Fully heal the player on first activation.
- [x] Change the primitive visual from inactive blue to active green.
- [x] Prevent repeated activation effects on the already-active checkpoint.
- [x] Support multiple future checkpoint scenes through the `checkpoints` group.
- [x] Preserve the original player spawn as fallback.
- [x] Add the checkpoint near the starting NPC area in `test_world.tscn`.

### Boar integration

- [x] Preserve all existing boar AI, combat, rewards, loot, quest, and respawn code.
- [x] Resolve the player's direct `PlayerRespawn` component safely.
- [x] Cancel an active boar attack immediately on `player_died`.
- [x] Stop treating dead, respawning, and protected players as valid targets.
- [x] Return the boar toward its original spawn after player death.
- [x] Allow normal detection again only after protection ends and range rules pass.

### Save compatibility

- [x] Increase the save writer to version 4.
- [x] Save active checkpoint ID, position, and rotation.
- [x] Restore checkpoint data through `PlayerRespawn.load_save_data()`.
- [x] Continue accepting versions 1, 2, and 3.
- [x] Use original-spawn fallback when older saves have no checkpoint section.
- [x] Keep player, health, progression, quest, inventory, equipment, and wallet data unchanged.
- [x] Exclude temporary death, fade, immunity, and enemy state from save data.
- [x] Reject saving during the death/black-screen respawn sequence.

### File safety and documentation

- [x] Preserve every existing file and folder path.
- [x] Create new files only inside existing approved folders.
- [x] Do not manually create, edit, or delete `.uid` files.
- [x] Add `docs/MILESTONE_10_SETUP.md`.
- [x] Update `docs/CURRENT_TASKS.md` and `docs/DECISION_LOG.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and allow new script UIDs to be generated.
- [ ] Activate the checkpoint and confirm full healing plus active visual.
- [ ] Confirm repeated interaction cannot repeat activation effects.
- [ ] Let the boar kill the player and confirm all gameplay inputs stop.
- [ ] Confirm open inventory and shop close immediately.
- [ ] Confirm the death message, 3-second delay, fade, teleport, and fade-back order.
- [ ] Confirm the player respawns at the active checkpoint with maximum health.
- [ ] Confirm velocity is cleared and normal controls return.
- [ ] Confirm 2 seconds of visible damage immunity while movement remains enabled.
- [ ] Confirm the boar cancels attacks and returns to spawn during death/protection.
- [ ] Confirm XP, gold, items, equipment, quest progress, and levels do not change.
- [ ] Save an active checkpoint, restart, load, and confirm later death uses it.
- [ ] Load versions 1–3 and confirm original-spawn fallback without crashing.
- [ ] Confirm every M1–M9 system still works.
- [ ] Confirm no critical debugger errors appear.

M10 is complete after all local checks pass.

---

## 14. Current Work Limit

Do not add the following during M10:

- Permanent death, lives, corpse retrieval, or death penalties.
- Item, gold, or experience loss.
- Main-menu, reload-screen, or scene replacement flows.
- Multiple checkpoint selection menus or fast travel.
- Multiplayer respawn authority.
- Detailed death animation, post-processing, or external assets.
- Changes to unrelated progression, inventory, economy, quest, or combat rules.

M10 is only one reusable respawn component, one death/fade UI, one primitive
checkpoint, boar disengagement, two-second protection, and save-version 4.

---

## 15. Next Milestone Preview

## M11 — Floor 1 Vertical Slice

Planned tasks:

- [ ] Replace the single test-space layout with a small Starting City section,
  road, and field while preserving reusable systems.
- [ ] Place the Road Warden, shopkeeper, chest, checkpoint, sign, test NPC,
  training target, and boar encounters into a readable route.
- [ ] Add landmarks and blocked future paths using primitive greybox geometry.
- [ ] Preserve the complete combat, progression, quest, inventory, economy,
  checkpoint, respawn, and save loop.
- [ ] Keep future floor zones and streaming boundaries in mind without building
  all 100 floors.

Begin M11 only after M10 passes local testing.

---

## 16. Updated Milestone Order

### M0 — Project Foundation

Documentation, decisions, project settings, and version-control preparation.

### M1 — Bootstrap and Third-Person Greybox

Main scene, primitive world, movement, camera, jump, sprint, gravity, and mouse capture.

### M2 — Reusable Third-Person Interaction

Camera targeting, prompt UI, one-line interactions, a sign, an NPC, and a one-use chest.

### M3 — Health and Basic Sword Combat

Reusable health, player HUD, primitive sword, attack hitbox, training-dummy hurtbox, and damage.

### M4 — First Enemy

One hostile primitive boar with detection, chase, attack, hit, death, return, and respawn behavior.

### M5 — Progression

Experience, levels, and basic HUD display.

### M6 — First Quest

One accept-track-complete quest.

### M7 — Saving and Loading

Versioned JSON save data and reliable restore flow.

### M8 — Inventory, Items, and Weapon Equipment

Resource-driven definitions, player inventory, one weapon slot, keyboard UI,
chest reward, combat integration, and save version 2.

### M9 — Gold, Loot Drops, and Shop NPC

Player wallet, boar gold, Boar Tusk pickup, weapon shop, Iron Sword, and save version 3.

### M10 — Player Death, Respawning, and Checkpoints

Death state, fade UI, stable safe checkpoint, boar disengagement, respawn
protection, and save version 4.

### M11 — Floor 1 Vertical Slice

Starting City section, road, field, landmarks, economy/checkpoint placement, and complete route.

### M12 — Prototype Polish

Feedback, audio, bug fixing, performance review, and full playthrough testing.

### M13 — Multiplayer Technical Test

Only after the complete local prototype works.

---

## 17. Definition of Done for Any Task

A task is done when:

- The requested behavior or document exists.
- Names follow the project rules or an accepted decision-log exception.
- Typed GDScript is used.
- Required scene references are validated.
- The result has been tested in Godot 4.7.
- No new critical errors are present.
- Existing completed behavior still works.
- Relevant documentation is updated.
- The change is ready for a focused Git commit.

---

## 18. Next Action

Open the project in Godot 4.7 and complete the M10 test sequence in
`docs/MILESTONE_10_SETUP.md`.

Prioritize these exact checks:

```text
Checkpoint activation:       full heal, active visual, no repeated effect
Player death:                every gameplay input stops
Respawn sequence:            3-second wait, fade, same-player teleport, full heal
Boar response:               attack cancelled and return to original spawn
Protection:                  2 seconds, movement allowed, no incoming damage
Persistent values:           XP, gold, items, equipment, and quest unchanged
Version 4 save:              active checkpoint survives restart/load
Versions 1 through 3:        load safely and use original spawn fallback
```

Run the complete M1–M9 regression checklist before considering M10 complete.
