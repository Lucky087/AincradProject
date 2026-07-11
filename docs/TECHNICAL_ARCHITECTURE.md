# Technical Architecture

**Project:** Aincrad-Inspired RPG  
**Engine:** Godot 4.7  
**Language:** Typed GDScript  
**Status:** Initial architecture  
**Last updated:** 2026-07-11

---

## 1. Purpose

This document defines how the Godot project should be organised before gameplay systems are built.

The architecture has four goals:

1. Keep the first prototype understandable for a beginner.
2. Prevent unrelated systems from becoming tightly connected.
3. Leave room for multiplayer.
4. Support large environments and many floors later.

This document describes intended structure. Empty folders may be represented by `.gitkeep` files if Git is being used.

---

## 2. Exact Project Location

Create the Godot project folder anywhere convenient on the computer.

Example:

```text
C:/GodotProjects/aincrad_game/
```

The file `project.godot` must be in the project root:

```text
C:/GodotProjects/aincrad_game/project.godot
```

Place these documentation files here:

```text
C:/GodotProjects/aincrad_game/docs/PROJECT_BIBLE.md
C:/GodotProjects/aincrad_game/docs/TECHNICAL_ARCHITECTURE.md
C:/GodotProjects/aincrad_game/docs/NAMING_CONVENTIONS.md
C:/GodotProjects/aincrad_game/docs/CURRENT_TASKS.md
C:/GodotProjects/aincrad_game/docs/DECISION_LOG.md
```

Inside Godot, the same location appears as:

```text
res://docs/
```

`res://` means the root of the current Godot project.

---

## 3. Recommended Root Structure

Create this structure inside the folder containing `project.godot`:

```text
res://
├── addons/
├── assets/
│   ├── audio/
│   │   ├── ambience/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   ├── materials/
│   ├── models/
│   │   ├── characters/
│   │   ├── creatures/
│   │   ├── environment/
│   │   └── props/
│   ├── shaders/
│   └── textures/
│       ├── characters/
│       ├── creatures/
│       ├── environment/
│       ├── props/
│       └── ui/
├── core/
│   ├── autoload/
│   ├── data/
│   ├── events/
│   ├── interfaces/
│   └── utilities/
├── docs/
│   ├── PROJECT_BIBLE.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── NAMING_CONVENTIONS.md
│   ├── CURRENT_TASKS.md
│   └── DECISION_LOG.md
├── game/
│   ├── actors/
│   │   ├── enemies/
│   │   ├── npcs/
│   │   └── player/
│   ├── camera/
│   ├── combat/
│   ├── interaction/
│   ├── items/
│   ├── progression/
│   ├── quests/
│   ├── saving/
│   ├── ui/
│   └── world/
│       ├── floors/
│       │   └── floor_001/
│       │       ├── chunks/
│       │       ├── data/
│       │       ├── navigation/
│       │       ├── scenes/
│       │       └── zones/
│       ├── shared/
│       └── transitions/
├── multiplayer/
│   ├── replication/
│   ├── sessions/
│   └── transport/
├── tests/
│   ├── integration/
│   ├── manual/
│   └── unit/
├── app/
│   ├── bootstrap/
│   └── main/
└── project.godot
```

Do not create scripts only to fill every folder. The folders define where future files belong.

---

## 4. What Each Root Folder Is For

### `addons/`

Third-party plugins and editor extensions.

Do not place normal game code here.

Example:

```text
res://addons/dialogue_plugin/
```

### `assets/`

Imported or source-facing art and audio assets.

Examples:

- `.glb` models.
- `.png` textures.
- `.wav` sound effects.
- `.ogg` music.
- Materials and shaders.

Do not place gameplay logic in this folder.

### `core/`

Small project-wide building blocks that are not specific to one gameplay feature or floor.

Examples:

- Shared data classes.
- Global event definitions.
- Interfaces or capability contracts.
- Generic utility functions.
- Carefully selected autoload services.

`core/` should remain small.

### `docs/`

Human-readable project documentation.

These files are not gameplay code, but they are part of the project and should be committed to version control.

### `game/`

Most gameplay scenes, scripts, and resources.

Examples:

- Player.
- Enemy.
- NPC.
- Combat.
- Quests.
- User interface.
- Floor content.

### `multiplayer/`

Networking-specific code.

The local prototype should not depend on this folder. Later, multiplayer code may connect to gameplay systems through clear methods, signals, commands, and data structures.

### `tests/`

Automated tests, test scenes, and manual test instructions.

### `app/`

Application startup and top-level scene control.

This is where the project later decides whether to show a menu, load a save, start a local game, or join a multiplayer session.

---

## 5. Feature Folder Pattern

A feature should normally keep its related scene, script, and local resources together.

Example future player folder:

```text
res://game/actors/player/
├── player.tscn
├── player.gd
├── player_input.gd
├── player_movement.gd
├── player_animation.gd
├── components/
│   ├── player_health_component.tscn
│   └── player_combat_component.tscn
└── data/
    └── default_player_stats.tres
```

This is easier to navigate than placing every script in one global scripts folder and every scene in one global scenes folder.

Do not create all these files during the documentation phase.

---

## 6. Floor Folder Pattern

Every floor receives its own folder.

Floor 1:

```text
res://game/world/floors/floor_001/
├── chunks/
├── data/
├── navigation/
├── scenes/
└── zones/
```

Future example:

```text
res://game/world/floors/floor_002/
```

### `chunks/`

Small sections that can be loaded and unloaded.

Examples:

```text
starting_city_plaza_chunk.tscn
starting_city_gate_chunk.tscn
east_field_chunk.tscn
```

### `data/`

Floor definitions, zone definitions, spawn tables, and environment configuration.

### `navigation/`

Navigation-related resources and floor-specific navigation setup.

### `scenes/`

Top-level floor scenes and floor assembly scenes.

### `zones/`

Zone controllers and zone-specific scenes that group chunks together.

---

## 7. Scene Architecture

Godot scenes should be treated as reusable building blocks.

A future top-level runtime tree may look similar to this:

```text
GameRoot
├── WorldRoot
│   ├── LoadedFloor
│   └── DynamicActors
├── PlayerRoot
├── UIRoot
├── AudioRoot
└── TransitionLayer
```

Responsibilities:

- `GameRoot` coordinates the running game session.
- `WorldRoot` owns loaded world content.
- `LoadedFloor` contains the active floor and zones.
- `DynamicActors` contains runtime-spawned enemies, NPCs, and similar entities.
- `PlayerRoot` contains local and remote player actors.
- `UIRoot` contains menus and HUD.
- `AudioRoot` contains session-level audio players.
- `TransitionLayer` handles fades and loading presentation.

The exact scene should be created only when the project reaches the bootstrap-scene task.

---

## 8. Preferred Dependency Direction

Dependencies should generally point inward toward shared data and interfaces.

```text
Floor Content
      ↓
Gameplay Features
      ↓
Core Data / Interfaces
```

Networking and interface code may observe or request gameplay actions, but gameplay code should not be built entirely around a specific menu or network transport.

Good example:

```text
Quest UI reads quest state from a quest system.
```

Bad example:

```text
Quest logic searches the scene tree for a specific label and edits its text directly.
```

---

## 9. Scene Communication Rules

Use communication methods in this order:

1. Direct method calls when one object clearly owns or references another.
2. Signals when an object announces that something happened.
3. Groups when several unrelated nodes share a capability.
4. A global event service only for truly distant project-wide events.

Avoid searching the full tree repeatedly with fragile absolute node paths.

Good:

```gdscript
health_component.damage_taken.connect(_on_damage_taken)
```

Avoid:

```gdscript
get_node("/root/Main/Game/World/Player/Health")
```

Long absolute paths break when scenes are reorganised.

---

## 10. Components

Reusable behaviour should later be separated into components.

Potential components:

- `HealthComponent`
- `HitboxComponent`
- `HurtboxComponent`
- `InteractionComponent`
- `ExperienceComponent`
- `QuestMarkerComponent`
- `NetworkIdentityComponent`

A component should have one clear purpose.

Example responsibility:

```text
HealthComponent
- Stores current health.
- Stores maximum health.
- Applies validated damage.
- Emits health-changed and died signals.
```

It should not also control movement, inventory, dialogue, and saving.

---

## 11. Data Resources

Custom Godot `Resource` classes should later hold reusable definitions.

Potential resources:

```text
ActorStats
EnemyDefinition
ItemDefinition
QuestDefinition
FloorDefinition
ZoneDefinition
SpawnDefinition
```

Example future typed resource:

```gdscript
class_name ActorStats
extends Resource

@export var maximum_health: float = 100.0
@export var movement_speed: float = 5.0
@export var attack_power: float = 10.0
```

A definition resource describes data. It should not normally contain live scene state such as the current health of one spawned enemy.

---

## 12. Runtime State Versus Definition Data

Keep these concepts separate.

### Definition data

Shared design values:

- Maximum health.
- Enemy display name.
- Experience reward.
- Quest objective text.
- Floor scene path.

### Runtime state

Values belonging to one active instance:

- Current health.
- Whether one enemy is dead.
- Current quest progress.
- Current player position.
- Whether one chest has been opened.

This separation is important for saving, spawning, testing, and multiplayer.

---

## 13. Autoload Policy

Do not add an autoload simply because a script needs to be accessed from several places.

Autoloads are reserved for true application-wide services.

Possible future autoloads:

```text
SceneRouter
SaveManager
GameSettings
```

Possible later multiplayer autoload:

```text
NetworkManager
```

Do not add these until the task that needs them begins.

Avoid a giant `GameManager` that owns every system.

Each autoload must:

- Have one clear responsibility.
- Be documented in `DECISION_LOG.md`.
- Avoid storing references to temporary scene nodes unless carefully managed.
- Be testable without requiring the entire game world.

---

## 14. Bootstrap Architecture

A future bootstrap flow should be:

```text
project.godot
    ↓
Bootstrap Scene
    ↓
Main Menu or Development Start
    ↓
Create Game Session
    ↓
Load Floor
    ↓
Spawn Player
    ↓
Enable UI and Input
```

The bootstrap scene should not contain Floor 1 geometry.

Its job is to start and coordinate the application.

Suggested future paths:

```text
res://app/bootstrap/bootstrap.tscn
res://app/bootstrap/bootstrap.gd
res://app/main/game_root.tscn
res://app/main/game_root.gd
```

---

## 15. World Loading Direction

Do not load a future full floor as one permanent scene.

Use this conceptual structure:

```text
Floor Definition
    ↓
Zone Manager
    ↓
Required Zone
    ↓
Nearby Chunks
```

For the first prototype, all small Floor 1 areas may initially be loaded together for simplicity.

However, city, road, and field content should still be separated logically so they can later become independently loaded chunks.

---

## 16. Floor and Zone Identity

Use stable IDs:

```text
floor_001
zone_starting_city
zone_east_road
zone_first_field
spawn_city_plaza
spawn_city_gate
```

Use IDs in saves and data.

Do not save visible labels such as `"Starting City"` as the only identifier because display names may change or be translated.

---

## 17. Entity Identity

Persistent or networked actors will later need stable identifiers.

Examples:

```text
npc_gate_guard
enemy_boar_spawn_001
quest_first_hunt
```

Runtime-spawned entities may also receive a session-specific ID.

Keep these separate:

- **Definition ID:** What kind of object is this?
- **Persistent placement ID:** Which placed object is this?
- **Runtime instance ID:** Which active network/session instance is this?

---

## 18. Multiplayer Readiness Rules

Gameplay is built locally first, but follow these rules from the beginning:

### 18.1 Do Not Assume One Player

Avoid global code such as:

```gdscript
var player: Player
```

when the real requirement is "the actor performing this action."

Pass actor references or actor IDs where appropriate.

### 18.2 Separate Input From Results

Input asks for an action.

Gameplay authority decides the result.

Conceptual flow:

```text
Input
  → Attack request
  → Combat validation
  → Damage result
  → Animation and UI feedback
```

### 18.3 Separate Local-Only Features

These are usually local:

- Camera.
- Local input.
- Pause-menu presentation.
- Local HUD.
- Graphics settings.

These may need authority or replication later:

- Damage.
- Enemy death.
- Experience rewards.
- Inventory changes.
- Quest completion.
- Position and movement state.

### 18.4 Avoid Saving Node References

Network and save systems should use IDs and clean data, not raw references to nodes that disappear when a scene unloads.

### 18.5 Multiplayer Comes Later

Do not build remote procedure calls or server code during the foundation milestone.

The architecture should permit multiplayer, not pretend multiplayer is already complete.

---

## 19. Save Architecture Direction

The save system should later use a versioned data format.

Conceptual save data:

```gdscript
{
    "save_version": 1,
    "player_id": "local_player",
    "floor_id": "floor_001",
    "zone_id": "zone_starting_city",
    "spawn_id": "spawn_city_plaza",
    "level": 1,
    "experience": 0,
    "quests": {},
    "world_flags": {}
}
```

Rules:

- Save only required state.
- Never save passwords or private credentials.
- Write to `user://`, not `res://`.
- Validate loaded values.
- Handle missing fields.
- Keep a save-format version.
- Use stable IDs.
- Consider migration functions when the format changes.

Actual saving code is not part of the current phase.

---

## 20. Typed GDScript Policy

All project-owned GDScript should use static types wherever Godot allows it.

Example:

```gdscript
class_name ExampleController
extends Node

signal state_changed(previous_state: StringName, new_state: StringName)

const DEFAULT_STATE: StringName = &"idle"

@export var enabled: bool = true

var current_state: StringName = DEFAULT_STATE

func set_state(new_state: StringName) -> void:
    if new_state == current_state:
        return

    var previous_state: StringName = current_state
    current_state = new_state
    state_changed.emit(previous_state, current_state)
```

Benefits for this project:

- Easier code completion.
- Earlier error detection.
- Clearer function contracts.
- Easier collaboration.
- Safer future refactoring.

Do not use `Variant` without a reason.

---

## 21. Script Responsibility Rule

A script should have a short answer to this question:

> What one job does this script perform?

Good answers:

- Controls third-person movement.
- Stores and changes health.
- Loads and unloads world zones.
- Tracks one player's quest states.

Bad answer:

- Controls everything related to the game.

When a script becomes difficult to describe in one sentence, consider separating responsibilities.

---

## 22. Interfaces and Capabilities

GDScript does not require a traditional interface file for every interaction.

Use capability methods and typed base classes where useful.

Example capability:

```gdscript
func receive_damage(amount: float, source: Node) -> void:
    pass
```

Before calling a loosely typed capability, verify it exists:

```gdscript
if target.has_method("receive_damage"):
    target.receive_damage(damage_amount, attacker)
```

For important systems, prefer a shared typed base class or typed component reference instead of depending heavily on `has_method`.

---

## 23. Groups

Groups are useful for broad capabilities.

Potential future groups:

```text
players
damageable
interactable
enemies
saveable
network_replicated
```

Groups should not replace all references and types.

Use them when asking a broad question such as:

```text
Which nearby objects are interactable?
```

---

## 24. Error and Warning Policy

During development:

- Fix parser errors immediately.
- Do not ignore recurring runtime errors.
- Treat new warnings as tasks to review.
- Use `push_warning()` for recoverable developer-facing problems.
- Use `push_error()` when a required setup is missing.
- Fail safely when save data or optional content is unavailable.
- Avoid hiding errors with empty catch-all logic.

The project should reach each milestone without known critical errors.

---

## 25. Testing Direction

Use three levels of testing.

### Unit tests

Small logic without a complete world.

Examples:

- Experience required for a level.
- Quest-state transitions.
- Save-data migration.

### Integration tests

Several systems working together.

Examples:

- Killing an enemy updates quest progress.
- Loading a save restores the correct floor and spawn.

### Manual tests

Player-facing behaviour.

Examples:

- Walk from the city to the field.
- Accept and complete the quest.
- Restart the game and load progress.

Manual test instructions belong in:

```text
res://tests/manual/
```

---

## 26. Performance Direction

The prototype is small, but future content should follow these rules:

- Do not keep all 100 floors loaded.
- Do not process distant inactive actors.
- Reuse scenes and resources.
- Use level-of-detail systems when art scale requires them.
- Use occlusion and visibility tools where appropriate.
- Profile before performing complex optimisation.
- Keep physics objects and collision shapes purposeful.
- Avoid per-frame full-tree searches.
- Avoid repeatedly loading the same resources at runtime.

---

## 27. Version Control

Use Git from the beginning if possible.

Commit:

- Project files.
- Scripts.
- Scenes.
- Resources.
- Documentation.
- Importable source assets that belong to the project.

Use the official Godot ignore recommendations for generated files.

Never commit:

- Passwords.
- Private server keys.
- Personal access tokens.
- Export signing secrets.
- User-specific temporary data.

Suggested commit style:

```text
docs: add initial project architecture
feat: add bootstrap scene
fix: prevent invalid floor transition
refactor: separate player movement component
```

---

## 28. Initial Setup Checklist

Complete these steps now:

1. Create a new Godot 4.7 project.
2. Choose the Compatibility or Forward+ renderer based on the development computer; record the choice in the decision log.
3. Confirm `project.godot` exists.
4. Create the root folders from Section 3.
5. Create the five Markdown files in `res://docs/`.
6. Copy the supplied contents into the matching files.
7. Initialise Git if it will be used.
8. Make the first documentation commit.
9. Do not add gameplay code yet.
10. Update `docs/CURRENT_TASKS.md`.

---

## 29. First Future Scene

After the foundation milestone is approved, the first scene should be a minimal bootstrap scene.

It should only prove:

- The project starts.
- A controlled startup scene exists.
- A placeholder game root can be loaded.
- The folder and naming rules are followed.

It should not yet implement combat or a complete player.

---

## 30. Architecture Review Questions

Before adding a new system, ask:

1. Which feature owns this?
2. Is it definition data or runtime state?
3. Does it need to be global?
4. Does it assume only one player?
5. Does it use a stable ID?
6. Can its scene be tested alone?
7. Will unloading a floor break it?
8. Does it directly control something it should only notify?
9. Is this required for the current milestone?
10. Is there a simpler solution for the prototype?

---

## 31. Floor-Local Coordinate and Scale Architecture

Floor 1 uses:

```text
Diameter:        10,000 m
Radius:           5,000 m
Playable radius:  4,850 m
Origin:            (0, 0, 0) at floor centre
East/West:         +X / -X
North/South:       -Z / +Z
Up:                +Y
```

Each floor must be loaded near its own local origin. Do not place all 100 floors at increasingly large global Y or X/Z offsets in one persistent world. Floor transitions should exchange stable floor, region, chunk, and spawn IDs.

Single-precision coordinates are sufficient at the 5 km Floor 1 radius. World-origin shifting is not required for Floor 1 and should only be reconsidered if a loaded world exceeds approximately 20–50 km from its origin or profiling reveals precision problems.

---

## 32. Floor Data and Future Streaming Grid

The machine-readable Floor 1 plan lives at:

```text
res://AincradProject/data/floors/floor_001.json
```

It owns planning IDs, scale, region boundaries, connections, roads, settlements, dungeons, landmarks, markers, checkpoints, and streaming metadata. It does not create runtime gameplay by itself.

Future outdoor chunks use a 256-metre grid:

```text
cx = floor(world_x / 256)
cz = floor(world_z / 256)
floor_001_cx_+000_cz_+015
```

Recommended future loading:

- Chebyshev radius 2: visual preload.
- Chebyshev radius 1: collision, navigation, interactables, enemies, and pickups.
- Region-level far proxies: major city walls, mountains, windmills, and Labyrinth silhouette.

A region is an authored content identity and may contain many chunks. A chunk is a streaming/persistence cell and may overlap an authored region border.

Persistent placement keys should eventually follow:

```text
floor_id/region_id/chunk_id/persistent_placement_id
```

Streaming remains a future task. Milestone 12 only locks the plan.

---

## 33. Permanent Floor Region and Preview Architecture

Milestone 14C introduces the first permanent production-region shell:

```text
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
```

Technical terrain scenes remain regression tools. They do not become production
world ownership roots.

### 33.1 Region ownership

A production region owns:

- Manifest-driven terrain streaming.
- Regional environment and lighting.
- Empty static and dynamic content containers.
- Stable markers and neighboring-region connection anchors.
- Safe-zone volumes and signals.
- Navigation and audio placeholders.
- Region bounds and fallback hooks.
- Region metadata and configuration validation.

A production region does not own:

- Player progression or inventory.
- Player quest, wallet, equipment, or respawn state.
- SaveManager.
- Global menus.
- Duplicate player systems.

### 33.2 Preview ownership

Local F6 validation belongs in a separate preview scene:

```text
res://AincradProject/scenes/world/floor_001_southern_region_preview.tscn
```

The preview instances the permanent region and existing player separately. It
may add temporary fall recovery, debug UI, chunk-boundary lines, safe-zone
visualization, and marker guides. These preview helpers must not be copied into
normal F5 gameplay by default.

### 33.3 Streaming target contract

`FloorChunkStreamer` accepts a `Node3D` streaming target. Existing scenes keep
using the player `CharacterBody3D`. A production region may initialise around a
stable `Marker3D`, then switch to a player, camera, server-interest anchor, or
other authoritative world target through:

```text
set_streaming_target(target: Node3D)
```

Terrain selection depends only on the target's world position. The streamer does
not own the target's progression or lifecycle.

### 33.4 Region configuration

Permanent region configuration lives in valid JSON and uses stable IDs:

```text
res://AincradProject/data/floors/floor_001_southern_region.json
```

It records:

- Region and floor IDs.
- Dataset and manifest paths.
- Bounds and chunk range.
- Spawn and checkpoint IDs.
- Safe-zone dimensions.
- Road-control references.
- Neighboring region IDs.
- Content-container paths.
- Stable marker definitions.
- Streaming values.
- Reconstruction confidence.

The region scene validates marker positions against this configuration. Display
names are not persistence keys.

### 33.5 Safe-zone contract

A region safe zone is initially a data-driven `Area3D` with a stable ID and
enter/exit signals. Combat disabling, enemy suppression, checkpoint activation,
and save behaviour belong to future subscribing systems. The region volume must
not directly mutate global player or save state.

### 33.6 Reconstruction status

The southern terrain and marker layout are project reconstruction guided by the
locked Floor 1 master plan and official anchors. Production scenes must preserve
that distinction and must not describe invented contours as official canon.

---

## 34. Manifest-Driven Modular Architecture Assembly

Floor-local modular architecture generated outside Godot should be represented
by one reusable assembly scene rather than direct GLB instances scattered across
production scenes.

For the Floor 1 Starting City north gate:

```text
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
```

owns only:

- Manifest validation.
- Stable architecture resource registration.
- Manifest placement reproduction.
- Render instance category containers.
- Dedicated static collision conversion.
- Placement markers.
- Architecture-local debug visualization.

It must not own:

- Terrain streaming.
- The player.
- Player progression or inventory.
- Global quests or menus.
- SaveManager.
- NPCs or enemies.
- Navigation.

### 34.1 Placement authority

The Blender-generated architecture manifest is the placement authority when it
contains complete stable records. Do not create a duplicate placement JSON or
copy transforms into production scenes unless the manifest schema is no longer
sufficient.

The assembly root is placed at the stable world anchor, while each module keeps
its local manifest transform:

```text
assembly_world_transform × placement_local_transform × imported_asset_transform
```

World validation compares dedicated assembly markers to the permanent region's
locked coordinates. Current north-gate target error is 0.05 metres or less.

### 34.2 Render resource contract

- Load every stable render resource so the complete kit is validated.
- Instance only the pieces referenced by the accepted assembly layout.
- Keep each placement under a predictable Node3D named from its stable
  placement ID.
- Preserve imported placeholder materials.
- Do not merge the kit into one runtime mesh.
- Do not add random corrective scale or rotation.

Unused kit modules may remain loaded and validated without being placed merely
for visual completeness.

### 34.3 Dedicated collision conversion

Architecture physics must originate only from the dedicated simplified collision
GLBs.

For each placed module:

```text
PlacementRoot
└── StaticBody3D
    ├── CollisionShape_00
    ├── CollisionShape_01
    └── ...
```

Collision-mesh transforms relative to the imported GLB root must be preserved.
The placement root must use the same manifest transform as the visible module.
Temporary source meshes are freed after shape creation. Optional hidden debug
visuals may show collision-source GLBs but must never become physics sources.

Render GLBs must not be used as fallback collision when a collision resource is
missing. Missing resources cause a clear validation failure instead.

### 34.4 Preview-before-production rule

A new architecture assembly must first run in a separate F6 preview with:

- The permanent region instanced unchanged.
- The architecture assembly instanced separately.
- The existing player instanced separately.
- Safe placement and fall recovery that do not write save data.
- Alignment, orientation, asset-count, and collision debug information.

Only after local acceptance may the reusable assembly itself be instanced beneath
a stable production content container. Individual generated GLBs and generated
placement children must not be copied directly into the permanent region scene.

### 34.5 North-gate runtime acceptance contract

The Floor 1 north gate is accepted for provisional production integration only
when local Godot 4.7 testing confirms:

- 16/16 render resources load.
- 16/16 collision resources load.
- Failed asset count is zero.
- Gate, west endpoint, east endpoint, and road alignment errors are at most
  0.05 metres.
- Forward direction agrees with negative Z.
- The player crosses the passage in both directions.
- Dedicated wall, tower, connector, road, stair, and platform collision behaves
  correctly.
- No duplicate render roots or static bodies accumulate.
- Architecture contact with the accepted terrain is usable as a greybox base.
- Existing terrain previews and normal F5 gameplay still work unchanged.


---

## 31. Provisional North-Gate Production Integration

Milestone 15C establishes the reusable north-gate assembly as provisional
production content inside the permanent southern Floor 1 region.

```text
Floor001SouthernRegion
└── StaticContent
    └── CityGateArchitecture
        └── NorthGateAssembly
```

Rules:

1. The region owns exactly one assembly scene instance, never individual gate
   GLB placements.
2. `Floor001NorthGateAssembly` remains the only manifest loader and collision
   builder for this asset set.
3. `Floor001SouthernRegion` validates the integrated result but does not
   duplicate architecture loading or placement logic.
4. Architecture validation is non-fatal. Missing or invalid greybox content
   emits warnings so terrain and region inspection can continue.
5. The north-gate preview finds the assembly inside its production-region
   instance; it must not create a second gate.
6. The southern-region preview inherits the gate automatically from the
   production region.
7. Production regions still do not own a player, progression, inventory,
   global quests, SaveManager, or global menus.
8. Flat road and edging render pieces remain visual-only over terrain collision.
9. The integrated assembly is provisional and may be disabled, regenerated, or
   replaced without changing stable production markers.
10. Normal F5 startup remains unchanged until a later explicit integration
    milestone.
