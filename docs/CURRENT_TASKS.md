# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M2 — Reusable Third-Person Interaction  
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

Add a reusable third-person interaction system without redesigning the working movement controller.

The player should be able to aim the third-person camera at one nearby interactable, see a prompt, and press E to interact.

This milestone contains three primitive test objects:

- A readable sign.
- A placeholder NPC with one dialogue line.
- A one-use chest.

Combat, inventory, quests, saving, multiplayer, and detailed dialogue remain outside this milestone.

---

## 3. M0 — Project Foundation

- [x] Create the five core project documents.
- [x] Define the Floor 1 vertical-slice scope.
- [x] Define naming and architecture rules.
- [x] Use Godot 4.7 and typed GDScript.
- [x] Select the Compatibility renderer for early greybox work.
- [x] Record the temporary beginner-facing path structure.
- [ ] Initialise Git in the user's working copy.
- [ ] Add the Godot `.gitignore`.
- [ ] Make the first local commit.

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
- [x] Add player facing rotation.
- [x] Add Escape mouse capture toggling.
- [x] Add collision floor, cubes, ramps, lighting, and environment.

### Local verification

- [~] Open and test M1 in the user's Godot 4.7 editor.
- [ ] Confirm movement and camera behaviour.
- [ ] Confirm jumping, gravity, and sprinting.
- [ ] Confirm collision on the floor, ramps, and cubes.
- [ ] Confirm no critical debugger errors.

The existing player controller remains unchanged during M2.

---

## 5. M2 — Reusable Third-Person Interaction

### Base interaction architecture

- [x] Create `res://scripts/interactions/interactable.gd`.
- [x] Use a reusable `Interactable` base class.
- [x] Add typed availability, prompt, and interaction methods.
- [x] Return optional display text from interactions.
- [x] Keep quest, inventory, combat, saving, and networking logic out.

### Player interaction detection

- [x] Create `res://scripts/interactions/player_interactor.gd`.
- [x] Add one camera-mounted `RayCast3D`.
- [x] Limit interaction using player-to-object distance.
- [x] Allow only the ray's closest valid object to be targeted.
- [x] Ignore the player's own collision body.
- [x] Stop world geometry from being interacted through.
- [x] Validate required scene nodes.
- [x] Validate the `interact` Input Map action.
- [x] Press E to call the target's interaction method.
- [x] Leave `player_controller.gd` unchanged.

### Interaction UI

- [x] Create `res://scenes/ui/interaction_ui.tscn`.
- [x] Create `res://scripts/ui/interaction_ui.gd`.
- [x] Show a prompt while a valid object is targeted.
- [x] Hide the prompt when no valid object is targeted.
- [x] Display short interaction messages.
- [x] Automatically hide messages after a timer.
- [x] Add missing-node error checks.

### Test interactables

- [x] Create the primitive sign scene and script.
- [x] Make the sign display a short message.
- [x] Create the primitive placeholder NPC scene and script.
- [x] Make the NPC display one dialogue line.
- [x] Create the primitive chest scene and script.
- [x] Make the chest animate open only once.
- [x] Remove the chest as a valid target after opening.
- [x] Add all three test objects to the greybox world.

### Input and scene integration

- [x] Add the `interact` Input Map action.
- [x] Bind `interact` to the physical E key.
- [x] Add `InteractionRayCast` beneath the existing camera.
- [x] Add `PlayerInteractor` to the player scene.
- [x] Instance `InteractionUI` in the player scene.
- [x] Preserve the existing movement controller and main scene.

### Local verification still required

- [~] Open the project in Godot 4.7.
- [ ] Confirm all new scripts parse without errors.
- [ ] Confirm all new scenes load without missing-resource errors.
- [ ] Press F5 and walk toward the sign.
- [ ] Aim at the sign and confirm its prompt appears.
- [ ] Look away and confirm the prompt disappears.
- [ ] Press E and confirm the sign message appears.
- [ ] Aim at the NPC and confirm only the NPC is targeted.
- [ ] Press E and confirm one dialogue line appears.
- [ ] Aim at the chest and press E.
- [ ] Confirm the chest lid opens.
- [ ] Confirm the chest prompt disappears after opening.
- [ ] Confirm the chest cannot open a second time.
- [ ] Confirm distant objects do not show a prompt.
- [ ] Confirm cubes or walls block the interaction ray.
- [ ] Confirm WASD, mouse camera, jump, sprint, and Escape still work.
- [ ] Confirm no critical errors appear in the debugger.

M2 is complete after these local checks pass.

---

## 6. Current Work Limit

Do not add the following during M2 testing:

- Combat.
- Weapons.
- Enemies.
- Health.
- Experience or levels.
- Quest state.
- Inventory or item rewards.
- Saving or loading.
- Multiplayer code.
- Shop purchasing.
- Full dialogue trees.
- Floor transitions.
- Blender models.
- External art packs.

The interaction base may support these later, but this milestone only proves detection, prompting, and method calls.

---

## 7. Next Milestone Preview

## M3 — Health and Basic Sword Combat

Planned tasks:

- [ ] Create a reusable health component.
- [ ] Create basic hitbox and hurtbox boundaries.
- [ ] Add one primitive sword placeholder.
- [ ] Add one basic attack.
- [ ] Keep enemy behaviour outside the first combat step.
- [ ] Preserve the interaction system.

Begin M3 only after M2 passes local testing.

---

## 8. Updated Milestone Order

### M0 — Project Foundation

Documentation, decisions, project settings, and version control preparation.

### M1 — Bootstrap and Third-Person Greybox

Main scene, primitive world, movement, camera, jump, sprint, gravity, and mouse capture.

### M2 — Reusable Third-Person Interaction

Camera targeting, prompt UI, one-line interactions, a sign, an NPC, and a one-use chest.

### M3 — Health and Basic Sword Combat

Health components, one sword attack, hit detection, and damage.

### M4 — First Enemy

One enemy type with simple behaviour and defeat handling.

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

## 9. Definition of Done for Any Task

A task is done when:

- The requested behaviour or document exists.
- Names follow the project rules or an accepted decision-log exception.
- Typed GDScript is used.
- Required scene references are validated.
- The result has been tested in Godot 4.7.
- No new critical errors are present.
- Relevant documentation is updated.
- The change is ready for a focused Git commit.

---

## 10. Next Action

Extract the M2 package, open `project.godot` in Godot 4.7, press F5, and complete the M2 local verification checklist above.
