# Naming Conventions

**Project:** Aincrad-Inspired RPG  
**Engine:** Godot 4.7  
**Language:** Typed GDScript  
**Last updated:** 2026-07-10

---

## 1. Purpose

Consistent names make the project easier to search, understand, and expand.

These rules apply to project-owned files, scenes, scripts, resources, nodes, IDs, signals, input actions, and code.

Third-party assets may keep their original names inside `res://addons/` or clearly separated source-asset folders.

---

## 2. Quick Reference

| Item | Style | Example |
|---|---|---|
| Folder | `snake_case` | `starting_city` |
| File | `snake_case` | `player_movement.gd` |
| Scene file | `snake_case.tscn` | `player.tscn` |
| Resource file | `snake_case.tres` | `first_hunt_quest.tres` |
| GDScript class | `PascalCase` | `PlayerController` |
| Scene-tree node | `PascalCase` | `CameraPivot` |
| Function | `snake_case` | `apply_damage()` |
| Variable | `snake_case` | `current_health` |
| Boolean | question-like `snake_case` | `is_alive` |
| Constant | `UPPER_SNAKE_CASE` | `MAX_PARTY_SIZE` |
| Signal | past-tense `snake_case` | `health_changed` |
| Enum name | `PascalCase` | `QuestState` |
| Enum value | `UPPER_SNAKE_CASE` | `IN_PROGRESS` |
| Stable content ID | lowercase `snake_case` | `quest_first_hunt` |
| Input action | lowercase `snake_case` | `player_attack_primary` |

---

## 3. Folder Names

Use lowercase `snake_case`.

Good:

```text
starting_city
floor_001
player_components
quest_data
```

Avoid:

```text
StartingCity
Floor 1
player-components
QuestData
```

Do not use spaces in project paths.

---

## 4. File Names

Use lowercase `snake_case`.

Good:

```text
player.gd
player.tscn
health_component.gd
health_component.tscn
first_hunt_quest.tres
```

Keep a scene and its main script similarly named:

```text
player.tscn
player.gd
```

Avoid unclear names:

```text
script1.gd
new_scene.tscn
manager_final2.gd
thing.gd
```

---

## 5. Class Names

Use `PascalCase`.

```gdscript
class_name HealthComponent
extends Node
```

Examples:

```text
PlayerController
EnemyController
QuestDefinition
FloorDefinition
SaveData
```

A globally named class must have a unique and descriptive name.

Avoid overly generic class names such as:

```text
Manager
Controller
Data
Object
```

Prefer:

```text
SaveManager
PlayerController
QuestDefinition
FloorRuntimeState
```

---

## 6. Node Names

Use `PascalCase` in the scene tree.

Example:

```text
Player
├── CharacterModel
├── CollisionShape3D
├── CameraPivot
│   └── Camera3D
├── HealthComponent
└── InteractionDetector
```

A node name should describe its role, not only its type.

Better:

```text
InteractionRayCast
MainCamera
SwordHitbox
```

Less useful:

```text
RayCast3D
Camera3D
Area3D
```

Type names are acceptable when the role is already obvious and there is only one such node.

---

## 7. Variables

Use lowercase `snake_case` and include a type.

```gdscript
var current_health: float = 100.0
var current_target: Node3D
var active_quest_ids: Array[StringName] = []
```

Names should describe what the value means.

Good:

```gdscript
movement_speed
attack_cooldown_seconds
current_floor_id
```

Avoid:

```gdscript
speed_value_number
thing
data
temp2
```

Temporary short names are acceptable for tiny mathematical scopes, but descriptive names are preferred.

---

## 8. Boolean Variables

Boolean names should read like a true-or-false question.

Good:

```gdscript
var is_alive: bool = true
var can_attack: bool = false
var has_completed_tutorial: bool = false
var should_respawn: bool = true
```

Avoid:

```gdscript
var alive: bool
var attack: bool
var completed: bool
```

Use prefixes such as:

- `is_`
- `has_`
- `can_`
- `should_`
- `was_`

---

## 9. Functions

Use lowercase `snake_case`, include parameter types, and include a return type.

```gdscript
func apply_damage(amount: float, source: Node) -> void:
    pass
```

Function names should normally start with an action.

Good:

```text
apply_damage
load_floor
accept_quest
calculate_experience_reward
find_nearest_target
```

Avoid:

```text
damage
floor
quest
do_thing
handle_stuff
```

Use `get_` when returning a value and `set_` when deliberately changing one:

```gdscript
func get_current_floor_id() -> StringName:
    return current_floor_id
```

Do not add trivial getter and setter functions unless they provide validation, signals, abstraction, or future safety.

---

## 10. Private Members

GDScript does not enforce private members in the same way as some languages.

Use a leading underscore for internal methods or callbacks that should not be treated as a public API.

```gdscript
func _update_animation() -> void:
    pass

func _on_health_changed(
    previous_health: float,
    current_health: float
) -> void:
    pass
```

Built-in Godot callbacks already use a leading underscore:

```gdscript
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass
```

Do not add underscores randomly.

---

## 11. Constants

Use `UPPER_SNAKE_CASE`.

```gdscript
const MAX_LEVEL: int = 100
const DEFAULT_FLOOR_ID: StringName = &"floor_001"
const SAVE_FILE_PATH: String = "user://savegame.json"
```

Constants should contain values that do not change during runtime.

---

## 12. Enums

Use `PascalCase` for the enum and `UPPER_SNAKE_CASE` for values.

```gdscript
enum QuestState {
    NOT_STARTED,
    IN_PROGRESS,
    COMPLETED,
    FAILED,
}
```

Typed use:

```gdscript
var current_state: QuestState = QuestState.NOT_STARTED
```

---

## 13. Signals

Use lowercase `snake_case`.

Signals should describe something that happened, not issue a vague command.

Good:

```gdscript
signal health_changed(
    previous_health: float,
    current_health: float
)

signal died(killer: Node)
signal quest_completed(quest_id: StringName)
signal floor_loaded(floor_id: StringName)
```

Avoid:

```gdscript
signal update
signal do_damage
signal thing_happened
```

Past-tense or completed-event names are preferred:

```text
damage_taken
health_changed
enemy_defeated
quest_accepted
save_completed
```

---

## 14. Signal Callback Names

Use this pattern:

```text
_on_<source>_<signal>
```

Examples:

```gdscript
func _on_health_component_died(killer: Node) -> void:
    pass

func _on_attack_timer_timeout() -> void:
    pass
```

When the source is obvious inside a small component, a shorter internal name may be used, but consistency is preferred.

---

## 15. Exported Variables

Use clear names and types.

```gdscript
@export_category("Movement")
@export var movement_speed: float = 5.0
@export var acceleration: float = 18.0

@export_category("Combat")
@export var attack_damage: float = 10.0
```

Use units in the name when confusion is possible:

```text
attack_cooldown_seconds
interaction_distance_metres
rotation_speed_degrees
```

Do not add units when the Godot type already makes the meaning obvious and the project consistently uses engine units.

---

## 16. Typed Collections

Specify collection types where practical.

```gdscript
var quest_ids: Array[StringName] = []
var enemies_by_id: Dictionary[StringName, Node] = {}
```

When a dictionary has a fixed data shape, consider creating a typed class or `Resource` instead of passing unstructured dictionaries through many systems.

---

## 17. Content IDs

Stable IDs use lowercase `snake_case`.

### Floor IDs

```text
floor_001
floor_002
floor_100
```

Always use three digits.

### Zone IDs

```text
zone_starting_city
zone_east_road
zone_first_field
```

### Spawn IDs

```text
spawn_city_plaza
spawn_city_gate
spawn_first_field_entrance
```

### NPC IDs

```text
npc_gate_guard
npc_beginner_quest_giver
```

### Enemy definition IDs

```text
enemy_wild_boar
enemy_field_wolf
```

### Enemy placement IDs

```text
enemy_spawn_boar_001
enemy_spawn_boar_002
```

### Quest IDs

```text
quest_first_hunt
quest_open_the_gate
```

### Item IDs

```text
item_beginner_sword
item_minor_health_potion
```

Never use a translated display name as the stable ID.

---

## 18. Display Names Versus IDs

Keep IDs and visible text separate.

Example:

```text
ID: quest_first_hunt
Display name: First Hunt
```

The display name may later be translated or rewritten. The ID should remain stable after saves depend on it.

---

## 19. Scene File Naming

Use the thing represented by the scene.

Good:

```text
player.tscn
wild_boar.tscn
quest_giver_npc.tscn
starting_city_gate_chunk.tscn
```

Reusable component scenes should end in `_component`:

```text
health_component.tscn
interaction_component.tscn
```

Top-level controllers may use a role suffix:

```text
floor_loader.tscn
zone_manager.tscn
```

Do not add `_scene` to every scene file.

Avoid:

```text
player_scene.tscn
enemy_scene.tscn
```

The `.tscn` extension already tells us it is a scene.

---

## 20. Script Suffixes

Use a suffix only when it clarifies responsibility.

Useful suffixes:

```text
_component
_controller
_manager
_definition
_state
_service
_view
_presenter
```

Examples:

```text
health_component.gd
player_controller.gd
floor_definition.gd
save_service.gd
quest_state.gd
```

Do not call every script a manager.

A manager should coordinate several objects or a system-wide process.

---

## 21. Resource Naming

Definition resource scripts:

```text
enemy_definition.gd
quest_definition.gd
floor_definition.gd
```

Individual `.tres` data assets:

```text
wild_boar.tres
first_hunt.tres
floor_001.tres
```

The folder gives additional context:

```text
res://game/quests/data/first_hunt.tres
```

---

## 22. Input Action Names

Input Map actions use lowercase `snake_case`.

Recommended future actions:

```text
player_move_left
player_move_right
player_move_forward
player_move_backward
player_jump
player_sprint
player_dodge
player_attack_primary
player_attack_secondary
player_interact
player_lock_on
ui_pause
ui_inventory
ui_quest_log
```

Prefix gameplay input with `player_` and interface input with `ui_`.

Do not bind gameplay logic directly to physical keys such as checking `"W"` inside scripts. Use Input Map actions.

---

## 23. Animation Names

Use lowercase `snake_case`.

Examples:

```text
idle
walk
run
attack_light_01
attack_light_02
hit_reaction
death
interact
```

Use numbered suffixes when several animations are part of a sequence.

---

## 24. Audio Names

Use lowercase `snake_case` and include enough context.

Examples:

```text
sword_swing_light_01.wav
sword_hit_flesh_01.wav
wild_boar_alert_01.wav
starting_city_ambience.ogg
floor_001_field_music.ogg
```

Avoid names based only on download filenames.

---

## 25. Material and Texture Names

Examples:

```text
stone_wall_material.tres
grass_ground_material.tres
starting_city_banner_albedo.png
beginner_sword_normal.png
```

Optional common texture suffixes:

```text
_albedo
_normal
_roughness
_metallic
_ao
_emission
```

Use the terminology selected by the project's art pipeline consistently.

---

## 26. Code Order

Use this general order inside GDScript files:

```text
1. class_name
2. extends
3. documentation comment
4. signals
5. enums
6. constants
7. @export variables
8. public variables
9. private/internal variables
10. @onready variables
11. built-in Godot callbacks
12. public methods
13. private/internal methods
14. signal callbacks
```

Example:

```gdscript
class_name ExampleComponent
extends Node

## Demonstrates the preferred code order.

signal value_changed(previous_value: float, current_value: float)

enum State {
    DISABLED,
    ENABLED,
}

const DEFAULT_VALUE: float = 10.0

@export var maximum_value: float = 100.0

var current_state: State = State.ENABLED

var _current_value: float = DEFAULT_VALUE

@onready var _timer: Timer = %Timer

func _ready() -> void:
    _current_value = clampf(_current_value, 0.0, maximum_value)

func get_current_value() -> float:
    return _current_value

func set_current_value(new_value: float) -> void:
    var clamped_value: float = clampf(new_value, 0.0, maximum_value)
    if is_equal_approx(clamped_value, _current_value):
        return

    var previous_value: float = _current_value
    _current_value = clamped_value
    value_changed.emit(previous_value, _current_value)

func _reset_value() -> void:
    set_current_value(DEFAULT_VALUE)

func _on_timer_timeout() -> void:
    _reset_value()
```

---

## 27. Documentation Comments

Use `##` for documentation comments on important classes, exported values, signals, and public methods.

```gdscript
## Stores and updates health for one actor.
class_name HealthComponent
extends Node

## Emitted after current health changes.
signal health_changed(
    previous_health: float,
    current_health: float
)
```

Use normal `#` comments for implementation notes.

Explain why something exists, not every obvious line.

Good:

```gdscript
# Delay removal until the death animation has emitted its completion signal.
```

Unhelpful:

```gdscript
# Set health to zero.
current_health = 0.0
```

---

## 28. Node References

Prefer unique-name references or exported typed references where appropriate.

Examples:

```gdscript
@onready var camera_pivot: Node3D = %CameraPivot

@export var health_component: HealthComponent
```

Avoid long fragile paths:

```gdscript
get_node("../../../../Player/Components/Health")
```

When required child nodes exist, document the expected scene structure.

---

## 29. Abbreviations

Avoid unclear abbreviations.

Good:

```text
experience_points
maximum_health
network_identity
```

Acceptable common abbreviations:

```text
id
ui
npc
rpc
fps
```

Use the same abbreviation everywhere. Do not mix:

```text
experience
exp
xp
```

For this project, use:

- `experience` in code and documentation.
- `XP` only in player-facing interface text where appropriate.

---

## 30. Numbers in Names

Use numbers only when they represent a real sequence, version, or stable placement.

Good:

```text
floor_001
attack_light_01
enemy_spawn_boar_003
```

Avoid:

```text
player2_final
script3
new_map_7
```

---

## 31. Temporary Files

Temporary developer content must be clearly marked.

Examples:

```text
dev_test_arena.tscn
debug_spawn_menu.gd
placeholder_beginner_sword.glb
```

Temporary content should not silently become production content.

Place isolated development scenes in an appropriate test folder:

```text
res://tests/manual/dev_test_arena.tscn
```

---

## 32. Prohibited Naming Patterns

Do not use:

- Spaces in paths.
- Random capitalisation.
- `final`, `final2`, or `new` as version control.
- Personal names as system names.
- File names with no meaning.
- Visible translated names as persistent IDs.
- One generic `manager.gd` for unrelated systems.
- One global `utils.gd` containing unrelated functions.

Use Git history and descriptive names instead.
