# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M6 — First Quest  
**Current phase:** Quest implementation package created; local Godot verification remains  
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

Add one reusable quest-definition and player quest-log system, connect valid wild-boar defeats to objective progress, add a new primitive quest giver, and display one complete accept-track-turn-in quest without replacing any working M1–M5 system.

The milestone should prove that:

- `boar_hunt` is a stable quest ID stored in a reusable resource.
- The quest supports Not Started, Active, Ready to Turn In, and Completed states.
- The Road Warden presents the offer before acceptance.
- Only boar defeats after acceptance count.
- The stable objective ID `wild_boar` reaches exactly 3 / 3.
- The existing 40 XP reward still applies to every valid boar death.
- The quest waits for the player to return before granting its 100 XP reward.
- Quest progress and reward ownership use the killing damage source and `players` group.
- One spawned boar life reports objective progress at most once.
- The completed quest can never grant its reward again.
- A separate quest tracker updates from signals and does not replace health or progression UI.
- All movement, interaction, health, combat, dummy, boar AI, and levelling behavior remains available.

Inventory, item rewards, gold, multiple quests, quest chains, saving, multiplayer, and detailed art remain outside this milestone.

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

## 10. Current Work Limit

Do not add the following during M6:

- Inventory, equipment, item rewards, loot, or gold.
- Shops or economy systems.
- Additional quests or quest chains.
- Save files or quest persistence.
- Multiplayer or network authority code.
- Boss mechanics.
- Detailed dialogue trees or cinematic presentation.
- Detailed effects, animation trees, or external assets.

M6 is only the reusable quest definition, player quest log, Boar Hunt flow, quest giver, boar progress report, and quest tracker.

---

## 11. Next Milestone Preview

## M7 — Floor 1 Vertical Slice

Planned tasks:

- [ ] Replace the single test-space layout with a small Starting City section, road, and field while preserving the reusable systems.
- [ ] Place the Road Warden, interactables, training target, and boar encounters into a readable route.
- [ ] Add landmarks and blocked future paths using primitive greybox geometry.
- [ ] Preserve the complete Boar Hunt loop.
- [ ] Keep large-world zones and future floor separation in mind without implementing all floors.

Begin M7 only after M6 passes local testing.

---

## 12. Updated Milestone Order

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

## 13. Definition of Done for Any Task

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

## 14. Next Action

Open the project in Godot 4.7 and complete every M6 local-verification checkbox, especially this exact quest sequence:

```text
Before acceptance: boar gives 40 XP, quest remains hidden
Accept quest:      Boar Hunt appears at 0 / 3
First valid kill:  1 / 3 plus normal 40 boar XP
Second valid kill: 2 / 3 plus normal 40 boar XP
Third valid kill:  Return to the quest giver plus normal 40 boar XP
Turn in quest:     receive exactly 100 quest XP
Talk again:        no additional quest XP
```

Also run the full M1–M5 regression checklist before considering M6 complete.
