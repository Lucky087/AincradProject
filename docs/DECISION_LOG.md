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

---

## D-019 — Preserve the Existing Folder Structure Through M3

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The working project already contains established `scenes/`, `scripts/`, `world/`, `data/`, `assets/`, and `docs/` folders, plus Godot-generated `.uid` files. Moving content now would create unnecessary broken references and would conflict with the explicit file-safety requirements for Milestone 3.

### Decision

Preserve the current folder structure exactly during M3.

Do not move, rename, delete, duplicate, or reorganize existing files or folders. Do not manually edit or delete Godot-generated `.uid` files.

Create only the allowed new `scripts/components/` folder and the requested milestone files in existing suitable folders.

### Consequences

- Existing scene and script references remain stable.
- The earlier migration review mentioned in D-014 and D-018 is postponed.
- New M3 content continues using the established beginner-facing layout.
- Any future reorganization requires a separate explicit migration decision and a tested path-update plan.

### Alternatives considered

- Move the project into the older proposed `game/` architecture before combat.
- Duplicate working files into a second structure.
- Clean generated files manually.

### Follow-up

Reconsider migration only when the user explicitly requests it and after the current prototype has a verified backup.

---

## D-020 — Use One Reusable Health Component for Players and Damageable Targets

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Player health, enemies, training targets, destructible quest objects, and future network actors all require the same basic concepts: current health, maximum health, damage, restoration, death, and health-change notifications.

### Decision

Create a typed `HealthComponent` that is independent from actor-specific logic.

The component owns health state and emits typed signals. Player, enemy, UI, animation, saving, and networking code may observe or call the component but must not be built into it.

### Consequences

- The player and training dummy use the same damage API.
- Future enemies can reuse the component without copying health logic.
- UI can subscribe to health changes without controlling combat.
- Saving and multiplayer can later serialize or replicate clean values around the component.
- Actor-specific death reactions remain outside the component.

### Alternatives considered

- Put player health inside `player_controller.gd`.
- Put dummy health directly inside `training_dummy.gd`.
- Create separate player-health and enemy-health scripts.

### Follow-up

M4 should reuse this component for the first moving enemy and for incoming player damage.

---

## D-021 — Use a ShapeCast Attack Boundary and Dedicated Hurtbox Layer

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The first sword attack needs a clear, reusable collision boundary. Using ordinary body collision alone would mix movement collision with combat detection and make future hit filtering harder.

### Decision

Use a `ShapeCast3D` beneath the player's existing `VisualRoot` as the first attack boundary.

Reserve 3D physics layer 3 for `Hurtbox` areas. The player attack cast detects only that layer and applies damage through a `HealthComponent` found on the hurtbox owner hierarchy.

### Consequences

- World collision, interaction targeting, and combat targeting remain separate.
- The attack follows the direction the player's visual body faces.
- One cast can detect several targets while deduplicating each health component per swing.
- Future enemies can add a layer-3 hurtbox without changing player combat code.
- More advanced weapon trails or animation-driven active frames may replace the prototype timing later.

### Alternatives considered

- Detect damage through ordinary `StaticBody3D` and `CharacterBody3D` collisions.
- Hard-code the training dummy type into player combat.
- Use a permanent overlapping `Area3D` without attack timing.
- Use a camera ray for melee combat.

### Follow-up

M4 should use the same hurtbox layer and introduce a separate enemy attack boundary for player damage.

---

## D-022 — Bind the First Sword Attack to `player_attack_primary`

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The naming conventions reserve prefixed Input Map actions for player gameplay. The first combat milestone needs one clear attack action without changing movement, interaction, or mouse-capture controls.

### Decision

Add the Input Map action:

```text
player_attack_primary
```

Bind it to the left mouse button. Process it in the separate `PlayerCombat` node only while the mouse is captured.

### Consequences

- Left click performs one basic sword swing.
- Clicking while the cursor is released does not attack.
- Existing E interaction and Escape mouse capture remain unchanged.
- Future controller bindings can be added to the same action.
- Additional attack actions can follow the same naming pattern later.

### Alternatives considered

- Put attack input inside `player_controller.gd`.
- Use a raw mouse-button check rather than the Input Map.
- Reuse the E interaction action.

### Follow-up

Add controller bindings only after keyboard-and-mouse combat is locally verified.

---

## D-023 — Use a Resettable Training Dummy Before Building Enemy AI

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Health and sword damage should be tested independently before movement, detection, chasing, and enemy attacks introduce additional failure points.

### Decision

Create one primitive stationary training dummy with:

- A reusable `HealthComponent`.
- A dedicated hurtbox.
- A visible health label.
- Simple hit feedback.
- A defeated state.
- Automatic reset after three seconds.

### Consequences

- Combat can be tested repeatedly without restarting the scene.
- M3 does not require enemy artificial intelligence.
- The dummy is a development target, not the first real enemy type.
- M4 remains responsible for enemy movement and attacks.

### Alternatives considered

- Build the first full enemy and combat system simultaneously.
- Destroy the dummy permanently after defeat.
- Add an enemy attack during M3.

### Follow-up

Keep the dummy available as a regression-test object after M4 begins.

---

## D-024 — Keep Health UI Separate From Interaction UI

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The existing interaction UI handles prompts and short messages. Health is persistent actor state with a different lifetime and update source.

### Decision

Create a separate reusable `HealthUI` scene that connects to one `HealthComponent` through an exported `NodePath`.

Do not add health controls or health state to `InteractionUI`.

### Consequences

- Interaction UI remains focused on interaction prompts and messages.
- Health UI can be reused or replaced independently.
- Future HUD composition can instance both UI scenes without merging their scripts.
- The player HUD is ready before enemies can damage the player.

### Alternatives considered

- Add the health bar to `interaction_ui.tscn`.
- Make `player_controller.gd` directly update labels.
- Create a global HUD autoload during M3.

### Follow-up

M5 may expand the HUD with experience and level displays while preserving separate feature responsibilities.

---

## D-025 — Preserve the Existing Folder Structure Through M4

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The current project already has working movement, interaction, health, sword combat, a training dummy, established `scenes/` and `scripts/` folders, and Godot-generated `.uid` files. Reorganising these files while adding the first enemy would create unnecessary risk and conflict with the explicit file-safety requirements.

### Decision

Preserve the existing folder structure exactly during M4.

Create the boar only at:

```text
res://AincradProject/scenes/enemies/boar_enemy.tscn
res://AincradProject/scripts/enemies/boar_enemy.gd
```

Modify only the existing player scene, test world, current-tasks document, and decision log where required. Do not manually edit or delete `.uid` files.

### Consequences

- Existing resource paths remain stable.
- The player scripts and interaction system remain untouched.
- Godot may generate a new `.uid` file for `boar_enemy.gd` when the project opens.
- Any future reorganisation still requires a separate explicit migration task.

### Alternatives considered

- Move enemies into a new `game/actors/` hierarchy before M4.
- Duplicate the current project into a second structure.
- Manually generate or edit script UID files.

### Follow-up

Keep using the current paths until the user explicitly requests and approves a tested migration.

---

## D-026 — Use a Small State Controller Without an Enemy Base Class Yet

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The first hostile enemy requires idle, chase, attack, hurt, return, dead, and respawn behaviour. Only one moving enemy type currently exists, so an inheritance hierarchy would not yet remove real duplication.

### Decision

Implement the boar with one typed state enum inside `boar_enemy.gd`.

Do not create `enemy_base.gd` during M4. Reconsider a shared base only after a second moving enemy reveals genuinely repeated behaviour that composition cannot handle cleanly.

### Consequences

- The first enemy remains easy for a beginner to inspect in one file.
- No premature inheritance contract is introduced.
- Reusable health remains in `HealthComponent`, not copied into the boar.
- A later refactor may extract common enemy behaviour after evidence exists.

### Alternatives considered

- Create an abstract enemy base before any duplicated enemy code exists.
- Put enemy behaviour inside `HealthComponent`.
- Add separate scripts for every small state immediately.

### Follow-up

Review duplication after the second hostile enemy is implemented.

---

## D-027 — Use Direct Greybox Movement and Delay Navigation

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The M4 test world is a small, mostly open greybox. Adding `NavigationRegion3D`, baking instructions, and path-recovery logic would increase setup complexity before the prototype has a real field layout that needs pathfinding.

### Decision

Use direct horizontal `CharacterBody3D` movement for the first boar.

The boar collides with World-layer bodies, moves in `_physics_process()`, and returns directly toward its stored spawn position. No navigation mesh is required or baked in M4.

### Consequences

- M4 has no navigation setup step.
- The boar can collide with large obstacles rather than intelligently walking around them.
- Detection, chasing, attacking, returning, death, and respawn can be tested independently from pathfinding.
- Navigation should be added when the real Floor 1 field contains routes and obstacles that require it.

### Alternatives considered

- Add and bake a navigation region immediately.
- Use `_process()` for enemy movement.
- Teleport the enemy instead of using physics movement.

### Follow-up

Add `NavigationAgent3D` and floor navigation only when the field layout demonstrates a real need.

---

## D-028 — Find Players by Group and Reuse Their Health Component

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The boar needs a target without depending on an absolute test-world node path. The player already has a reusable `HealthComponent`, and the architecture should avoid placing enemy-specific references inside the player scripts.

### Decision

Add the existing player root to the `players` group in `player.tscn`.

The boar resolves the first available group member and finds its child `HealthComponent`. If the reference disappears, the boar searches again at a limited configurable interval.

### Consequences

- `player_controller.gd` and `player_combat.gd` remain unchanged.
- The boar can locate the player even if the test-world hierarchy changes.
- Incoming damage uses the same public `HealthComponent.apply_damage()` method already used by the sword system.
- The group approach can later contain multiple players, but M4 still targets only one local player.

### Alternatives considered

- Export a hard-coded path from the boar to `../../Player`.
- Add an enemy reference to the player controller.
- Create a global game-manager autoload only to locate the player.

### Follow-up

A later multiplayer milestone must replace first-player selection with explicit authority and target-selection rules.

---

## D-029 — Validate Enemy Damage at the Hit Moment

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Starting an attack while the player is close does not guarantee the player remains close when the visible lunge reaches its hit moment. A permanent overlapping damage area could also apply damage repeatedly during one attack.

### Decision

Perform exactly one damage attempt per boar attack sequence.

At the hit callback, verify that:

- The boar and player are alive.
- The player is still within `maximum_attack_hit_distance`.
- A World-layer ray from the boar to the player is not blocked by another solid body.

Only then call the player's existing `HealthComponent.apply_damage()` method. Start a cooldown after the attack completes.

### Consequences

- One attack cannot damage the player multiple times.
- Moving out during windup can avoid the hit.
- Solid greybox bodies can block the attack.
- Attack animation, hit validation, and health state remain separate responsibilities.

### Alternatives considered

- Damage immediately when the attack begins.
- Apply damage every physics frame while an Area3D overlaps.
- Ignore distance after the attack starts.
- Hard-code changes directly into the player health UI.

### Follow-up

Future animation-driven combat may replace the tween callback with animation events while preserving the same validation rules.

---

## D-030 — Respawn the Boar at Its Stored Scene Transform

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The first enemy must be repeatable for testing without requiring a scene restart. Returning to a guessed coordinate would break when the scene instance is moved in the editor.

### Decision

Store the boar's initial global transform during `_ready()` and use it as both the leash origin and respawn location.

On death, stop movement and attacks, disable the body collision and hurtbox, and start a configurable respawn timer. On timeout, restore the saved transform, visuals, collision, hurtbox, state, and health.

### Consequences

- Designers can move the boar instance without editing the script.
- The boar returns to and respawns at the same authored position.
- The same scene can be instanced more than once later with independent spawn origins.
- No loot, experience, or persistence is attached to respawn yet.

### Alternatives considered

- Use a hard-coded world coordinate.
- Permanently delete the boar after death.
- Reload the entire test world after every enemy defeat.

### Follow-up

Future world-state saving must decide whether defeated enemies should respawn immediately, after a timer, or after a session reload.

---

## D-031 — Preserve the Existing Folder Structure Through M5

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The uploaded project already contains working movement, interactions, health, sword combat, a training dummy, a hostile boar, established `scenes/` and `scripts/` folders, and Godot-generated `.uid` files. Reorganising those files while adding progression would create unnecessary risk and violate the current file-safety rules.

### Decision

Preserve the existing folder structure exactly during M5.

Create only:

```text
res://AincradProject/scripts/components/player_progression.gd
res://AincradProject/scripts/ui/progression_ui.gd
res://AincradProject/scenes/ui/progression_ui.tscn
res://AincradProject/docs/MILESTONE_5_SETUP.md
```

Modify only the existing player scene, boar script, boar scene, current-tasks document, and decision log where required. Do not manually edit or delete `.uid` files.

### Consequences

- Existing resource paths remain stable.
- The player controller, player combat script, health component, training dummy, and interaction system remain unchanged.
- Godot may generate new `.uid` files for the two new scripts when the project opens.
- Any future reorganisation still requires a separate explicit migration task.

### Alternatives considered

- Move progression into a new `game/progression/` hierarchy.
- Merge progression into `player_controller.gd`.
- Manually create script UID files.

### Follow-up

Keep using the current beginner-facing paths until a separately approved migration is requested.

---

## D-032 — Use a Reusable PlayerProgression Component With a Linear Formula

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The player needs level and experience state that can later be used by quests, saving, UI, enemies, and multiplayer authority without placing progression logic inside movement, combat, or enemy scripts.

### Decision

Create one typed `PlayerProgression` component as a direct child of the player.

Use the replaceable formula:

```text
experience required for next level = base_experience_per_level × current level
```

Set `base_experience_per_level` to 100 by default. Store experience within the current level, carry excess experience forward, support several level-ups from one reward, and expose typed getters plus `experience_changed` and `levelled_up` signals.

### Consequences

- Level 1 requires 100 XP, Level 2 requires 200 XP, and Level 3 requires 300 XP.
- Progression logic remains independent from the HUD and enemy movement.
- Future formulas can replace one calculation method without changing reward callers.
- Experience beyond the configured maximum level is discarded.

### Alternatives considered

- Store level and XP inside `player_controller.gd`.
- Hard-code each level requirement in an array.
- Make the progression UI own the experience values.

### Follow-up

A future saving milestone should serialize current level and current-level experience through stable save data.

---

## D-033 — Award Boar XP From the Killing Damage Source With a Per-Life Gate

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The existing `HealthComponent` already emits `died(source)` using the source from the damage that reduced health to zero. The sword already supplies the player root as that source. The boar must reward the responsible player once, without relying on a fixed test-world path or rewarding simple scene removal.

### Decision

Give the boar an exported `experience_reward` with a default value of 40.

In the existing death callback:

1. Use the killing `source` supplied by `HealthComponent.died(source)`.
2. Walk upward from that source until a node in the existing `players` group is found.
3. Find that player's direct `PlayerProgression` child.
4. Call `add_experience(experience_reward)`.
5. Set a private per-life reward flag so the same death cannot reward twice.
6. Reset the flag only when the boar respawns.

Do not award experience from `_exit_tree()`, `queue_free()`, timeout removal, or any other non-death path.

### Consequences

- The player responsible for the killing sword hit receives the reward.
- Duplicate death callbacks cannot duplicate XP.
- A respawned boar can reward XP again.
- The training dummy remains reward-free because it is not modified.
- Future non-player damage sources receive no player XP unless they resolve to a `players` group member.

### Alternatives considered

- Award XP whenever the boar is removed from the scene tree.
- Hard-code `../../Player/PlayerProgression`.
- Make `PlayerCombat` award a fixed reward for every damaged target.
- Store a global XP singleton.

### Follow-up

Future party, assist, and multiplayer reward rules must replace the single killing-source rule explicitly.

---

## D-034 — Keep Progression UI Separate and Defer Maximum-Health Growth

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The project already has separate health and interaction UI scenes. Progression is a different feature with its own signals and presentation. The existing `HealthComponent` exposes health reads, damage, healing, and reset, but it does not expose a safe public method for changing maximum health while clamping current health and emitting a consistent update.

### Decision

Create a separate `ProgressionUI` scene beneath the existing health panel. It connects to `PlayerProgression` through an exported `NodePath` and updates only from progression signals.

Do not change maximum health during M5. Do not directly assign the exported `maximum_health` property from progression code. Record `+5 maximum HP and full heal per level` as a future task that requires a safe public health API first.

### Consequences

- Existing health and interaction UI files remain unchanged.
- Progression UI can be replaced independently later.
- No `_process()` loop is required for HUD updates.
- Level-ups do not currently change combat stats or health.
- Health-component invariants are not bypassed.

### Alternatives considered

- Merge XP controls into `health_ui.tscn`.
- Make the boar directly update labels.
- Change `maximum_health` from outside the health component without a method or signal.
- Redesign the existing health component during M5.

### Follow-up

Add a tested `set_maximum_health()` or `increase_maximum_health()` API in a dedicated future milestone before enabling health growth.

---

## D-035 — Preserve the Existing Folder Structure Through M6

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The uploaded project already contains working movement, interaction, health,
combat, enemy, progression, UI, data, world, documentation, and Godot-generated
`.uid` files. Reorganising those files while adding the first quest would add
risk without improving the milestone.

### Decision

Preserve the existing folder structure exactly during M6.

Create only the quest definition, player quest log, quest NPC, quest UI, Boar
Hunt resource, their scenes, and the milestone setup document inside existing
suitable folders. Modify only the existing player scene, test world, boar script,
boar scene, current tasks, and decision log where required.

Do not move, rename, delete, duplicate, or reorganize existing content. Do not
manually create, edit, or delete `.uid` files.

### Consequences

- Existing resource paths remain stable.
- Movement, combat, health, progression, and interaction scripts remain
  unchanged.
- Godot may generate `.uid` files for new scripts after opening the project.
- Any future migration still requires a separately approved task.

### Alternatives considered

- Move all gameplay into a new `game/` or `src/` hierarchy.
- Merge quest logic into the existing NPC or progression scripts.
- Manually generate script UID files.

### Follow-up

Continue using the current paths until an explicit migration milestone is
approved.

---

## D-036 — Separate Quest Definitions From Player Runtime Quest State

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Quest titles, descriptions, objective targets, and rewards are reusable design
data. Accepted state, progress, readiness, completion, and reward gates belong
to one player. Mixing both kinds of data in an NPC or UI would make future
quests, saving, and multiplayer authority harder to add.

### Decision

Use a typed `QuestDefinition` resource for stable quest content and a direct
player child named `PlayerQuestLog` for runtime state.

The Boar Hunt resource uses:

```text
quest_id: boar_hunt
objective_id: wild_boar
objective_target: 3
experience_reward: 100
```

`PlayerQuestLog` supports registration, acceptance, objective progress, turn-in,
and the four states Not Started, Active, Ready to Turn In, and Completed. It
announces changes through typed signals.

### Consequences

- The same quest definition can later be used by NPCs, UI, saving, or server
  authority without duplicating text and values.
- Visible text can change without changing stable IDs.
- Additional quests can be registered without changing the player controller.
- Runtime state is not stored in the `.tres` resource.

### Alternatives considered

- Store quest state directly on the quest NPC.
- Store all quest values in the quest UI.
- Hard-code Boar Hunt values inside the boar enemy.
- Add a global quest singleton for one local prototype player.

### Follow-up

The saving milestone should serialize quest IDs, states, progress, and reward
gates rather than serializing live quest nodes.

---

## D-037 — Report Boar Quest Progress From the Killing Source With a Per-Life Gate

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The existing health system already identifies the source of the killing hit,
and the boar already uses that source for its normal 40 XP reward. Quest
progress must go to the same responsible player, count only after acceptance,
and never duplicate during one defeated life.

### Decision

Give the boar the stable exported enemy ID `wild_boar`.

During the existing guarded death callback:

1. Preserve the normal 40 XP reward.
2. Walk upward from the killing source to the existing `players` group member.
3. Find that player's direct `PlayerQuestLog` child.
4. Report one objective event using the boar's stable enemy ID.
5. Set a private per-life quest-report flag.
6. Reset that flag only when the boar respawns.

Let `PlayerQuestLog` decide whether an active quest accepts the objective event.

### Consequences

- Boars defeated before acceptance do not count.
- A valid active Boar Hunt receives exactly one progress point per boar life.
- A respawned boar can count again.
- The training dummy does not count because it never reports `wild_boar`.
- The boar's AI, damage, death, respawn, and XP behavior remain independent from
  Boar Hunt-specific state.

### Alternatives considered

- Let the quest UI watch the boar's health directly.
- Increment quest progress from `PlayerCombat` for every target it kills.
- Hard-code a path to the test-world player.
- Count every boar death globally regardless of the killing source.

### Follow-up

Future shared-kill, party, assist, and multiplayer rules must replace the single
killing-source rule explicitly.

---

## D-038 — Use a Two-Step Quest Offer and Require NPC Turn-In

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The first quest needs a visible offer, explicit acceptance, progress checking,
and manual turn-in, but a full branching dialogue system is outside the current
scope. The existing interaction system already supports E input, changing
prompts, and short messages.

### Decision

Create a new primitive `QuestNpc` that inherits the existing `Interactable`
base class.

- First E interaction presents Boar Hunt and its reward.
- Second E interaction accepts it.
- Active interactions show current progress.
- Ready interactions turn in the quest.
- Completed interactions show thank-you dialogue.

Do not automatically grant the 100 XP reward when progress reaches 3 / 3. Grant
it only from `PlayerQuestLog.turn_in_quest()` after the player returns to the
NPC. Set the reward gate before adding XP, then mark the quest completed.

Use a separate signal-driven `QuestUI` below the existing progression panel.

### Consequences

- The prototype demonstrates offer, acceptance, tracking, return, and completion.
- The reward cannot be duplicated by talking to the NPC repeatedly.
- No new input action or dialogue manager is required.
- Existing health, progression, and interaction UI remain separate.
- A full dialogue-choice interface can replace the two-step approach later.

### Alternatives considered

- Accept the quest automatically on the first interaction.
- Grant the reward immediately on the third kill.
- Replace the existing test NPC.
- Build a full dialogue tree and choice system during M6.

### Follow-up

A future dialogue milestone may replace the two-step E flow while keeping the
same quest-log methods and states.

---

## D-039 — Preserve the Existing Folder Structure Through M7

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The uploaded project already contains working movement, interaction, combat,
health, enemy, progression, quest, UI, documentation, Godot settings, and
Godot-generated `.uid` files. Reorganising those files while adding persistence
would make resource-path and save testing less reliable.

### Decision

Preserve the existing folder structure exactly during M7.

Create only:

```text
scripts/systems/save_manager.gd
scripts/ui/save_status_ui.gd
scenes/ui/save_status_ui.tscn
docs/MILESTONE_7_SETUP.md
```

Modify only `project.godot`, the existing player scene, the existing health,
progression, quest-log and quest-UI scripts, and required documentation.

Do not move, rename, delete, duplicate, or reorganize existing content. Do not
manually create, edit, or delete `.uid` files.

### Consequences

- Existing `res://AincradProject/` resource paths remain stable.
- Godot may generate UID files for the two new scripts after opening the project.
- M1–M6 scenes and public interfaces remain available.
- A future structure migration still requires an explicitly approved milestone.

### Alternatives considered

- Move all systems into a new architecture while adding saves.
- Create duplicate player or quest data under `scripts/systems/`.
- Manually generate new UID files.

### Follow-up

Continue using the current paths through the Floor 1 vertical-slice milestone.

---

## D-040 — Use One SaveManager Autoload as a Coordinator

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Manual save and load input is application-wide and should remain available when
world scenes are replaced later. The architecture document reserves Autoloads
for true application-wide services and lists SaveManager as an appropriate
future example.

### Decision

Register `scripts/systems/save_manager.gd` as the `SaveManager` Autoload.

Use the typed script class name `SaveManagerService` so it does not conflict with
the Autoload node name.

The manager will:

1. Handle K and L through `_unhandled_input()`.
2. Find the local player through the existing `players` group.
3. Resolve the player's direct health, progression, and quest components.
4. Ask those components to export or restore their own data.
5. Read and write `user://savegame.json`.
6. Emit user-facing status messages.

The manager will not own duplicate health, XP, level, or quest variables.

### Consequences

- Save/load remains available independently of the current gameplay scene.
- Existing components remain the source of truth.
- The manager has one clear application-wide responsibility.
- No `_process()` polling is needed.
- Future scene transitions can keep the same save coordinator.

### Alternatives considered

- Attach save code to the player controller.
- Put save input inside the test world.
- Add duplicate progression and quest dictionaries to a global game manager.
- Avoid an Autoload and hard-code the current scene tree.

### Follow-up

Future floor and spawn persistence may extend the same versioned format without
moving current player-owned data into SaveManager.

---

## D-041 — Let Components Own Their Persistent Data Interfaces

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

`HealthComponent`, `PlayerProgression`, and `PlayerQuestLog` already own and
validate their runtime state. SaveManager would violate those boundaries if it
wrote private variables directly or recreated their rules.

### Decision

Add these public interfaces where appropriate:

```gdscript
get_save_data() -> Dictionary
load_save_data(data: Dictionary) -> void
```

Each component validates its own fields and emits a signal that refreshes its
existing UI after loading.

- Health emits `health_changed` but not damage, healing, or death signals.
- Progression emits `experience_changed` but not `levelled_up`.
- Quest log emits the new `quest_data_loaded` refresh signal rather than
  replaying normal quest completion.

### Consequences

- SaveManager remains orchestration code rather than a duplicate data model.
- Component invariants remain centralized.
- UI refreshes immediately without `_process()` loops.
- Loading does not replay combat, reward, or level-up consequences.
- Future component fields can be versioned behind their own load methods.

### Alternatives considered

- Let SaveManager modify private fields directly.
- Recalculate quest state in the UI.
- Emit every gameplay signal again during load.
- Duplicate all player data inside the Autoload.

### Follow-up

Any future inventory or equipment component should follow the same ownership
pattern rather than expanding SaveManager into a monolithic state container.

---

## D-042 — Use Versioned JSON and Normalize Quest Reward Ownership on Load

**Date:** 2026-07-10  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The first save must be readable for testing, survive restarts, reject damaged or
unsupported data safely, and guarantee that a completed Boar Hunt never pays its
100 XP reward twice.

### Decision

Write JSON to:

```text
user://savegame.json
```

Use `save_version = 1` and stable quest IDs. Store readable quest state names:

```text
not_started
active
ready_to_turn_in
completed
```

During quest loading:

- Completed state forces `reward_claimed = true`.
- A claimed reward forces Completed state.
- Completed and ready states normalize objective progress to the target.
- Unknown quest IDs are skipped with warnings.
- Missing or invalid fields use safe existing values.

Reject an empty file, invalid JSON root, parse error, or unsupported version
without crashing.

### Consequences

- The file is easy to inspect during prototype testing.
- Save-format migration can be added explicitly later.
- Completed Boar Hunt cannot become turn-in-ready after loading.
- Talking to the Road Warden after loading a completed quest cannot grant more XP.
- Damaged and outdated saves produce visible feedback and useful warnings.

### Alternatives considered

- Save live nodes or scene trees.
- Store visible quest titles instead of stable IDs.
- Trust `state` without saving the reward gate.
- Use an unversioned JSON file.
- Crash or reset the project when parsing fails.

### Follow-up

Add migration functions before changing the meaning or shape of version 1 data.

---

## D-043 — Keep Item Definitions Separate From Player Inventory State

**Date:** 2026-07-11  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Weapons need reusable names, descriptions, categories, stack limits, slots, and
damage values. Runtime ownership must also remain saveable without serializing
live nodes or depending on Resource paths.

### Decision

Create `ItemDefinition` as a reusable Resource class under
`scripts/items/item_definition.gd`.

Store item design data in `.tres` resources, while `PlayerInventory` owns only
stable item IDs, quantities, and the equipped weapon ID.

The first registered definitions are:

- `training_sword`, 25 damage.
- `bronze_sword`, 35 damage.

### Consequences

- New items can reuse the same component and UI.
- Save files remain based on stable IDs rather than scene or Resource references.
- Item files can be edited without duplicating inventory logic.
- Unknown saved IDs can be skipped safely.
- Item definitions must keep their stable IDs after public saves depend on them.

### Alternatives considered

- Store complete Resource paths in save data.
- Put weapon damage directly in inventory dictionaries.
- Create separate scripts for every individual weapon.
- Make SaveManager own an item database.

### Follow-up

Register future item definitions with each player's inventory or a later shared
catalog without changing existing saved IDs.

---

## D-044 — Let PlayerInventory Own Runtime Items and One Weapon Slot

**Date:** 2026-07-11  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Inventory data should not be duplicated inside the UI, combat script, chest, or
SaveManager. The first milestone only requires weapons but should leave room for
stackable consumables, materials, quest items, and miscellaneous items later.

### Decision

Add one `PlayerInventory` component as a direct child of the player.

It owns:

- A configurable maximum slot count.
- Stable item ID and quantity stacks.
- One equipped weapon ID.
- Item add, remove, ownership, quantity, equip, and unequip interfaces.
- Inventory and equipment signals.
- Component-owned save and load methods.

A new game starts with exactly one Training Sword equipped. Non-stackable
weapons cannot be duplicated.

### Consequences

- Inventory UI is presentation only.
- Combat asks the inventory for current weapon damage.
- The chest asks the inventory to add its reward.
- SaveManager only coordinates the component's public persistence interface.
- Additional equipment slots remain intentionally outside this milestone.

### Alternatives considered

- Put inventory arrays on the player controller.
- Let InventoryUI own the list.
- Duplicate equipped-weapon data in PlayerCombat.
- Use Node or Resource references as saved ownership state.

### Follow-up

Future armour or consumables must extend this component deliberately rather than
creating parallel player inventories.

---

## D-045 — Derive Sword Damage From Equipped Weapon and Gate Gameplay Input

**Date:** 2026-07-11  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

The existing combat system already owns attack timing, ShapeCast3D collision,
one-hit-per-swing protection, and cooldowns. Inventory must change damage without
replacing those proven mechanics. Opening a full-screen inventory must also stop
movement, attacks, and interactions while preserving gravity and UI input.

### Decision

Keep the existing `PlayerCombat` public signals and attack flow. Add an exported
inventory path and synchronize the existing `attack_damage` value from the
equipped weapon whenever equipment changes.

An unequipped player cannot start a damaging sword attack.

Add small public input gates to:

- `PlayerController` for movement, jump, and sprint.
- `PlayerCombat` for attacks and active-swing cancellation.
- `PlayerInteractor` for targeting and E interactions.

`InventoryUI` calls these gates when it opens and closes. Escape is consumed by
the inventory first, so it closes before mouse capture can change.

### Consequences

- Training Sword preserves 25 damage.
- Bronze Sword changes damage to 35 immediately.
- Attack hit windows and cooldowns remain unchanged.
- Unequipping produces a safe zero-damage state.
- Gameplay scripts remain responsible for their own input rather than checking a
  global menu flag every frame.

### Alternatives considered

- Replace PlayerCombat with an inventory-specific combat controller.
- Change ShapeCast3D or cooldown logic.
- Pause the entire scene tree when inventory opens.
- Let each gameplay script search for InventoryUI every frame.

### Follow-up

A future general UI-state coordinator may replace the direct gates when several
modal menus exist, but current public methods should remain compatible.

---

## D-046 — Grant Bronze Sword Through the Existing One-Use Chest

**Date:** 2026-07-11  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Milestone 8 needs one item acquisition path without adding loot tables, enemy
drops, shops, or a replacement chest scene.

### Decision

Extend the existing `TestChest` interaction so it safely finds the interacting
player's `PlayerInventory` and attempts to add one `bronze_sword`.

- The chest opens after a successful reward.
- If the player already owns Bronze Sword, it opens and reports that no duplicate
  was added.
- If the inventory cannot accept the reward, the chest stays closed so the
  player can retry.
- Repeated interaction cannot produce duplicate non-stackable weapons.

### Consequences

- Existing interaction targeting, prompt, E input, and lid animation remain.
- No alternative chest or loot system is introduced.
- A loaded inventory containing Bronze Sword remains duplicate-safe even though
  temporary chest-open state is not saved.

### Alternatives considered

- Replace the chest scene.
- Give Bronze Sword automatically at startup.
- Drop a physical pickup.
- Award the sword from the boar or quest.

### Follow-up

Chest persistence and configurable loot containers may be added only after the
prototype needs persistent world-object state.

---

## D-047 — Advance Save Format to Version 2 With Version-1 Inventory Fallback

**Date:** 2026-07-11  
**Status:** Accepted  
**Decision owner:** Lead developer

### Context

Inventory and equipment must survive restarts, but Milestone 7 version-1 saves
contain only player, progression, and quest data. Existing saves must not crash
or silently create duplicate starter weapons.

### Decision

Increase the save writer to version 2 and add:

```text
inventory.items[] = { item_id, quantity }
inventory.equipped_weapon_id
```

Continue accepting save versions 1 and 2.

When loading version 1, pass missing inventory data to `PlayerInventory`, which
resets to exactly one configured starter Training Sword and equips it.

For version 2:

- Unknown item IDs are skipped with warnings.
- Stack and slot limits are revalidated.
- Duplicate non-stackable weapons are rejected.
- The equipped ID is restored only if it identifies an owned equippable weapon.
- Inventory and equipment signals refresh UI and combat immediately.

### Consequences

- Milestone 7 saves remain usable.
- New saves preserve both swords and current weapon equipment.
- SaveManager still does not own duplicate inventory state.
- Future format changes must preserve or migrate versions 1 and 2 deliberately.

### Alternatives considered

- Reject all version-1 saves.
- Keep version 1 despite changing its schema.
- Store Resource paths or complete Resources in JSON.
- Add starter inventory before loading every save, causing duplicates.

### Follow-up

Add explicit migration helpers before version 3 changes the meaning of existing
inventory fields.

