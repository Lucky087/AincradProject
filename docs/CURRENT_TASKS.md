# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M3 — Health and Basic Sword Combat  
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

Add reusable health and the first basic sword attack without replacing the working player controller or interaction system.

The milestone should prove that:

- The player and future actors can use the same health component.
- A primitive player sword can perform one basic attack.
- A forward attack hitbox can find a dedicated hurtbox.
- One target takes damage only once per swing.
- A primitive training dummy can be defeated and reset for repeated testing.
- The player has a reusable health HUD ready for future incoming damage.

Enemy movement, enemy attacks, experience, quests, inventory, saving, and multiplayer remain outside this milestone.

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

## 7. Current Work Limit

Do not add the following during M3 testing:

- Enemy movement or artificial intelligence.
- Enemy attacks or player death handling.
- Experience or levels.
- Quest state.
- Inventory, equipment menus, or item rewards.
- Saving or loading.
- Multiplayer code.
- Advanced combos.
- Blocking, dodging, stamina, or lock-on targeting.
- Damage numbers or advanced effects.
- Blender models or external art packs.

The current combat system is only the smallest reusable damage test.

---

## 8. Next Milestone Preview

## M4 — First Enemy

Planned tasks:

- [ ] Create one primitive enemy type.
- [ ] Add a small state-based behaviour controller.
- [ ] Add idle, detection, chase, attack, hurt, and defeated states.
- [ ] Reuse `HealthComponent`.
- [ ] Reuse the existing hurtbox boundary.
- [ ] Add an enemy attack boundary that can damage the player.
- [ ] Add basic player death or reset behaviour only as required for testing.
- [ ] Preserve movement, interaction, and M3 combat.

Begin M4 only after M3 passes local testing.

---

## 9. Updated Milestone Order

### M0 — Project Foundation

Documentation, decisions, project settings, and version-control preparation.

### M1 — Bootstrap and Third-Person Greybox

Main scene, primitive world, movement, camera, jump, sprint, gravity, and mouse capture.

### M2 — Reusable Third-Person Interaction

Camera targeting, prompt UI, one-line interactions, a sign, an NPC, and a one-use chest.

### M3 — Health and Basic Sword Combat

Reusable health, player HUD, primitive sword, attack hitbox, training-dummy hurtbox, and damage.

### M4 — First Enemy

One enemy type with simple behaviour, attacks, and defeat handling.

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

## 10. Definition of Done for Any Task

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

## 11. Next Action

Open the project in Godot 4.7 and complete every M3 local-verification checkbox before beginning M4.
