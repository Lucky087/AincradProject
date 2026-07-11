# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M15B.1 — North-Gate Road Collision Bugfix
**Current phase:** Road and edging physics disabled in favour of terrain collision after confirmed runtime sticking; local Godot 4.7 road traversal and regression retest required before M15C
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

**M15B current goal:** Import and validate the completed 16-piece north-gate architecture kit in Godot through a reusable architecture-only assembly and a separate F6 preview. Verify scale, negative-Z orientation, stable marker placement, the open gate passage, wall endpoints, road alignment, dedicated simplified collision, and existing-player traversal without modifying the permanent production region or normal F5 startup.

The uploaded M15A project now contains the completed Blender source, 16 render GLBs, 16 collision GLBs, a complete 32-GLB manifest, and Godot import metadata. M15B reproduces the manifest reference placement in an isolated preview. Runtime acceptance in Godot 4.7 remains required before provisional production integration.

**M14A historical goal:** Generate the first data-driven, map-aware southern Floor 1 terrain dataset around the Starting City gate while preserving all existing terrain tests, gameplay systems, scenes, `.uid` files, and the complete uploaded folder structure.

The M14A generator, terrain-profile JSON, completed terrain manifest, real 147 GLBs, generation log, documentation, and handoff remain preserved as accepted production-base history.

**M12 historical goal:** Lock the complete Floor 1 reference scale, coordinate system, region plan, future chunk grid, production order, SVG map, and machine-readable JSON without changing gameplay or 3D geometry.

The M11 goal text below is retained as historical milestone context and remains relevant for regression testing, but it is no longer the active work scope.

Create the first proper Floor 1 wilderness scene while preserving the reusable
player, interaction, combat, progression, quest, inventory, economy, save,
death, and checkpoint systems developed in M1 through M10.

The milestone should prove that:

- `test_world.tscn` remains available as an unchanged debugging scene.
- `floor_001_outskirts.tscn` provides an approximately 350-by-350-metre region.
- The Starting City gate, safe area, road, grasslands, forest, ruins, and sealed
  labyrinth entrance form a readable exploration route.
- Existing player and HUD scenes are instantiated exactly once.
- Existing quest, shop, sign, chest, checkpoint, and boar scenes work without
  duplicated scripts or alternate systems.
- Three separated boars provide sensible beginner encounters.
- Stable spawn markers prepare later procedural spawning and streaming work.
- Visible cliffs, city walls, water, and the sealed labyrinth stop players from
  leaving the current prototype route.
- A fall-safety volume returns the player to a safe transform.
- Loaded positions outside Floor 1 bounds fall back to `PlayerSpawn`.
- Invalid saved checkpoint transforms migrate to the city-gate checkpoint.
- The existing save format remains version 4 because no persistent schema changed.

Final terrain, detailed city art, new enemies, bosses, dungeon interiors, world
streaming, multiplayer, and external assets remain outside this milestone.

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

## 14. M11 — Floor 1 Outskirts Greybox

### New Floor 1 scene

- [x] Create `world/floors/floor_001/floor_001_outskirts.tscn`.
- [x] Keep `scenes/world/test_world.tscn` unchanged and manually openable.
- [x] Use one Godot unit as one metre.
- [x] Build an approximately 350-by-350-metre playable ground area.
- [x] Use only primitive meshes, simple materials, and existing scenes.
- [x] Organize content beneath clear zone and system parents.

### Region layout

- [x] Add the closed Starting City wall, gate, towers, safe plaza, and outgoing road.
- [x] Add open beginner grasslands with rocks and broad primitive hill caps.
- [x] Add one main road with readable forest and ruins branches.
- [x] Add a grouped primitive-tree forest with a clear path.
- [x] Add ancient ruins with broken walls, columns, and a raised platform.
- [x] Reserve the ruins platform for a future miniboss without creating one.
- [x] Add a large sealed labyrinth entrance visible from the southern road.
- [x] Add an unavailable-prototype sign at the labyrinth route.
- [x] Add visible cliff, wall, water, and sealed-door boundaries.

### Existing systems and placements

- [x] Instance the existing player scene once near the city gate.
- [x] Reuse every existing player-owned HUD and gameplay component through that scene.
- [x] Place the existing checkpoint with ID `floor_001_starting_city_gate`.
- [x] Place the existing Road Warden and Shopkeeper in the safe area.
- [x] Place existing sign and chest scenes without replacing their behavior.
- [x] Place three existing boars in separated grassland encounter locations.
- [x] Give each boar its own deterministic loot seed and scene-captured spawn transform.
- [x] Keep the training dummy only in the test world.

### Stable markers and future preparation

- [x] Add `PlayerSpawn`.
- [x] Add `CityGateCheckpoint`.
- [x] Add `GrasslandsEnemySpawn01` through `GrasslandsEnemySpawn03`.
- [x] Add `FutureForestEnemySpawn`.
- [x] Add `FutureRuinsMinibossSpawn`.
- [x] Add `FutureLabyrinthEntrance`.
- [x] Keep the current floor as one scene while preserving zone parent boundaries.

### Environment and performance

- [x] Add a procedural daytime sky and brighter directional lighting.
- [x] Add light distance fog that keeps the route readable.
- [x] Reuse materials and primitive mesh resources across repeated objects.
- [x] Keep decorative rocks and trees free of unnecessary collision.
- [x] Use simplified collision only on terrain, boundaries, large rocks, and structures.
- [x] Add no processing scripts for decoration.

### Startup, fall safety, and save compatibility

- [x] Create `scripts/world/floor_001_outskirts.gd`.
- [x] Add a below-map `Area3D` fall-safety volume.
- [x] Return a fallen player to an active valid checkpoint or `PlayerSpawn`.
- [x] Validate loaded player positions against Floor 1 bounds after a successful load.
- [x] Use `PlayerSpawn` when a loaded position is outside the region or below terrain.
- [x] Validate saved checkpoint transforms and migrate invalid ones to the gate checkpoint.
- [x] Preserve all version-1-through-version-4 save compatibility.
- [x] Keep SaveManager and its version-4 schema unchanged.
- [x] Point `scenes/main.tscn` at the new Floor 1 scene.
- [x] Make `scenes/main.tscn` the project startup scene.

### File safety and documentation

- [x] Preserve every existing path and file.
- [x] Do not modify `scenes/world/test_world.tscn`.
- [x] Create new files only inside the approved floor, script, and docs folders.
- [x] Do not manually create, edit, or delete `.uid` files.
- [x] Create `docs/MILESTONE_11_SETUP.md`.
- [x] Update `docs/CURRENT_TASKS.md` and `docs/DECISION_LOG.md`.

### Local verification still required

- [~] Open the project in Godot 4.7 and let new script UIDs generate normally.
- [ ] Confirm the project starts through `scenes/main.tscn` in Floor 1 outskirts.
- [ ] Confirm the player appears near the Starting City gate with every HUD visible.
- [ ] Activate the gate checkpoint and confirm healing, active visual, death respawn, and saving.
- [ ] Confirm Road Warden quest acceptance, progress, turn-in, and one-time reward.
- [ ] Confirm Shopkeeper purchase behavior and inventory/equipment integration.
- [ ] Confirm the chest, signs, inventory, save/load, and modal input gates still work.
- [ ] Confirm all three boars are separated and do not aggro together from the road.
- [ ] Confirm each boar still grants XP, gold, loot, and active quest progress once per life.
- [ ] Confirm the road, forest branch, ruins branch, and labyrinth route are readable.
- [ ] Confirm the labyrinth doorway remains sealed and its sign is readable.
- [ ] Confirm cliffs and walls stop ordinary boundary escape.
- [ ] Fall below the map and confirm safe recovery.
- [ ] Load an out-of-bounds position and confirm `PlayerSpawn` fallback.
- [ ] Load versions 1 through 4 and confirm no persistent data is lost.
- [ ] Open `scenes/world/test_world.tscn` manually and complete its regression checks.
- [ ] Confirm no critical debugger or missing-resource errors appear.

M11 is complete after all local checks pass.

---


## 15. M12 — Floor 1 Master Map and Scale Lock

### Reference and scale

- [x] Read all existing project documentation before planning.
- [x] Inspect `floor_001_outskirts.tscn` without modifying it.
- [x] Separate confirmed official information, reasonable interpretation, and original reconstruction.
- [x] Lock one Godot unit to one metre.
- [x] Lock Floor 1 to a 10,000-metre diameter and 5,000-metre radius.
- [x] Lock a 4,850-metre normal playable radius and 150-metre rim belt.
- [x] Lock floor-centred coordinates with `+X` east and `-Z` north.
- [x] Document player travel-time targets and settlement scale targets.
- [x] Confirm that origin shifting is not currently required.

### Master map and data

- [x] Create the complete circular Floor 1 development reconstruction.
- [x] Define fourteen stable regions and their neighbours.
- [x] Define known and reconstructed settlements, roads, dungeons, landmarks, spawn markers, and checkpoints.
- [x] Create `docs/floors/FLOOR_001_MASTER_MAP.svg`.
- [x] Create valid machine-readable `data/floors/floor_001.json`.
- [x] Mark confidence for major locations and measurements.

### Current outskirts integration

- [x] Map the 350-by-350-metre scene to the southern gate sector.
- [x] Set its planning origin to `(0, 0, 3835)`.
- [x] Document which parts can remain and which must be rebuilt or relocated.
- [x] Keep the existing scene byte-identical during this milestone.

### Chunk and production planning

- [x] Lock a 256-by-256-metre outdoor streaming grid.
- [x] Define chunk naming and coordinate rules.
- [x] Define future visual, collision, navigation, actor, persistence, save, and multiplayer behavior.
- [x] Create a phased production order from floor shell to Labyrinth exterior.
- [x] Defer streaming implementation, terrain geometry, enemies, quests, final art, and additional floors.

### Documentation and safety

- [x] Update `PROJECT_BIBLE.md`.
- [x] Update `TECHNICAL_ARCHITECTURE.md`.
- [x] Update `CURRENT_TASKS.md`.
- [x] Update `DECISION_LOG.md`.
- [x] Preserve every gameplay, scene, project setting, and `.uid` file.
- [ ] Review the SVG and JSON inside the local repository.
- [ ] Make a focused local Git commit.

M12 is complete when the planning artifacts are accepted as the source of truth for future Floor 1 production.

---
## 16. Current Work Limit

During M12, do not modify gameplay code, project settings, scenes, terrain geometry, enemy placement, NPC placement, or save data. Only the required planning documents, SVG, JSON, and documentation updates are allowed.

The M11 limits below are retained as additional production constraints:

Do not add the following during M11:

- Final Starting City buildings or detailed architecture.
- Terrain plugins, imported heightmaps, Blender models, or external assets.
- New enemies, minibosses, bosses, or labyrinth interiors.
- World streaming, chunk loading, procedural spawning, or multiplayer.
- Crafting, skills, armour, additional currencies, or unrelated systems.
- Detailed vegetation collision, high-density props, or final textures.

M11 is one readable, complete outdoor greybox that reuses the existing vertical
slice systems and prepares stable markers and zone boundaries for later work.

---

## 17. Next Milestone Preview

## M13 — Floor Shell and Streaming Prototype

Planned M13 tasks:

- [ ] Create a data-driven empty Floor 1 root using the locked 10 km bounds.
- [ ] Prototype the 256 m chunk coordinate grid with flat debug chunks only.
- [ ] Add chunk-border collision and navigation seam tests.
- [ ] Add a floor/region/chunk debug overlay.
- [ ] Plan a versioned save migration for floor, region, and chunk IDs.
- [ ] Keep both `test_world.tscn` and `floor_001_outskirts.tscn` available for regression.
- [ ] Do not begin final terrain or art until the empty streaming prototype is stable.

Begin M13 only after the M12 SVG, JSON, and scale decisions are reviewed and accepted.

### Later M14 prototype-polish tasks retained from the previous roadmap


- [ ] Complete a full start-to-finish Floor 1 playthrough and regression pass.
- [ ] Improve combat, hit, quest, purchase, checkpoint, and loot feedback.
- [ ] Add placeholder audio using only properly licensed or original sources.
- [ ] Profile the outdoor scene and reduce any unnecessary greybox cost.
- [ ] Fix navigation, collision, UI overlap, and readability issues found locally.
- [ ] Review which greybox zones should become future streamable chunks.

Begin M14 only after M13 is stable and the retained M11 local regression checks pass.

---

## 18. Updated Milestone Order

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

### M11 — Floor 1 Outskirts Greybox

Starting City gate, road, grasslands, forest, ruins, sealed labyrinth landmark,
stable markers, boundary recovery, and the complete reusable gameplay loop.

### M12 — Floor 1 Master Map and Scale Lock

### M13 — Floor Shell and Streaming Prototype

### M14 — Prototype Polish

Feedback, audio, bug fixing, performance review, and full playthrough testing.

### M15 — Multiplayer Technical Test

Only after the complete local prototype works.

---

## 19. Definition of Done for Any Task

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

## 20. Next Action

Review these Milestone 12 source-of-truth files before creating more Floor 1 geometry:

```text
docs/floors/FLOOR_001_REFERENCE_AUDIT.md
docs/floors/FLOOR_001_SCALE_GUIDE.md
docs/floors/FLOOR_001_MASTER_PLAN.md
docs/floors/FLOOR_001_REGION_LIST.md
docs/floors/FLOOR_001_PRODUCTION_ORDER.md
docs/floors/FLOOR_001_MASTER_MAP.svg
data/floors/floor_001.json
```

After acceptance, the next implementation milestone is the empty Floor 1 shell and 256 m streaming prototype.

The older M11 local regression action remains below and should still be completed in Godot 4.7:

Open the project in Godot 4.7 and complete the M11 test sequence in
`docs/MILESTONE_11_SETUP.md`.

Prioritize these exact checks:

```text
Startup:                      Main wrapper loads Floor 1 outskirts
Safe area:                    Player, HUD, checkpoint, quest NPC, shop, chest
Route:                        Gate → road → grasslands → forest/ruins → labyrinth
Encounters:                   Three separated boars retain every reward system
Death and checkpoint:         Respawn at floor_001_starting_city_gate
Save/load:                    Valid position restore plus out-of-bounds fallback
Fall recovery:                Below-map volume returns player safely
Debug scene:                  test_world.tscn remains manually playable

Run the complete M1–M10 regression checklist before considering M11 complete.


---

## 21. Milestone 13A — Blender Terrain-Chunk Pipeline Test

**Status:** Script prepared; local Blender execution required  
**Date:** 2026-07-11

This milestone is inserted before the Floor 1 shell and streaming implementation. It proves terrain generation and export without changing gameplay or building the full floor.

### Completed in the project package

- [x] Preserve the complete outer `aincrad/` and inner `AincradProject/` structure.
- [x] Read and follow the Floor 1 scale, map, region, and production documents.
- [x] Create `BlenderSource/` beside `AincradProject/`.
- [x] Keep Blender `.blend` source outside the Godot import tree.
- [x] Create the Blender 4.x terrain generator script.
- [x] Calculate the outskirts centre chunk from the locked grid formula.
- [x] Select the 3 × 3 test grid covering X `-1..1` and Z `13..15`.
- [x] Use stable names such as `floor_001_chunk_x+00_z+14`.
- [x] Define 65 × 65 LOD0 meshes.
- [x] Define 33 × 33 LOD1 meshes.
- [x] Define 17 × 17 collision meshes.
- [x] Use deterministic global-coordinate height sampling.
- [x] Use global-coordinate UVs.
- [x] Add border, corner, dimension, and placement validation.
- [x] Add separate GLB export and manifest generation.
- [x] Add safe generator-owned collection cleanup.
- [x] Create the beginner-friendly Blender pipeline guide.
- [x] Validate Python syntax and pure generation calculations outside Blender.
- [x] Confirm no gameplay, scene, project setting, or `.uid` file changed.

### Local Blender completion required

- [ ] Install or open Blender 4.x.
- [ ] Run `BlenderSource/floor_001/scripts/generate_floor_001_terrain_test.py`.
- [ ] Confirm `SEAM VALIDATION PASSED`.
- [ ] Confirm nine LOD0, nine LOD1, and nine collision objects exist.
- [ ] Confirm every mesh is exactly 256 × 256 metres.
- [ ] Confirm twenty-seven real GLB files are exported.
- [ ] Confirm `terrain_test_manifest.json` is generated and valid.
- [ ] Confirm `floor_001_terrain_test.blend` is saved outside `AincradProject`.
- [ ] Open the GLBs in Godot and verify import scale and orientation.
- [ ] Complete a visual neighbour-edge inspection in Blender.

### Explicitly not included

- [x] No complete ten-kilometre Floor 1 terrain.
- [x] No Godot chunk loader.
- [x] No world streaming.
- [x] No navigation meshes.
- [x] No roads, lakes, forests, or final materials.
- [x] No gameplay or scene modifications.

### Next milestone after local approval

Proceed to **M13B — Floor Shell and Streaming Prototype** only after the generated chunks import at correct scale, orientation, and seams in Godot.

---

## 22. Milestone 13B — Godot Terrain-Chunk Import Test

**Status:** Test scene and loader prepared; local Godot 4.7 verification required  
**Date:** 2026-07-11

This milestone validates the real 13A GLB exports inside an isolated Godot scene.
It does not change the normal game startup or implement world streaming.

### Completed in the project package

- [x] Read the generated terrain manifest.
- [x] Validate Floor 1 ID, one-metre units, 256 m chunk size, centre chunk, and chunk count.
- [x] Create `scenes/world/terrain_chunk_test.tscn`.
- [x] Create `scripts/world/terrain_chunk_test_loader.gd`.
- [x] Reuse the existing player scene and its active camera.
- [x] Load all valid LOD0 GLBs from manifest paths.
- [x] Load all valid LOD1 GLBs and keep them hidden by default.
- [x] Add an F4 debug toggle without modifying `project.godot`.
- [x] Place chunk roots from manifest `global_position` values.
- [x] Validate that grid coordinates and manifest positions agree.
- [x] Build `StaticBody3D` collision only from dedicated collision GLBs.
- [x] Organize LOD0, LOD1, and collision beneath each stable chunk root.
- [x] Add a periodic debug display without `_process()`.
- [x] Add a test-scene-only fall-recovery volume.
- [x] Continue safely when an individual GLB is missing.
- [x] Create `docs/floors/FLOOR_001_GODOT_TERRAIN_TEST.md`.
- [x] Preserve the normal game, test world, outskirts, SaveManager, and project settings.
- [x] Preserve every existing `.uid`, `.godot`, and imported asset file.

### Local Godot verification required

- [ ] Allow Godot 4.7 to finish importing all 27 GLBs.
- [ ] Open `scenes/world/terrain_chunk_test.tscn`.
- [ ] Run the current scene with F6.
- [ ] Confirm nine LOD0 chunks load.
- [ ] Confirm nine LOD1 chunks load.
- [ ] Confirm nine collision chunks load.
- [ ] Confirm the debug panel reports the expected centre chunk.
- [ ] Confirm the debug panel reports manifest seams as passed.
- [ ] Confirm the complete area is approximately 768 by 768 metres.
- [ ] Confirm the player scale is correct at one unit per metre.
- [ ] Walk and jump across every internal chunk border.
- [ ] Confirm no visible terrain cracks or major collision gaps.
- [ ] Press F4 and compare LOD0 and LOD1 alignment.
- [ ] Fall below the terrain and confirm safe recovery.
- [ ] Run the normal game with F5 and confirm it is unchanged.

### Explicitly not included

- [x] No final distance-based LOD system.
- [x] No runtime world streaming.
- [x] No navigation meshes.
- [x] No complete Floor 1 terrain.
- [x] No roads, forests, buildings, enemies, or NPCs.
- [x] No gameplay, player, SaveManager, main-scene, or project-setting changes.

### Next step after local approval

Proceed to an empty Floor 1 shell and streaming prototype only after the 13B
scene proves correct scale, axes, visual seams, collision seams, and manifest
placement in Godot 4.7.

---

## 23. Milestone 13C — Runtime Terrain Chunk Streaming Test

**Status:** Streaming scene and reusable loader prepared; local Godot 4.7 verification required  
**Date:** 2026-07-11

This milestone adds an isolated runtime streaming test using only the nine
existing terrain chunks. It does not change normal F5 gameplay or the 13B
non-streaming regression scene.

### Completed in the project package

- [x] Preserve the complete outer `aincrad/`, `.godot/`, `AincradProject/`, and
      `BlenderSource/` structure.
- [x] Keep `terrain_chunk_test.tscn` and its loader unchanged.
- [x] Create reusable `scripts/world/floor_chunk_streamer.gd`.
- [x] Create isolated `scenes/world/terrain_streaming_test.tscn`.
- [x] Create test coordinator `scripts/world/terrain_streaming_test.gd`.
- [x] Build a manifest registry keyed by signed `Vector2i` grid coordinates.
- [x] Use floor-based 256 m coordinate calculation for positive and negative
      world positions.
- [x] Select LOD0, LOD1, collision, retention, and unloading independently.
- [x] Use default radii 0, 1, 1, and 2 chunks.
- [x] Recalculate target sets only on chunk changes or explicit test updates.
- [x] Poll loading through a 0.20-second Timer rather than every rendered frame.
- [x] Queue unique threaded `PackedScene` requests.
- [x] Prevent repeated requests for queued or loading paths.
- [x] Ignore stale completed requests after the player leaves their target area.
- [x] Preserve one stable root per active chunk ID.
- [x] Preserve one visual node and one collision body per active root.
- [x] Build physics only from dedicated collision GLBs.
- [x] Remove visual and collision independently outside their radii.
- [x] Remove chunk roots outside the unload radius.
- [x] Add periodic debug counts and loaded stable IDs.
- [x] Add one transparent current-cell boundary plane.
- [x] Add local `Ctrl + Arrow` test teleports without changing Input Map.
- [x] Add isolated fall recovery without changing saves or checkpoints.
- [x] Create `docs/floors/FLOOR_001_CHUNK_STREAMING_TEST.md`.
- [x] Preserve normal gameplay, player scripts, SaveManager, project settings,
      existing `.uid` files, and all `.godot` contents.

### Local Godot verification required

- [ ] Open `scenes/world/terrain_streaming_test.tscn` in Godot 4.7.
- [ ] Run it with F6.
- [ ] Confirm the centre coordinate is `(0, 14)`.
- [ ] Confirm one centre LOD0 chunk becomes active.
- [ ] Confirm eight neighbouring LOD1 chunks become active.
- [ ] Confirm nine collision chunks become active.
- [ ] Confirm all loading requests eventually complete.
- [ ] Walk east across X `256` and confirm the current grid becomes `(1, 14)`.
- [ ] Walk west across X `0` and confirm floor-based negative coordinate logic.
- [ ] Walk and jump across every active collision border.
- [ ] Confirm no duplicate visual or collision nodes accumulate.
- [ ] Use `Ctrl + Arrow` to test every generated chunk centre.
- [ ] Confirm outward teleports report missing manifest coordinates safely.
- [ ] Confirm roots beyond the unload radius are removed.
- [ ] Fall below the test grid and confirm centre recovery.
- [ ] Open and run `terrain_chunk_test.tscn` as the unchanged regression test.
- [ ] Press F5 and confirm the normal game remains unchanged.

### Explicitly not included

- [x] No complete Floor 1 terrain.
- [x] No additional Blender chunks.
- [x] No production world streaming integration.
- [x] No roads, cities, forests, rivers, navigation, enemies, or NPCs.
- [x] No gameplay, player, SaveManager, main-scene, or project-setting changes.
- [x] No multiplayer streaming.

### Completion gate

Do not expand the terrain batch until local Godot testing confirms correct
signed coordinates, LOD transitions, independent collision, safe unloading,
no duplicate instances, and unchanged normal gameplay.


---

## 24. Milestone 14A — Actual Southern Floor 1 Terrain Generation

**Status:** Complete implementation and mathematical preflight delivered; local Blender 5.1.2 generation required  
**Date:** 2026-07-11

### Completed in the project package

- [x] Preserve the complete outer `aincrad/`, `.godot/`, `AincradProject/`, and `BlenderSource/` structure.
- [x] Preserve all existing nine-chunk GLBs, imports, manifest, Blender generator, source file, Godot tests, gameplay scenes, scripts, and `.uid` files.
- [x] Create `data/floors/floor_001_southern_terrain_profile.json`.
- [x] Store the city-gate plateau, safe-zone limits, road control points, terrain transitions, drainage, height controls, slope limits, seed, confidence, and chunk range in profile data.
- [x] Create `BlenderSource/floor_001/scripts/generate_floor_001_southern_terrain.py`.
- [x] Support Blender 5.1.2 with practical Blender 4.x exporter fallback.
- [x] Include `PROJECT_ROOT_OVERRIDE: str = r""`.
- [x] Generate exactly 49 logical chunks for X `-3…+3` and Z `+11…+17`.
- [x] Use one deterministic global-coordinate height function.
- [x] Create 65 × 65 LOD0, 33 × 33 LOD1, and 17 × 17 collision grids.
- [x] Protect the city-gate plateau and future northbound road corridor from uncontrolled noise.
- [x] Create gradual western woodland and eastern lowland transition masks.
- [x] Add Blender-safe generated collections and non-exported validation markers.
- [x] Add four simple placeholder terrain materials.
- [x] Stop rather than delete an untagged conflicting generated collection or material.
- [x] Validate east/west borders, north/south borders, shared corners, dimensions, placement, cross-resolution alignment, and configured slopes.
- [x] Pass mathematical seam validation for all 49 chunks.
- [x] Create the explicit preflight manifest with 49 chunk records and pending-export status.
- [x] Create the preflight generation log without pretending Blender executed.
- [x] Create `docs/floors/FLOOR_001_SOUTHERN_TERRAIN_GENERATION.md`.
- [x] Create `docs/handoffs/HANDOFF_MILESTONE_14A.md`.
- [x] Keep normal F5 gameplay and all existing test scenes unchanged.

### Mathematical validation completed

- [x] Python syntax compilation passed.
- [x] Both Floor 1 JSON files parse and validate.
- [x] Exactly 49 chunk coordinates are produced.
- [x] Border values compared: 9,660.
- [x] Shared-corner values compared: 324.
- [x] Cross-resolution values compared: 67,522.
- [x] Placement checks passed: 294.
- [x] Dimension checks passed: 294.
- [x] Maximum sampled slope ratio: 0.098960.
- [x] Maximum safe-zone slope ratio: 0.017429.
- [x] Maximum road-corridor slope ratio: 0.033653.
- [x] `SOUTHERN TERRAIN SEAM VALIDATION PASSED`.

### Local Blender 5.1.2 verification required

- [ ] Open and run `generate_floor_001_southern_terrain.py` in Blender 5.1.2.
- [ ] Confirm the generator creates only `Floor001SouthernTerrain` and its four child collections.
- [ ] Confirm 49 LOD0, 49 LOD1, and 49 collision objects are created.
- [ ] Confirm all generated objects measure exactly 256 × 256 metres horizontally.
- [ ] Confirm the gate plateau, road corridor, western ridges, eastern lowlands, and northern continuation look intentional.
- [ ] Confirm the Blender console prints `SOUTHERN TERRAIN SEAM VALIDATION PASSED`.
- [ ] Confirm exactly 147 GLBs are exported.
- [ ] Confirm `floor_001_southern_terrain.blend` is created.
- [ ] Confirm the manifest status changes to `complete_blender_exports_generated`.
- [ ] Confirm the generation log reports Blender execution and exports as true.
- [ ] Open Godot 4.7 and allow the new GLBs to import.
- [ ] Run the unchanged 13B and 13C terrain regression scenes.
- [ ] Run F5 and confirm normal gameplay remains unchanged.

### Explicitly not included

- [x] No Starting City buildings, wall, or gate model.
- [x] No road meshes, bridges, trees, rocks, grass, rivers, or water.
- [x] No enemies, NPCs, navigation meshes, or final materials.
- [x] No full Floor 1 and no Floors 2–100.
- [x] No gameplay, player, UI, SaveManager, project setting, main-scene, or existing-test changes.

### Completion gate and next milestone

M14A remains locally unapproved until Blender 5.1.2 creates and validates the real 147 GLBs and source `.blend`. After the complete local checklist passes, proceed to **Milestone 14B — Southern Terrain Godot Import and 7 × 7 Streaming Validation** in a separate F6 test scene.

---

## 25. Milestone 14B — Southern Terrain Godot Import and 7 × 7 Streaming Validation

**Status:** Implementation and static validation complete; local Godot 4.7 F6 approval required  
**Date:** 2026-07-11

The uploaded 14B archive already contains the completed Milestone 14A Blender
outputs: 49 LOD0 GLBs, 49 LOD1 GLBs, 49 collision GLBs, and a manifest reporting
147 completed exports with passed seam validation.

### Completed in the project package

- [x] Preserve the complete outer `aincrad/`, `.godot/`, `AincradProject/`, and
      `BlenderSource/` structure.
- [x] Keep normal F5 startup, player, SaveManager, gameplay systems, project
      settings, and both earlier terrain test scenes unchanged.
- [x] Create `scenes/world/floor_001_southern_streaming_test.tscn`.
- [x] Create `scripts/world/floor_001_southern_streaming_test.gd`.
- [x] Reuse `scripts/world/floor_chunk_streamer.gd` instead of duplicating the
      streaming system.
- [x] Preserve every existing public streamer method and signal.
- [x] Preserve the original nine-chunk default manifest and default settings.
- [x] Add backward-compatible support for nested southern `lod_paths`.
- [x] Add opt-in dataset ID, chunk count, grid range, export completion, GLB
      count, seam, and resource-path expectations.
- [x] Reject a pending or incomplete Blender manifest with a clear status.
- [x] Register exactly 49 southern chunk records.
- [x] Validate exactly 49 unique LOD0, 49 unique LOD1, and 49 unique collision
      paths.
- [x] Validate all 147 GLBs exist and have Godot import records.
- [x] Use LOD0 radius 1, LOD1 visual radius 2, collision radius 1, unload radius
      3, and a 0.20-second update interval.
- [x] Use threaded ResourceLoader requests and a controlled queue.
- [x] Retain visited southern resources in the isolated test cache to avoid
      repeated requests during the documented route.
- [x] Keep collision independent from visual LOD.
- [x] Reuse the existing `player.tscn` without modifying it.
- [x] Add manifest-derived safe placement and downward collision raycasts.
- [x] Add F1 gate, F2 north, F3 west, F4 east, and F9 centre teleports.
- [x] Add local B-key boundary toggling without Input Map changes.
- [x] Add test-only fall recovery without save or checkpoint changes.
- [x] Add current and nearby loaded chunk boundary lines with one mesh per group.
- [x] Add periodic debug counts, loaded IDs, cache size, load/unload counters,
      failures, and recent streaming update duration.
- [x] Create `docs/floors/FLOOR_001_SOUTHERN_STREAMING_TEST.md`.
- [x] Create `docs/handoffs/HANDOFF_MILESTONE_14B.md`.
- [x] Pass GDScript parser/linter checks.
- [x] Pass static manifest, GLB, path, structure, and preservation validation.

### Local Godot 4.7 verification required

- [ ] Open `floor_001_southern_streaming_test.tscn` and run it with F6.
- [ ] Confirm dataset ID `floor_001_southern_region_v1`.
- [ ] Confirm manifest validation shows PASSED.
- [ ] Confirm 49/49 chunks register.
- [ ] Confirm pending requests reach zero and failed requests remain zero.
- [ ] Confirm the same player lands safely on the city-gate collision.
- [ ] Confirm movement, sprint, jump, camera, and controls remain normal.
- [ ] Walk north across Z 3584, 3328, and 3072.
- [ ] Confirm nearby chunks become LOD0 and the outer visible ring becomes LOD1.
- [ ] Confirm collision follows radius 1 independently from LOD.
- [ ] Confirm distant visuals, collisions, and roots unload correctly.
- [ ] Confirm no duplicate roots, visual nodes, or StaticBody3D nodes accumulate.
- [ ] Test F3 western transition.
- [ ] Test F4 eastern transition.
- [ ] Test F2 northern continuation edge.
- [ ] Return with F1 and confirm safe placement and cache reuse.
- [ ] Toggle boundary visualization with B.
- [ ] Trigger fall recovery and confirm no progression or save changes.
- [ ] Run unchanged `terrain_chunk_test.tscn`.
- [ ] Run unchanged `terrain_streaming_test.tscn`.
- [ ] Press F5 and confirm the normal game remains unchanged.

### Explicitly not included

- [x] No roads, city wall, gate model, buildings, trees, grass, rocks, rivers,
      lakes, enemies, NPCs, navigation meshes, or final materials.
- [x] No normal-game Floor 1 integration.
- [x] No full Floor 1 or Floors 2–100.
- [x] No multiplayer streaming.

### Completion gate and next milestone

Do not create the production shell until the complete 14B F6 route and both
regression scenes pass locally. After approval, proceed to **Milestone 14C —
Southern Terrain Acceptance and Empty Floor 1 Production Shell**.

---

## 26. Milestone 14C — Southern Terrain Acceptance and Empty Floor 1 Production Shell

**Status:** Implementation and static validation complete; local Godot 4.7 F6 preview verification required  
**Date:** 2026-07-11

The user confirmed that the 49-chunk southern terrain dataset was generated and
validated locally. The permanent production shell is now separate from all
technical terrain tests and is not the default F5 world.

### Completed in the project package

- [x] Preserve the complete outer `aincrad/` structure.
- [x] Keep `project.godot`, normal F5 startup, existing terrain tests, player,
      SaveManager, gameplay systems, southern GLBs, manifests, Blender files,
      `.uid` files, and `.godot/` unchanged.
- [x] Inspect all documentation under `AincradProject/docs/`.
- [x] Remove only the two orphaned Git conflict-marker lines after D-074.
- [x] Preserve every meaningful decision in `DECISION_LOG.md`.
- [x] Create the permanent production region at
      `world/floors/floor_001/floor_001_southern_region.tscn`.
- [x] Create the production controller at
      `scripts/world/floor_001_southern_region.gd`.
- [x] Create `data/floors/floor_001_southern_region.json`.
- [x] Reuse the real 49-chunk southern terrain manifest.
- [x] Reuse `floor_chunk_streamer.gd` rather than duplicate streaming code.
- [x] Preserve all existing streamer methods and add a backwards-compatible
      `Node3D` streaming-target API.
- [x] Keep the production region player-independent.
- [x] Add empty static, dynamic, navigation, audio, region-volume, and debug
      containers for future content.
- [x] Add stable spawn, checkpoint, gate, wall, road, field, and future-region
      markers derived from the terrain profile and Floor 1 plan.
- [x] Add a data-driven 305-metre city-gate safe-zone `Area3D` with enter/exit
      signals only.
- [x] Add production bounds and fallback-marker hooks without save changes.
- [x] Use LOD0 radius 1, LOD1 radius 2, collision radius 1, unload radius 3, and
      a 0.20-second update interval.
- [x] Create an F6-only preview that instances the permanent region and existing
      player separately.
- [x] Add safe collision-derived preview spawn, fall recovery, debug counts,
      chunk boundaries, stable-marker guides, and safe-zone visualization.
- [x] Create `docs/floors/FLOOR_001_SOUTHERN_TERRAIN_ACCEPTANCE.md`.
- [x] Create `docs/handoffs/HANDOFF_MILESTONE_14C.md`.
- [x] Update `TECHNICAL_ARCHITECTURE.md` and `DECISION_LOG.md`.
- [x] Pass the GDScript parser, `gdlint`, and 1,190 static validation checks.
- [x] Keep roads, buildings, walls, vegetation, enemies, NPCs, navigation baking,
      final materials, and normal-game integration out of this milestone.

### Local Godot 4.7 verification required

- [ ] Open `floor_001_southern_region.tscn` and confirm no missing resources.
- [ ] Open `floor_001_southern_region_preview.tscn` and run it with F6.
- [ ] Confirm region ID `region_floor_001_southern`.
- [ ] Confirm manifest validation passes and 49 chunks register.
- [ ] Confirm the existing player lands on exported collision at the city gate.
- [ ] Confirm walking, sprinting, jumping, and camera controls remain normal.
- [ ] Walk north across multiple 256-metre boundaries.
- [ ] Confirm LOD0, LOD1, collision, and unloading behave as in 14B.
- [ ] Confirm the debug panel reports correct chunk and safe-zone state.
- [ ] Press B and confirm chunk-boundary guides toggle.
- [ ] Press M and confirm stable-marker and safe-zone guides toggle.
- [ ] Press F1 and confirm the player safely returns to the gate.
- [ ] Fall below the terrain and confirm preview-only recovery.
- [ ] Confirm no save, checkpoint, inventory, quest, XP, health, equipment, or gold
      changes occur from preview recovery.
- [ ] Run unchanged `terrain_chunk_test.tscn`.
- [ ] Run unchanged `terrain_streaming_test.tscn`.
- [ ] Run unchanged `floor_001_southern_streaming_test.tscn`.
- [ ] Press F5 and confirm the existing normal game still starts.
- [ ] Confirm no duplicate player or terrain systems appear.

### Completion gate and next milestone

After the production preview and all three terrain regressions pass locally,
proceed to **Milestone 15A — Starting City North-Gate Architecture Greybox**.

---

## 27. Milestone 15A — Starting City North-Gate Architecture Greybox

**Status:** Blender generation complete in the uploaded project; Godot placement verification moved to M15B  
**Date:** 2026-07-11

This milestone creates a reusable architecture asset kit. It does not place the
kit into the permanent production region and does not change normal F5 startup.

### Completed in the project package

- [x] Preserve the complete outer `aincrad/` structure.
- [x] Preserve the accepted southern terrain, all 147 terrain GLBs, manifests,
      terrain generators, production region, preview, technical tests, player,
      SaveManager, gameplay, `.uid` files, and `.godot/`.
- [x] Read all files under `AincradProject/docs/`.
- [x] Read and validate the permanent region JSON, terrain profile, and
      production-region Marker3D nodes.
- [x] Lock `CityGateCentre`, `CityWallWestConnection`,
      `CityWallEastConnection`, and `MainRoadStart` as architecture anchors.
- [x] Create
      `BlenderSource/floor_001/scripts/generate_floor_001_north_gate_architecture.py`.
- [x] Support Blender 5.1.2 with practical Blender 4.x glTF fallback.
- [x] Use one unit as one metre and preserve Godot east +X, north -Z, up +Y.
- [x] Add safe generator-owned collection and material cleanup.
- [x] Stop instead of deleting untagged conflicting Blender content.
- [x] Create 16 stable modular piece definitions.
- [x] Include straight, outer, and inner city-wall variants.
- [x] Include central gate structure, left/right towers, and left/right
      wall-to-tower connectors.
- [x] Preserve a 14 m wide and 12 m high open gate passage.
- [x] Include battlements, access stairs, and access platform pieces.
- [x] Include straight road, left/right curved roads, road intersection, and
      straight road edging.
- [x] Create separate render and simplified collision generation for every piece.
- [x] Create a Blender-only reference assembly aligned to the permanent markers.
- [x] Terminate the west and east reference walls exactly at X -210 and +210.
- [x] Align the gate and northbound road to `(0, 9, 3835)`.
- [x] Register 16 render paths and 16 collision paths in a valid manifest.
- [x] Create an explicitly pending manifest when Blender is unavailable.
- [x] Create `BlenderSource/floor_001/logs/floor_001_north_gate_architecture.log`.
- [x] Create beginner-friendly generation and future-placement documentation.
- [x] Create `docs/handoffs/HANDOFF_MILESTONE_15A.md`.
- [x] Pass Python compilation and 117 architecture preflight checks.
- [x] Confirm zero gate/road, west-wall, and east-wall alignment error.
- [x] Confirm no terrain mesh or production scene was modified.

### Local Blender 5.1.2 completion required

- [x] Run `generate_floor_001_north_gate_architecture.py` in Blender 5.1.2.
- [x] Confirm the generator creates only `Floor001NorthGateArchitecture` through the saved source and generation log.
- [x] Confirm `KitRender` contains 16 reusable piece roots.
- [x] Confirm `KitCollision` contains 16 simplified collision roots.
- [x] Confirm `ReferenceAssembly` records zero error against all four locked markers.
- [x] Confirm the gate passage remains open in render and collision data.
- [x] Confirm the manifest records the road and gate forward direction as negative Godot Z.
- [x] Confirm exactly 16 render GLBs are exported.
- [x] Confirm exactly 16 collision GLBs are exported.
- [x] Confirm `floor_001_north_gate_architecture.blend` is saved.
- [x] Confirm manifest status is `complete_blender_exports_generated`.
- [x] Confirm manifest actual GLB count is 32.
- [x] Confirm the log and manifest report Blender execution and exports as true.
- [ ] Rerun the script and confirm unrelated Blender objects remain untouched.
- [x] Confirm all 32 Godot `.import` records exist in the uploaded project.
- [ ] Confirm correct one-metre scale, axes, local origins, and placeholder materials.
- [ ] Run all terrain regression scenes unchanged.
- [ ] Press F5 and confirm normal gameplay remains unchanged.

### Explicitly not included

- [x] No production-scene architecture placement.
- [x] No full Starting City, houses, or interiors.
- [x] No final gate, wall, road, shader, texture, or copyrighted SAO material.
- [x] No vegetation, rocks, rivers, water, NPCs, enemies, quests, or navigation.
- [x] No terrain changes.
- [x] No main-game integration.

### Completion gate and next milestone

After the complete local Blender checklist passes, proceed to **Milestone 15B —
North-Gate Godot Import and Production Placement Preview**. Use the completed
architecture manifest, place render and collision assets beneath the existing
production containers in an isolated F6 preview, and keep normal F5 startup and
all existing regression scenes unchanged.



---

## 28. Milestone 15B — North-Gate Godot Import and Production Placement Preview

**Status:** Runtime acceptance failed on road collision; Milestone 15B.1 fix implemented and awaiting local retest  
**Date:** 2026-07-11

This milestone keeps the permanent southern production region unchanged and creates a reusable architecture-only assembly plus an isolated F6 preview. Local testing confirmed that the original concave road collisions wedged the player, so M15C is blocked until the 15B.1 retest passes.

### Completed in the project package

- [x] Preserve the complete outer `aincrad/` structure.
- [x] Read every file under `AincradProject/docs/`.
- [x] Preserve all terrain GLBs, architecture GLBs, Blender generators, manifests, existing previews, player scripts, gameplay systems, SaveManager, `project.godot`, `.uid` files, and `.godot/`.
- [x] Validate manifest status `complete_blender_exports_generated`.
- [x] Validate 16 unique render assets, 16 unique collision assets, and 32 total GLBs.
- [x] Parse all 32 GLBs and confirm non-empty geometry.
- [x] Confirm one unit per metre, north `-Z`, passage width 14 m, and passage height 12 m.
- [x] Confirm the central collision has two side piers and one overhead lintel.
- [x] Reuse the manifest's 30 exact placement records instead of creating duplicate placement data.
- [x] Create `world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn`.
- [x] Create `scripts/world/floor_001_north_gate_assembly.gd`.
- [x] Keep the assembly free of terrain, player, global UI, SaveManager, actors, quests, and navigation.
- [x] Load all 16 render and all 16 collision resources through stable piece IDs.
- [x] Instance render placements below predictable category containers.
- [x] Create StaticBody3D collision only from dedicated collision GLBs.
- [x] Preserve exact matching render and collision transforms.
- [x] Add hidden collision-source visualization for the C key.
- [x] Add placement markers and 0.05-metre alignment validation.
- [x] Create `scenes/world/floor_001_north_gate_preview.tscn`.
- [x] Create `scripts/world/floor_001_north_gate_preview.gd`.
- [x] Instance the permanent southern region, reusable assembly, and existing player separately.
- [x] Add safe F1–F4 teleports without Input Map changes.
- [x] Add G placement-marker, C collision-visual, and B chunk-boundary toggles.
- [x] Add preview-only fall recovery with no save or progression changes.
- [x] Add periodic manifest, asset-count, alignment, passage, player, and terrain debug information.
- [x] Create `docs/floors/FLOOR_001_NORTH_GATE_GODOT_PREVIEW.md`.
- [x] Create `docs/handoffs/HANDOFF_MILESTONE_15B.md`.
- [x] Pass GDScript parsing, `gdlint`, `gdformat --check`, scene-reference, JSON, GLB, placement, and preservation validation.
- [x] Keep `floor_001_southern_region.tscn` unchanged pending local acceptance.

### Local Godot 4.7 acceptance required

- [ ] Open `floor_001_north_gate_assembly.tscn` without missing resources.
- [ ] Run `floor_001_north_gate_preview.tscn` with F6.
- [ ] Confirm manifest status passes.
- [ ] Confirm render assets report 16/16 and collision assets report 16/16.
- [ ] Confirm failed assets remain zero.
- [ ] Confirm gate, west, east, and road alignment errors are at most 0.05 m.
- [ ] Confirm gate forward agrees with negative Z.
- [ ] Walk from F1 through the physically open passage to the city side.
- [ ] Confirm the passage debug state changes while inside.
- [ ] Walk back out through the opening.
- [ ] Test both towers, connectors, walls, road pieces, road edging, stair ramp, and platform collision.
- [ ] Press C and compare the dedicated collision GLBs to the render placement.
- [ ] Press G and inspect stable placement markers.
- [ ] Press F3 and F4 and inspect both wall endpoints.
- [ ] Confirm no large wall gaps, heavy overlap, buried gate, floating road, or blocked passage.
- [ ] Confirm no duplicate render roots, StaticBody3D nodes, or collision shapes accumulate.
- [ ] Trigger preview fall recovery and confirm no save or progression changes.
- [ ] Run all four existing terrain/production regression scenes unchanged.
- [ ] Press F5 and confirm the existing normal game still starts.

### Completion gate and next milestone

After local F6 acceptance and regression testing, proceed to **Milestone 15C — North-Gate Production Acceptance and Provisional Region Integration**. Instance only the reusable assembly beneath `StaticContent/CityGateArchitecture`; do not copy individual GLBs into the production region.

---

## 29. Bugfix Milestone 15B.1 — North-Gate Road Collision

**Status:** Implementation and static validation complete; local Godot 4.7 F6 road retest required  
**Date:** 2026-07-11

### Confirmed failure

- [x] Record that normal movement works on terrain.
- [x] Record that standing or landing on the road prevents horizontal movement.
- [x] Record that teleporting away restores movement.
- [x] Confirm the player controller and player collision shape are unchanged.

### Confirmed cause

- [x] Inspect all road, curve, intersection, and edging collision GLBs.
- [x] Confirm the placed straight road uses a thin concave trimesh slab.
- [x] Confirm its top triangles face downward and bottom triangles face upward.
- [x] Confirm the slab bottom is at world Y 9.02 while terrain intersects or
      closely approaches that level.
- [x] Confirm adjacent modules contain coincident vertical end faces.
- [x] Confirm the intersection collision contains two overlapping slabs.
- [x] Confirm the six concave edging bodies also overlap the terrain near the
      road boundary.
- [x] Confirm manifest placement IDs are unique and runtime rebuild cleanup is
      not duplicating collision bodies.

### Fix implemented

- [x] Preserve all render GLBs, collision GLBs, manifest data, and Blender source.
- [x] Keep all 16 collision resources loaded and validated.
- [x] Disable flat road physics by default.
- [x] Disable road-edging physics by default.
- [x] Use streamed terrain collision as the authoritative walking surface.
- [x] Keep walls, towers, gate piers, connectors, stairs, and platform collision.
- [x] Preserve the C collision-source visualization toggle.
- [x] Show active collision sources in red and disabled road sources in amber.
- [x] Add road body, shape, disabled-placement, duplicate, and transform debug
      diagnostics.
- [x] Add road-render surface versus terrain-height diagnostics.
- [x] Keep terrain, player movement, terrain streaming, SaveManager,
      `project.godot`, `.uid`, and `.godot/` unchanged.

### Local road retest required

- [ ] Confirm flat road collision reports OFF.
- [ ] Confirm road edging collision reports OFF.
- [ ] Confirm active road collision bodies and shapes report zero.
- [ ] Confirm disabled road placements report nine.
- [ ] Confirm duplicate collision placements report zero.
- [ ] Walk from terrain onto the visible road.
- [ ] Walk and sprint along all three straight modules.
- [ ] Cross every module join in both directions.
- [ ] Jump and land on every module.
- [ ] Jump and land across both joins.
- [ ] Walk from road back to terrain.
- [ ] Walk beside both road edges without wedging.
- [ ] Walk through the gate passage in both directions.
- [ ] Confirm gate piers, walls, towers, stairs, and platform still collide.
- [ ] Run every terrain and southern-region regression preview unchanged.
- [ ] Press F5 and confirm normal gameplay remains unchanged.

### Completion gate

Do not begin Milestone 15C until every road traversal, architecture collision,
terrain regression, and F5 check above passes locally.

