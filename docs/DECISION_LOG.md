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

## D-012 — Use the Compatibility Renderer for the Greybox Prototype

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The first runnable milestone uses only primitive meshes, basic lighting, and a simple environment. Broad hardware compatibility and easy startup are more important than advanced rendering features at this stage.

### Decision

Use Godot's Compatibility renderer for the initial greybox project.

The project may move to Forward+ later if the final visual target requires its desktop rendering features.

### Consequences

- The primitive test milestone should run on a wider range of development computers.
- The current project does not depend on advanced Forward+ effects.
- Renderer-specific visual work is postponed.
- Changing to Forward+ later requires testing and a new decision-log entry.

### Alternatives considered

- Use Forward+ immediately.
- Leave the renderer unrecorded.

### Follow-up

Test the Compatibility build on the development computer before adding detailed environment art.

---

## D-013 — Combine Bootstrap and Basic Player Into One Runnable Greybox Milestone

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The project foundation is documented, and the next useful result is a small scene that can be opened and tested immediately. A bootstrap-only scene would not yet prove movement, camera behaviour, jumping, gravity, or collision.

### Decision

Combine the earlier bootstrap milestone and basic third-person-player milestone into one contained milestone named **M1 — Bootstrap and Third-Person Greybox**.

The milestone includes only:

- A main scene.
- A primitive test world.
- A `CharacterBody3D` player.
- Camera-relative movement.
- Mouse camera control.
- Jumping and gravity.
- Hold-to-sprint.
- Visual facing rotation.
- Mouse capture toggling.

### Consequences

- The first runnable build provides a meaningful movement test.
- Primitive shapes are used instead of external assets.
- Combat, enemies, NPCs, quests, saving, inventory, and multiplayer remain postponed.
- The next milestone becomes interaction and one NPC.

### Alternatives considered

- Create only an empty bootstrap scene.
- Add combat and enemies at the same time.
- Build detailed Floor 1 art before testing movement.

### Follow-up

Complete every local verification item in `CURRENT_TASKS.md` before beginning M2.

---

## D-014 — Use Requested Beginner-Facing Scene and Script Paths for M1

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The long-term architecture prefers feature-oriented folders that keep related scenes, scripts, and resources together. The requested first milestone uses explicit beginner-facing paths:

```text
res://scenes/player/player.tscn
res://scripts/player/player_controller.gd
res://scenes/world/test_world.tscn
res://scenes/main.tscn
```

### Decision

Use the requested paths for M1 as a documented temporary exception.

The long-term feature-oriented direction in D-004 remains the target. Before the project gains many gameplay systems, review whether the player and world files should migrate into the long-term `game/` and `app/` structure.

### Consequences

- The downloadable milestone matches the exact requested paths.
- The first project is easier for a beginner to locate and understand.
- Scene and script files are temporarily separated by file type.
- Future migration may require path updates in scenes and documentation.
- No additional unrelated global `scripts/` dumping ground should be created without another decision.

### Alternatives considered

- Ignore the requested paths and use only the long-term architecture.
- Permanently replace the feature-oriented architecture with global scene and script folders.

### Follow-up

Revisit the folder layout before M3 or before adding several new actor types.

## D-015 — Use a Reusable Interactable Base Class

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The same player input must eventually activate NPC dialogue, doors, chests, pickups, shops, quest objects, and floor teleporters. Hard-coding a separate player check for every object type would tightly couple the player to future systems.

### Decision

Create a reusable `Interactable` base class with three typed methods:

- Check whether interaction is currently available.
- Provide the current prompt text.
- Perform the interaction and return optional UI message text.

The player interactor depends on the base class rather than specific test objects.

### Consequences

- New interactable types can inherit the base without changing player movement.
- Test messages remain simple during M2.
- Future systems may override the methods and call dedicated dialogue, door, inventory, shop, quest, or transition services.
- Returning a string is suitable for the prototype but may later be replaced or extended by structured interaction results.

### Alternatives considered

- Use `has_method("interact")` on arbitrary nodes.
- Put sign, NPC, and chest logic inside the player script.
- Create a global interaction autoload.

### Follow-up

Review whether structured interaction-result data is needed when dialogue and inventory systems begin.

---

## D-016 — Target From the Camera but Validate Distance From the Player

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

A third-person game needs interaction to follow the direction the player is looking, but the camera is several metres behind the character. Using only camera-to-object distance could allow interactions from too far away.

### Decision

Use one `RayCast3D` beneath the active third-person camera to select the closest object in the centre of the view.

Then validate the selected object's distance from the player's `PlayerInteractor`.

The ray checks both world geometry and interactable collision layers. The player body is added as a ray exception.

### Consequences

- Looking direction determines the candidate.
- Player distance determines whether it is nearby enough.
- Only one object can be targeted at a time.
- Walls and greybox obstacles can block targeting.
- The interaction ray requires the active camera scene hierarchy to remain correctly assigned through exported NodePaths.

### Alternatives considered

- Use only a sphere around the player.
- Use camera distance alone.
- Search every nearby interactable each frame.
- Let the ray ignore world geometry.

### Follow-up

Consider a small `ShapeCast3D` or aim-assist option later if a controller requires more forgiving targeting.

---

## D-017 — Use Collision Layer 2 for Interaction Targeting

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The interaction ray must distinguish interactable physics bodies from ordinary world geometry while still allowing obstacles to block line of sight.

### Decision

Reserve collision layer 2 for interactable detection during the prototype.

Test interactables use collision layer value `3`, which places them on:

- Layer 1 for normal physical collision.
- Layer 2 for interaction targeting.

The interaction ray uses mask value `3` so it sees world geometry and interactables.

### Consequences

- The player can physically collide with test interactables.
- The interaction ray can identify them.
- Ordinary layer-1 geometry can block interactions.
- Future collision-layer names should be configured in Project Settings before the layer plan grows.

### Alternatives considered

- Put interactables only on layer 1.
- Make interactables non-colliding `Area3D` nodes.
- Ignore geometry with the interaction ray.

### Follow-up

Name collision layers in Project Settings when the combat milestone introduces hitboxes and hurtboxes.

---

## D-018 — Continue the Beginner-Facing Scene and Script Paths Through M2

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

D-014 allowed the requested top-level `scenes/` and `scripts/` paths for M1. M2 explicitly requests matching interaction and UI paths.

### Decision

Continue the documented path exception through M2:

```text
res://scripts/interactions/
res://scripts/ui/
res://scenes/interactions/
res://scenes/ui/
```

Do not move the existing working player during this milestone.

### Consequences

- The package matches the requested beginner-friendly paths.
- Existing scene references remain stable.
- The long-term feature-oriented architecture remains postponed.
- A migration decision is required before the temporary layout becomes significantly larger.

### Alternatives considered

- Move all M1 files before implementing interaction.
- Mix the new interaction system into the long-term `game/` structure while leaving the player elsewhere.

### Follow-up

Review the folder migration before or during M3, before several combat and actor systems are added.
