# Decision Log

**Project:** Aincrad-Inspired RPG  
**Format:** Lightweight architecture decision record  
**Last updated:** 2026-07-10

---

## 1. Purpose

This file records decisions that affect the whole project.

Use it when a decision:

- Changes architecture.
- Changes scope.
- Adds a major dependency.
- Changes save compatibility.
- Changes multiplayer direction.
- Changes folder or naming rules.
- Replaces an earlier accepted decision.

Do not use it for every tiny code change.

---

## 2. Status Values

```text
Proposed
Accepted
Superseded
Rejected
Deprecated
```

---

## 3. Entry Template

Copy this template for future decisions:

```markdown
## D-XXX — Decision title

**Date:** YYYY-MM-DD  
**Status:** Proposed  
**Decision owner:** Lead developer

### Context

Why is this decision needed?

### Decision

What are we choosing?

### Consequences

What becomes easier, harder, required, or prohibited?

### Alternatives considered

What other reasonable options were considered?

### Follow-up

What tasks or document updates are required?
```

---

## D-001 — Build a Floor 1 Vertical Slice First

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Building 100 floors before proving the player loop would create an unmanageable amount of unfinished content and make architecture mistakes expensive.

### Decision

Build one small but complete Floor 1 prototype before creating additional floors.

The prototype must eventually include:

- Third-person player.
- Starting City section.
- Road.
- Field.
- One enemy.
- Sword combat.
- Health.
- Experience and levelling.
- One NPC.
- One quest.
- Saving and loading.

### Consequences

- Floor 2 and later floors are postponed.
- Systems must be tested through one complete route.
- World size is intentionally limited.
- The first success measure is completeness, not map size.

### Alternatives considered

- Build all floors as empty terrain first.
- Build the entire Floor 1 map first.
- Begin with multiplayer infrastructure before gameplay.

These alternatives were rejected because they delay a playable result.

### Follow-up

Use `CURRENT_TASKS.md` to keep work focused on the current milestone.

---

## D-002 — Use Godot 4.7

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The project needs one fixed engine target so scripts, scenes, documentation, and troubleshooting remain consistent.

### Decision

Use Godot 4.7 for the prototype.

### Consequences

- All project instructions should target Godot 4.7.
- Plugins must be checked for Godot 4.7 compatibility.
- Engine upgrades require a new decision-log entry and a tested migration branch.
- Team members should not casually open and resave the project in another engine version.

### Alternatives considered

- Godot 4.6.
- Tracking the latest development build.
- Another engine.

### Follow-up

Record any later engine upgrade as a separate decision.

---

## D-003 — Use Typed GDScript

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The project may eventually contain many systems and contributors. Untyped code makes large refactors and beginner debugging harder.

### Decision

Use statically typed GDScript for all project-owned gameplay code wherever Godot supports a useful type.

### Consequences

- Functions include parameter and return types.
- Variables include types.
- Collections should be typed where practical.
- Warnings caused by unsafe typing should be reviewed.
- Third-party plugin code does not need to be rewritten only to match this rule.

### Alternatives considered

- Fully dynamic GDScript.
- C#.
- Mixed GDScript and C# from the beginning.

### Follow-up

Use the examples and code order in `NAMING_CONVENTIONS.md`.

---

## D-004 — Organise the Project by Feature and World Content

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

A project-wide `scripts/` folder and `scenes/` folder become difficult to navigate as the number of actors, systems, and floors grows.

### Decision

Keep related scenes, scripts, components, and local resources near their feature.

Keep floor-specific content inside:

```text
res://game/world/floors/floor_XXX/
```

Keep reusable gameplay systems outside individual floor folders.

### Consequences

- Player files live near other player files.
- Quest files live near quest files.
- Floor 1 content cannot become the hidden home of reusable systems.
- Moving a feature is simpler because its files are grouped.

### Alternatives considered

- Separate global folders for all scripts, scenes, and resources.
- Store every file under Floor 1 until another floor is created.

### Follow-up

Create the root structure from `TECHNICAL_ARCHITECTURE.md`.

---

## D-005 — Divide Floors Into Zones and Chunks

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

A complete large floor may contain cities, fields, dungeons, actors, navigation, and detailed art. Loading everything at once will not scale.

### Decision

Treat each floor as a collection of zones and potentially smaller loadable chunks.

The first prototype may load its small areas together, but their content should remain logically separated.

### Consequences

- City, road, and field should not become one inseparable scene.
- Future streaming can be added without completely reorganising content.
- Floor testing can target individual zones.
- Cross-zone persistence will require stable IDs.

### Alternatives considered

- One scene per entire floor.
- One scene containing every floor.
- Procedural generation as the only world format.

### Follow-up

Do not implement streaming until the prototype scale requires it.

---

## D-006 — Use Resource-Driven Definitions

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Enemy, quest, item, and floor values should be editable without duplicating logic across scenes.

### Decision

Use custom Godot `Resource` classes for reusable definition data where they improve clarity.

Potential definitions include:

- Enemy definitions.
- Quest definitions.
- Item definitions.
- Actor statistics.
- Floor definitions.
- Zone definitions.

### Consequences

- Shared design values are separated from live runtime state.
- Designers can create several content definitions using the same behaviour.
- Resources must not be mistaken for per-instance mutable state.
- Stable IDs are required inside persistent definitions.

### Alternatives considered

- Hard-code all values in scripts.
- Put all values directly on large scenes.
- Store all data in one untyped dictionary.

### Follow-up

Create each resource class only when its gameplay milestone begins.

---

## D-007 — Keep Autoloads Minimal

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Autoloads are convenient but can create hidden dependencies and a giant global game manager.

### Decision

Add an autoload only when a service truly needs application-wide lifetime or access.

Possible future examples:

- Scene routing.
- Save coordination.
- Game settings.
- Network session coordination.

No autoload is required during the documentation milestone.

### Consequences

- Most systems remain normal scenes, nodes, resources, or plain classes.
- Every new autoload requires a clear responsibility.
- Global mutable state is reduced.
- Some dependencies must be passed explicitly.

### Alternatives considered

- One global `GameManager` containing all systems.
- Make every major system an autoload.
- Ban autoloads completely.

### Follow-up

Record each major future autoload in this log.

---

## D-008 — Build Single-Player First but Preserve Multiplayer Boundaries

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The long-term concept includes real players, but networking every unfinished gameplay feature would slow development and complicate debugging.

### Decision

Complete the local Floor 1 gameplay loop first.

While doing so:

- Do not assume only one actor can exist.
- Separate input requests from authoritative results.
- Keep local camera and UI separate from replicated state.
- Use stable IDs for persistent or network-relevant content.
- Avoid saving raw node references.

### Consequences

- No multiplayer code is required in early milestones.
- Some interfaces and method parameters must be actor-aware.
- Networking can later wrap tested gameplay rather than replace it.
- Full multiplayer behaviour is not promised by architecture alone.

### Alternatives considered

- Build multiplayer before movement and combat.
- Ignore multiplayer completely until the entire game is built.
- Use peer-to-peer trust for all permanent results.

### Follow-up

Begin the first networking technical test only after the local prototype is complete.

---

## D-009 — Use Versioned Save Data and Stable IDs

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Scenes, visible names, and file paths will change as the project develops. Saves must survive reasonable restructuring.

### Decision

Save clean data using stable content IDs and include a save-format version.

Do not serialize complete live scene trees as the main save strategy.

### Consequences

- Persistent objects require planned IDs.
- Save loading must validate missing or invalid data.
- Future format changes may require migration.
- Renaming display text does not break saves.
- Changing a stable ID requires an explicit migration decision.

### Alternatives considered

- Save node paths.
- Save visible names.
- Serialize entire scene instances.
- Delay all save planning until the end.

### Follow-up

Define the first save schema during the saving milestone.

---

## D-010 — Keep Production Content Original

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The project is inspired by the floating-floor structure and adventure feeling of Aincrad. Directly copying protected characters, maps, logos, music, dialogue, or assets would restrict safe public distribution.

### Decision

Develop an original game world, story, names, visual identity, interface, characters, and assets.

Temporary internal references may be used for orientation, but public-facing content must become original.

### Consequences

- The project can retain the multi-floor fantasy concept.
- Existing franchise assets should not enter the production repository.
- Worldbuilding must eventually define an original setting.
- Placeholder names must be reviewed before public builds.

### Alternatives considered

- Attempt a one-to-one commercial recreation.
- Use copied assets as permanent content.
- Make no distinction between inspiration and production content.

### Follow-up

Choose an original working title and original Floor 1 place names.

---

## D-011 — Target Windows PC First

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Supporting many platforms during the first prototype would increase testing and interface requirements.

### Decision

Target Windows PC first with keyboard and mouse as the initial control method.

### Consequences

- Early testing focuses on one platform.
- Controller support is postponed.
- Other desktop or console targets remain possible later.
- Platform-specific assumptions should still be kept out of core gameplay where practical.

### Alternatives considered

- Support Windows, Linux, macOS, consoles, and mobile from the beginning.
- Target mobile first.
- Require controller support in the first movement milestone.

### Follow-up

Review controller support after the keyboard-and-mouse player prototype works.

---

## D-012 — Renderer Choice Remains Open Until Project Creation

**Date:** 2026-07-10  
**Status:** Proposed  
**Decision owner:** Lead developer

### Context

Godot project creation requires a renderer choice. The best initial option depends on the development computer, visual target, and performance needs.

### Decision

Choose either Compatibility or Forward+ when creating the real project, then replace this proposed entry with an accepted renderer decision.

### Consequences

- Folder and documentation work can proceed immediately.
- Rendering features should not be designed around an unrecorded assumption.
- The selected renderer must be tested on the actual development computer.

### Alternatives considered

- Select a renderer without checking the machine.
- Treat the renderer as unimportant and never record it.

### Follow-up

Update this entry during M0 project setup.
