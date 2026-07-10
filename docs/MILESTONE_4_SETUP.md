# Milestone 4 Setup and Test Guide

**Milestone:** First Enemy  
**Engine:** Godot 4.7  
**Language:** Typed GDScript

---

## 1. What This Milestone Adds

Milestone 4 adds one hostile primitive boar that:

- Idles while the player is far away.
- Detects the player inside a configurable range.
- Chases using `CharacterBody3D` movement.
- Stops near the player.
- Performs a visible lunge attack.
- Damages the player's existing `HealthComponent` once per attack.
- Rejects damage when the player is too far away or blocked by a solid World body.
- Takes sword damage through the existing layer-3 hurtbox system.
- Briefly reacts when hit.
- Dies at zero health.
- Stops moving and attacking while defeated.
- Respawns at its exact original scene position.
- Returns to its spawn if the player escapes or pulls it too far away.

The existing movement, camera, interactions, health UI, sword combat, and training dummy are preserved.

This milestone does not add loot, experience, inventory, quests, bosses, saving, multiplayer, or external assets.

---

## 2. New Files

```text
AincradProject/scripts/enemies/boar_enemy.gd
AincradProject/scenes/enemies/boar_enemy.tscn
AincradProject/docs/MILESTONE_4_SETUP.md
```

Because `project.godot` is one folder above `AincradProject`, Godot shows the script path as:

```text
res://AincradProject/scripts/enemies/boar_enemy.gd
```

Godot may generate `boar_enemy.gd.uid` when the editor imports the new script. Let Godot create it. Do not create, edit, rename, or delete `.uid` files manually.

---

## 3. Modified Files

```text
AincradProject/scenes/player/player.tscn
AincradProject/scenes/world/test_world.tscn
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

The player scene changed only by adding its existing root node to the `players` group.

These working scripts remain unchanged:

```text
AincradProject/scripts/player/player_controller.gd
AincradProject/scripts/player/player_combat.gd
AincradProject/scripts/components/health_component.gd
```

No existing public method or signal was changed.

---

## 4. Boar Scene Hierarchy

```text
BoarEnemy (CharacterBody3D)
├── HealthComponent
├── CollisionShape3D
├── AttackPivot
│   └── VisualRoot
│       ├── Body
│       ├── Head
│       ├── Snout
│       ├── FrontLeftLeg
│       ├── FrontRightLeg
│       ├── BackLeftLeg
│       ├── BackRightLeg
│       ├── LeftEye
│       ├── RightEye
│       ├── LeftTusk
│       └── RightTusk
├── Hurtbox (Area3D)
│   └── CollisionShape3D
├── StatusLabel
├── AttackCooldownTimer
├── HitReactionTimer
└── RespawnTimer
```

### Root `BoarEnemy`

```text
Type: CharacterBody3D
Group: enemies
Collision Layer: 1 — World
Collision Mask: 1 — World
Floor Snap Length: 0.3
Floor Stop On Slope: On
```

The root owns physical movement and collision.

### `HealthComponent`

```text
Maximum Health: 100
Start At Maximum Health: On
Is Invulnerable: Off
```

The player sword already searches from the boar's hurtbox toward this component. No change to `player_combat.gd` is required.

### Root body `CollisionShape3D`

```text
Shape: BoxShape3D
Size: (1.5, 1.2, 2.25)
Position: (0, 0.62, 0)
```

This stops the boar and player from walking through solid World objects.

### `AttackPivot`

The visible boar is beneath this node. The attack script moves the pivot forward and back to create a simple lunge. Proper animation assets can replace this later.

### `Hurtbox`

```text
Type: Area3D
Collision Layer: 3 — Hurtbox
Collision Mask: None
Monitoring: Off
Monitorable: On
Shape Size: (1.8, 1.5, 2.75)
Shape Position: (0, 0.75, 0)
```

The existing player `ShapeCast3D` detects this layer and applies damage through the existing `HealthComponent` API.

### `StatusLabel`

The label displays the boar's HP and current test state:

```text
Idle
Chasing
Attacking
Hit
Returning
Defeated
```

This label is development feedback and can be removed during later presentation polish.

### Timers

```text
AttackCooldownTimer: 1.2 seconds, one shot
HitReactionTimer: 0.18 seconds, one shot
RespawnTimer: 5.0 seconds, one shot
```

The script starts these timers with the exported values, so changing the script exports also changes runtime timing.

---

## 5. Important Boar Inspector Values

Select the root `BoarEnemy` node to edit these values.

### Targeting

```text
Player Group: players
Detection Range: 9.0
Disengage Range: 13.0
Maximum Leash Distance: 14.0
Player Search Interval Seconds: 0.5
```

- `Detection Range` begins the chase.
- `Disengage Range` is larger, preventing rapid state flickering at the detection boundary.
- `Maximum Leash Distance` stops the player from dragging the boar indefinitely away from its spawn.
- `Player Search Interval` is used only if the player reference is missing or becomes invalid.

### Movement

```text
Movement Speed: 3.2
Movement Acceleration: 12.0
Rotation Speed: 9.0
Spawn Arrival Distance: 0.35
```

Movement runs in `_physics_process()` and uses `move_and_slide()`.

### Attack

```text
Attack Damage: 12
Attack Stop Distance: 1.75
Maximum Attack Hit Distance: 2.25
Attack Windup Seconds: 0.25
Attack Recovery Seconds: 0.30
Attack Cooldown Seconds: 1.20
Attack Lunge Distance: 0.45
```

The stop distance controls when the boar begins an attack. The larger hit distance allows a small tolerance for player and enemy movement, but the hit is still rechecked at the exact damage moment.

### Reaction and respawn

```text
Hit Reaction Seconds: 0.18
Respawn Delay Seconds: 5.0
```

---

## 6. How the Boar Finds the Player

The existing player root now belongs to this group:

```text
players
```

The player hierarchy and scripts were not replaced.

At startup, the boar calls:

```gdscript
get_tree().get_first_node_in_group(&"players")
```

It then looks for a direct child `HealthComponent` on that player.

This avoids a fragile absolute path such as:

```text
../../Player
```

If the player is temporarily unavailable, the boar retries at a limited interval instead of searching every frame.

---

## 7. Enemy Behaviour

The boar uses these internal states:

```text
IDLE
CHASING
ATTACKING
HURT
RETURNING
DEAD
```

### Idle

The boar remains still while the player is outside detection range.

### Chasing

When the player enters detection range, the boar moves directly toward the player and rotates to face its movement direction.

### Attacking

At `attack_stop_distance`, the boar stops and lunges once.

At the hit moment, it checks:

1. The player still exists.
2. The player is alive.
3. The player is no farther than `maximum_attack_hit_distance`.
4. A World-layer ray reaches the player before hitting another solid body.

Only one call to `HealthComponent.apply_damage()` is attempted in one attack sequence.

### Hurt

Sword damage interrupts an active boar attack, briefly pauses movement, and squashes the primitive visual.

### Returning

The boar returns to its stored spawn when:

- The player moves beyond disengage range.
- The boar exceeds its maximum leash distance.
- The player has no living health component.

### Dead

At zero health, the boar:

- Stops movement.
- Cancels its attack.
- Disables its body collision.
- Disables its hurtbox.
- Falls sideways visually.
- Starts the respawn timer.

### Respawn

After the timer, it restores:

- Original transform.
- Original visual transforms.
- Body collision.
- Hurtbox.
- Full health.
- Idle state.

---

## 8. Test-World Placement

The boar is already added to the existing test world:

```text
TestWorld
└── HostileEnemies
    └── BoarEnemy
```

Its instance position is:

```text
X: -10
Y: 0.05
Z: -8
```

The player starts far enough away that the boar should initially remain idle.

To add another boar manually later:

1. Open `AincradProject/scenes/world/test_world.tscn`.
2. Select `HostileEnemies`.
3. Drag `boar_enemy.tscn` from the FileSystem dock onto that node.
4. Move the new instance to an open part of the floor.
5. Each instance automatically stores its own authored transform as its spawn.

Do not duplicate the script or create another enemy folder.

---

## 9. Navigation Setup

No navigation node or navigation mesh is used in M4.

Nothing needs to be generated or baked.

The current greybox is open enough to test enemy states with direct movement. The boar collides with cubes and walls but does not intelligently path around them.

A future field milestone should add `NavigationRegion3D` and `NavigationAgent3D` when the real layout includes routes, buildings, fences, or terrain that require pathfinding.

---

## 10. Controls

```text
WASD: Move
Mouse: Rotate camera
Space: Jump
Hold Shift: Sprint
E: Interact
Left Mouse Button: Sword attack
Escape: Release or recapture mouse
```

No new Input Map action is required for M4.

---

## 11. Complete Test Checklist

### Project loading

- [ ] Open the folder containing `project.godot` in Godot 4.7.
- [ ] Let Godot import the new script and generate its `.uid` file normally.
- [ ] Confirm no existing files have been moved by the editor.
- [ ] Confirm the Output and Debugger show no parser or missing-resource errors.

### Existing functionality regression

- [ ] Press F5.
- [ ] Confirm WASD movement works.
- [ ] Confirm mouse camera control works.
- [ ] Confirm Space jumps.
- [ ] Confirm gravity works.
- [ ] Confirm Shift sprinting works.
- [ ] Confirm Escape releases and recaptures the mouse.
- [ ] Confirm the health UI begins at `HP: 100 / 100`.
- [ ] Confirm E interaction still works on the sign, NPC, and chest.
- [ ] Confirm the training dummy still takes 25 damage per sword hit.
- [ ] Confirm the training dummy still resets after defeat.

### Idle and detection

- [ ] Find the boar near `(-10, 0, -8)`.
- [ ] Stay far away and confirm its label says `Idle`.
- [ ] Approach until inside approximately nine metres.
- [ ] Confirm its label changes to `Chasing`.
- [ ] Confirm it moves and rotates toward the player.

### Attack

- [ ] Let the boar get close.
- [ ] Confirm it stops instead of standing inside the player.
- [ ] Confirm the primitive boar visibly lunges.
- [ ] Confirm one successful lunge changes player health from 100 to 88.
- [ ] Confirm health does not continue dropping several times during one lunge.
- [ ] Confirm the cooldown creates a pause before the next attack.
- [ ] Move away during the windup and confirm an excessive-distance hit is rejected.
- [ ] Place a cube or wall between the boar and player and confirm a blocked attack deals no damage.

### Return behaviour

- [ ] Let the boar chase.
- [ ] Sprint beyond its disengage or leash range.
- [ ] Confirm the label changes to `Returning`.
- [ ] Confirm the boar moves toward its original spawn.
- [ ] Confirm it stops and becomes `Idle` when it reaches spawn.

### Taking damage

- [ ] Approach and face the boar.
- [ ] Attack once with the sword.
- [ ] Confirm the boar changes from 100 HP to 75 HP.
- [ ] Confirm the brief hit squash is visible.
- [ ] Confirm a boar lunge is interrupted when the boar is hit.
- [ ] Confirm four sword hits defeat it.

### Death and respawn

- [ ] Confirm the defeated boar falls sideways.
- [ ] Confirm it stops moving.
- [ ] Confirm it stops attacking.
- [ ] Confirm further sword attacks do not damage it while defeated.
- [ ] Wait five seconds.
- [ ] Confirm it returns to its original spawn position.
- [ ] Confirm its label returns to `HP: 100 / 100` and `Idle`.
- [ ] Confirm it can detect, chase, attack, take damage, die, and respawn again.

### Final debugger check

- [ ] Confirm no critical errors appear after a full combat and respawn cycle.
- [ ] Confirm no missing-node warnings appear for the boar.
- [ ] Confirm no earlier system stopped working.

---

## 12. Expected Limitations

These are intentional in M4:

- The boar does not navigate around complex obstacles.
- The player has no respawn behaviour yet; restart the running scene after player death.
- The boar has no loot or experience reward.
- The boar uses tweened primitive movement instead of imported animations.
- The boar targets only the first local player in the `players` group.
- The boar state label is developer-facing test information.
