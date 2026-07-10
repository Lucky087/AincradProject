# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M4 — First Enemy  
**Current phase:** Implementation package created; local Godot verification remains  
**Last updated:** 2026-07-10

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

Add one reusable hostile boar enemy without replacing the working player, interaction, health, or sword-combat systems.

The milestone should prove that:

- One primitive enemy can idle, detect, chase, attack, return, die, and respawn.
- Enemy damage reaches the player's existing `HealthComponent`.
- The existing sword damages the enemy through the existing hurtbox system.
- One enemy attack can damage the player at most once.
- Attack damage is rejected when the player has moved too far away or a world body blocks the attack line.
- The enemy stops moving and attacking after death.
- The enemy returns to its exact original spawn after the respawn timer.
- All earlier movement, camera, interaction, health UI, sword, and training-dummy behaviour remains available.

Experience, loot, quests, inventory, saving, bosses, multiplayer, and detailed art remain outside this milestone.

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

## 8. Current Work Limit

Do not add the following during M4:

- Loot or item drops.
- Experience or level rewards.
- Inventory or equipment systems.
- Quest progress.
- Boss phases or special mechanics.
- Multiplayer or network authority code.
- Saving or loading.
- Advanced pathfinding or crowd avoidance.
- Complex animation trees.
- Blocking, dodging, stamina, or lock-on targeting.
- Blender models, external assets, or detailed environments.

The first boar is only a small hostile-enemy behaviour test.

---

## 9. Next Milestone Preview

## M5 — Progression

Planned tasks:

- [ ] Add reusable experience data and level calculations.
- [ ] Award experience only after a valid enemy defeat.
- [ ] Add current level and experience to the HUD.
- [ ] Prevent repeated rewards from one enemy death.
- [ ] Keep progression separate from enemy movement and combat logic.
- [ ] Preserve all M1–M4 behaviour.

Begin M5 only after M4 passes local testing.

---

## 10. Updated Milestone Order

### M0 — Project Foundation

Documentation, decisions, project settings, and version-control preparation.

### M1 — Bootstrap and Third-Person Greybox

Main scene, primitive world, movement, camera, jump, sprint, gravity, and mouse capture.

### M2 — Reusable Third-Person Interaction

Camera targeting, prompt UI, one-line interactions, a sign, an NPC, and a one-use chest.

### M3 — Health and Basic Sword Combat

Reusable health, player HUD, primitive sword, attack hitbox, training-dummy hurtbox, and damage.

### M4 — First Enemy

One hostile primitive boar with detection, chase, attack, hit, death, return, and respawn behaviour.

### M5 — Progression

Experience, levels, and basic HUD display.

### M6 — First Quest

One accept-track-complete quest.

### M7 — Floor 1 Vertical Slice

Starting City section, road, field, landmarks, and complete route.

### M8 — Saving and Loading

Versioned save data and reliable restore flow.

### M9 — Prototype Polish

Feedback, audio, bug fixing, performance review, and full playthrough testing.

### M10 — Multiplayer Technical Test

Only after the complete local prototype works.

---

## 11. Definition of Done for Any Task

A task is done when:

- The requested behaviour or document exists.
- Names follow the project rules or an accepted decision-log exception.
- Typed GDScript is used.
- Required scene references are validated.
- The result has been tested in Godot 4.7.
- No new critical errors are present.
- Existing completed behaviour still works.
- Relevant documentation is updated.
- The change is ready for a focused Git commit.

---

## 12. Next Action

Open the project in Godot 4.7 and complete every M4 local-verification checkbox, including regression tests for movement, interaction, sword combat, the training dummy, and the player health UI.
