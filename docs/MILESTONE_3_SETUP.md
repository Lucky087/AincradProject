# Milestone 3 Setup and Test Guide

**Milestone:** Health and Basic Sword Combat  
**Engine:** Godot 4.7  
**Language:** Typed GDScript

---

## 1. What This Milestone Adds

Milestone 3 adds the smallest reusable combat test:

- One reusable `HealthComponent`.
- A player health component and HP display.
- A primitive sword attached to the existing player visuals.
- One left-click sword swing.
- A forward `ShapeCast3D` attack boundary.
- A dedicated hurtbox collision layer.
- One stationary primitive training dummy.
- Dummy health, damage feedback, defeat, and automatic reset.

The existing movement controller and interaction system are preserved.

This milestone does not add enemy movement, enemy attacks, experience, inventory, quests, saving, or multiplayer.

---

## 2. New Files

These files were added inside the existing structure:

```text
AincradProject/scripts/components/health_component.gd
AincradProject/scripts/player/player_combat.gd
AincradProject/scripts/enemies/training_dummy.gd
AincradProject/scripts/ui/health_ui.gd
AincradProject/scenes/enemies/training_dummy.tscn
AincradProject/scenes/ui/health_ui.tscn
AincradProject/docs/MILESTONE_3_SETUP.md
```

Because the actual `project.godot` file is one level above `AincradProject`, Godot displays these as paths such as:

```text
res://AincradProject/scripts/components/health_component.gd
```

Do not move them to remove the `AincradProject` part. The uploaded project already uses this structure.

Godot may create matching `.uid` files for new scripts when the project is opened. Let Godot create those automatically. Do not manually create, edit, rename, or delete `.uid` files.

---

## 3. Modified Files

Only these existing project files were intentionally modified:

```text
project.godot
AincradProject/scenes/player/player.tscn
AincradProject/scenes/world/test_world.tscn
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

The working movement script remains unchanged:

```text
AincradProject/scripts/player/player_controller.gd
```

The existing interaction scripts and scenes also remain unchanged.

---

## 4. Player Scene Additions

The following nodes were added without removing the existing nodes:

```text
Player
├── HealthComponent
├── VisualRoot
│   ├── existing player visuals
│   ├── SwordPivot
│   │   ├── Handle
│   │   ├── Guard
│   │   └── Blade
│   └── AttackShapeCast
├── existing camera and interaction nodes
├── PlayerCombat
├── HealthUI
└── InteractionUI
```

### HealthComponent

Important Inspector values:

```text
Maximum Health: 100
Start At Maximum Health: On
Is Invulnerable: Off
```

### AttackShapeCast

Important Inspector values:

```text
Shape: BoxShape3D
Position: (0, 0.95, -0.45)
Target Position: (0, 0, -1.15)
Collision Mask: Layer 3 only
Collide With Areas: On
Collide With Bodies: Off
Enabled: On
```

It is beneath `VisualRoot`, so it follows the direction the player body is facing.

### PlayerCombat

Important Inspector values:

```text
Attack Damage: 25
Swing Duration Seconds: 0.16
Recovery Duration Seconds: 0.18
Cooldown Seconds: 0.18

Attack Shape Cast Path:
../VisualRoot/AttackShapeCast

Sword Pivot Path:
../VisualRoot/SwordPivot

Health Component Path:
../HealthComponent
```

### HealthUI

The instanced health UI uses:

```text
Health Component Path:
../HealthComponent
```

The HP display appears at the upper-left corner.

The player HP will stay at 100 during M3 because no enemy attack exists yet. The same health component is already ready for incoming damage in the next milestone.

---

## 5. Training Dummy Scene

The dummy scene contains:

```text
TrainingDummy
├── HealthComponent
├── CollisionShape3D
├── VisualRoot
│   ├── Base
│   ├── Post
│   ├── Arms
│   └── Target
├── Hurtbox
│   └── CollisionShape3D
├── StatusLabel
└── ResetTimer
```

### Root body

```text
Type: StaticBody3D
Collision Layer: Layer 1 — World
Collision Mask: Layer 1 — World
```

The root body prevents the player from walking through the dummy.

### Hurtbox

```text
Type: Area3D
Collision Layer: Layer 3 — Hurtbox
Collision Mask: None
Monitoring: Off
Monitorable: On
```

The player sword checks this hurtbox rather than using ordinary movement collision as combat detection.

### Dummy health

```text
Maximum Health: 100
Player damage per attack: 25
Attacks required to defeat: 4
Reset delay: 3 seconds
```

---

## 6. Test-World Addition

The dummy was added to the existing test world under:

```text
TestWorld
└── CombatTargets
    └── TrainingDummy
```

Its position is:

```text
X: 6
Y: 0
Z: 10.5
```

The sign, NPC, chest, greybox obstacles, player spawn, light, and environment remain in place.

---

## 7. Input Map

The project contains this new action:

```text
player_attack_primary
```

Binding:

```text
Left Mouse Button
```

To verify it manually:

1. Open **Project → Project Settings**.
2. Open **Input Map**.
3. Search for `player_attack_primary`.
4. Expand the action.
5. Confirm the left mouse button is listed.

The existing actions must remain present:

```text
player_move_forward
player_move_backward
player_move_left
player_move_right
player_jump
player_sprint
player_toggle_mouse_capture
interact
```

---

## 8. Collision Layers

The project now names the first three 3D physics layers:

```text
Layer 1: World
Layer 2: Interactable
Layer 3: Hurtbox
```

Current uses:

- Player movement and ordinary physical objects use `World`.
- The existing interaction objects also use `Interactable`.
- Damageable combat areas use `Hurtbox`.
- The player attack shape detects only `Hurtbox`.

Do not change the existing interaction ray mask while testing M3.

---

## 9. Controls

```text
WASD: Move
Mouse: Rotate camera
Space: Jump
Hold Shift: Sprint
E: Interact
Left Mouse Button: Sword attack
Escape: Release or recapture mouse
```

A sword attack is ignored while the cursor is released. Press Escape again to capture the mouse before attacking.

---

## 10. Complete Test Checklist

### Project loading

- [ ] Open the folder containing `project.godot` in Godot 4.7.
- [ ] Allow Godot to scan the new scripts and generate new `.uid` files normally.
- [ ] Confirm no files were manually moved by the editor.
- [ ] Confirm the Output and Debugger show no parser errors.

### Existing behaviour

- [ ] Press F5.
- [ ] Confirm WASD movement works.
- [ ] Confirm the mouse camera works.
- [ ] Confirm Space jumps.
- [ ] Confirm gravity returns the player to the floor.
- [ ] Confirm Shift still sprints.
- [ ] Confirm Escape releases and recaptures the mouse.
- [ ] Confirm E still interacts with the sign, NPC, and chest.

### Player health UI

- [ ] Confirm the health panel appears at the upper-left corner.
- [ ] Confirm it reads `HP: 100 / 100`.
- [ ] Confirm it does not cover the interaction prompt.

### Sword visual and input

- [ ] Confirm the primitive sword appears on the player.
- [ ] Capture the mouse.
- [ ] Click the left mouse button.
- [ ] Confirm the sword visibly swings.
- [ ] Click repeatedly during one swing.
- [ ] Confirm attacks do not overlap or create several simultaneous swings.

### Range and facing

- [ ] Stand far from the dummy and attack.
- [ ] Confirm the dummy loses no health.
- [ ] Stand close but face away and attack.
- [ ] Confirm the dummy loses no health.
- [ ] Stand close and face the dummy.
- [ ] Attack once.
- [ ] Confirm the dummy reads `HP: 75 / 100`.

### Damage and defeat

- [ ] Confirm every successful attack removes exactly 25 HP.
- [ ] Confirm one swing does not damage the same dummy more than once.
- [ ] Attack until the dummy reaches zero health.
- [ ] Confirm the dummy displays its defeated message.
- [ ] Confirm it tilts as defeat feedback.
- [ ] Try attacking the defeated dummy.
- [ ] Confirm it takes no additional damage.
- [ ] Wait three seconds.
- [ ] Confirm it returns upright.
- [ ] Confirm it returns to `HP: 100 / 100`.
- [ ] Confirm it can be damaged again.

### Final regression check

- [ ] Walk into the dummy and confirm physical collision works.
- [ ] Confirm the interaction prompt does not appear for the dummy.
- [ ] Confirm the sign, NPC, and chest remain interactable.
- [ ] Confirm no critical errors appear in the debugger.

---

## 11. Expected Result

After local verification, Milestone 3 proves that reusable health, separate combat boundaries, a player sword attack, and damage feedback work without mixing combat into the movement or interaction scripts.
