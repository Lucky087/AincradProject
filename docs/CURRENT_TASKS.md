# Current Tasks

**Project:** Aincrad-Inspired RPG  
**Current milestone:** M0 — Project Foundation  
**Current phase:** Documentation and folder setup only  
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

Create a clean Godot 4.7 project foundation before implementing gameplay.

Milestone M0 is complete when:

- The project opens correctly in Godot 4.7.
- The agreed folder structure exists.
- The five core documents exist in `res://docs/`.
- Naming rules are understood.
- Initial technical decisions are recorded.
- Version control is ready.
- No gameplay system has been prematurely implemented.

---

## 3. M0 — Project Foundation

### Project creation

- [ ] Create a new Godot 4.7 project.
- [ ] Give the project a temporary original working title.
- [ ] Confirm the project opens without errors.
- [ ] Confirm `project.godot` is in the project root.
- [ ] Choose a renderer.
- [ ] Record the renderer decision in `DECISION_LOG.md`.
- [ ] Set up Git version control.
- [ ] Add the correct Godot `.gitignore`.
- [ ] Make an initial clean commit.

### Folder structure

- [ ] Create `res://addons/`.
- [ ] Create `res://assets/` and its initial subfolders.
- [ ] Create `res://core/` and its initial subfolders.
- [ ] Create `res://docs/`.
- [ ] Create `res://game/` and its feature folders.
- [ ] Create `res://game/world/floors/floor_001/`.
- [ ] Create `res://multiplayer/`.
- [ ] Create `res://tests/`.
- [ ] Create `res://app/`.
- [ ] Confirm folder names follow `NAMING_CONVENTIONS.md`.

### Documentation

- [x] Define the project vision and prototype scope.
- [x] Define the initial technical architecture.
- [x] Define naming conventions.
- [x] Create the current task list.
- [x] Create the initial decision log.
- [ ] Copy all five files into `res://docs/`.
- [ ] Read each document once inside the project.
- [ ] Correct any paths that differ from the real local setup.
- [ ] Commit the documentation.

### Project settings review

- [ ] Confirm Godot version is 4.7.
- [ ] Record the chosen renderer.
- [ ] Record the intended initial platform as Windows PC.
- [ ] Do not configure final graphics settings yet.
- [ ] Do not create the full Input Map yet.
- [ ] Do not add autoloads yet.

### Architecture check

- [ ] Confirm Floor 1 has its own folder.
- [ ] Confirm reusable systems are outside the Floor 1 folder.
- [ ] Confirm networking has a separate future-facing folder.
- [ ] Confirm saves will use stable IDs and a format version.
- [ ] Confirm no design requires all 100 floors to be loaded.
- [ ] Confirm the project does not assume all future code belongs in one manager.

---

## 4. Current Work Limit

Do not begin these features during M0:

- Third-person movement.
- Camera controls.
- Sword combat.
- Health.
- Enemy artificial intelligence.
- Experience.
- Levelling.
- Dialogue.
- Quests.
- Saving and loading.
- Multiplayer.
- Final city art.
- Full Floor 1 terrain.
- Any additional floors.

The purpose of M0 is to prevent these systems from being built on an unclear foundation.

---

## 5. Next Milestone Preview

## M1 — Bootstrap and Development Test Scene

M1 should begin only after M0 is complete.

Planned M1 tasks:

- [ ] Create `res://app/bootstrap/bootstrap.tscn`.
- [ ] Create `res://app/bootstrap/bootstrap.gd`.
- [ ] Create `res://app/main/game_root.tscn`.
- [ ] Create a minimal development test scene.
- [ ] Set the bootstrap scene as the main scene.
- [ ] Confirm project startup flow.
- [ ] Add no combat or quest code.
- [ ] Document how to run the project.

M1 should prove the application starts through a controlled entry point.

---

## 6. Future Milestone Order

This order is provisional and may be changed in the decision log.

### M0 — Project Foundation

Documentation, folders, version control, and conventions.

### M1 — Bootstrap and Test World

Application startup, game root, and a simple test environment.

### M2 — Third-Person Player

Movement, camera, basic animation, and input separation.

### M3 — Interaction and NPC

Interaction detection, one NPC, and simple dialogue.

### M4 — Health and Combat

Health components, sword attack, hit detection, and damage.

### M5 — First Enemy

One enemy type with simple behaviour and defeat handling.

### M6 — Progression

Experience, level calculation, and basic HUD display.

### M7 — Quest

One accept-track-complete quest.

### M8 — Floor 1 Vertical Slice

Starting City section, road, field, landmarks, and complete route.

### M9 — Saving and Loading

Versioned save data and reliable restore flow.

### M10 — Prototype Polish

Audio, feedback, bug fixing, optimisation, and complete playthrough test.

### M11 — Multiplayer Technical Test

Only after the complete local prototype works.

---

## 7. Task Selection Rule

Work on one small task at a time.

A task should ideally produce one testable result.

Good task:

```text
Create the bootstrap scene and make it print a startup confirmation.
```

Too large:

```text
Create the full player, combat, multiplayer, and Floor 1.
```

When a task grows, divide it before coding.

---

## 8. Definition of Done for Any Task

A task is done when:

- The requested behaviour or document exists.
- Names follow the project rules.
- Typed GDScript is used when code exists.
- The project runs without new critical errors.
- The result has been tested.
- Relevant documentation is updated.
- The change has a focused Git commit.
- Temporary debug code is removed or clearly labelled.

---

## 9. Bug Priority

Use these priorities later:

### P0 — Critical

The project cannot start, save data is destroyed, or development is blocked.

### P1 — High

A required prototype feature cannot be completed.

### P2 — Medium

A feature works incorrectly but has a workaround.

### P3 — Low

Minor visual, usability, naming, or polish issue.

---

## 10. Current Questions to Resolve

Record the answer to each question in `DECISION_LOG.md`.

- [ ] What is the original working title?
- [ ] Which renderer will the project use initially?
- [ ] Which Git hosting service will store the repository?
- [ ] Will placeholder art come from primitive meshes, original Blender assets, or licensed asset packs?
- [ ] What minimum computer specification should the prototype target?
- [ ] Will the first prototype use keyboard and mouse only?
- [ ] What internal measurement and scale rules will environment artists follow?

None of these questions should block copying the documentation and creating folders.

---

## 11. Latest Completed Work

- [x] Reduced the immediate goal from 100 floors to one Floor 1 vertical slice.
- [x] Defined the eventual prototype feature list.
- [x] Chosen Godot 4.7.
- [x] Chosen typed GDScript.
- [x] Established a multiplayer-aware but single-player-first direction.
- [x] Established a floor and zone folder strategy.
- [x] Established stable ID and versioned-save requirements.

---

## 12. Next Action

Create the Godot project and copy this documentation folder into:

```text
res://docs/
```

Then create the root folders listed in `TECHNICAL_ARCHITECTURE.md`.
