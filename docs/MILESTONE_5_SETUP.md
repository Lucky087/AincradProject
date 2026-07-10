# Milestone 5 Setup — Experience and Levelling

**Project:** Aincrad-Inspired RPG  
**Engine:** Godot 4.7  
**Language:** Typed GDScript  
**Last updated:** 2026-07-10

---

## 1. Milestone Result

Milestone 5 adds reusable player progression without replacing any existing movement, camera, interaction, health, sword, training-dummy, or boar behavior.

The player now has:

- A current level.
- Current experience within that level.
- A calculated requirement for the next level.
- A configurable maximum level.
- A typed `add_experience(amount)` method.
- Support for several level-ups from one large reward.
- Typed experience and level-up signals.
- A separate progression HUD.

The existing boar gives 40 XP after a valid player kill and can give the reward again after it respawns.

---

## 2. New Files

```text
res://AincradProject/scripts/components/player_progression.gd
res://AincradProject/scripts/ui/progression_ui.gd
res://AincradProject/scenes/ui/progression_ui.tscn
res://AincradProject/docs/MILESTONE_5_SETUP.md
```

Godot should create new script `.uid` files automatically when the project opens. Do not create, edit, or delete those files manually.

---

## 3. Modified Files

```text
res://AincradProject/scenes/player/player.tscn
res://AincradProject/scripts/enemies/boar_enemy.gd
res://AincradProject/scenes/enemies/boar_enemy.tscn
res://AincradProject/docs/CURRENT_TASKS.md
res://AincradProject/docs/DECISION_LOG.md
```

No test-world edit is required because the existing boar instance automatically uses the updated boar scene and script.

The following important files remain unchanged:

```text
res://AincradProject/scripts/player/player_controller.gd
res://AincradProject/scripts/player/player_combat.gd
res://AincradProject/scripts/components/health_component.gd
res://AincradProject/scripts/enemies/training_dummy.gd
res://AincradProject/scenes/enemies/training_dummy.tscn
res://AincradProject/scenes/ui/health_ui.tscn
res://AincradProject/scripts/ui/health_ui.gd
res://AincradProject/scenes/world/test_world.tscn
```

---

## 4. Player Scene Additions

The existing player gains two children while all previous nodes remain in place:

```text
Player
├── HealthComponent
├── PlayerProgression
├── existing movement, camera, interaction, and combat nodes
├── HealthUI
├── ProgressionUI
└── InteractionUI
```

### `PlayerProgression` Inspector values

```text
Starting Level: 1
Starting Experience: 0
Maximum Level: 100
Base Experience Per Level: 100
```

### `ProgressionUI` Inspector value

```text
Progression Component Path: ../PlayerProgression
```

---

## 5. Experience Formula

The component uses:

```text
required experience = base experience per level × current level
```

With the default base value of 100:

```text
Level 1 → 2: 100 XP
Level 2 → 3: 200 XP
Level 3 → 4: 300 XP
```

The formula is kept inside:

```gdscript
calculate_experience_required_for_level(level)
```

This allows a later curve to replace the calculation without changing the boar, UI, or callers of `add_experience()`.

---

## 6. Large Rewards and Excess Experience

`add_experience(amount)` uses a loop so one large reward can cross several level boundaries.

Example from Level 1 with 0 XP:

```text
Add 350 XP
- Spend 100 XP to reach Level 2
- Spend 200 XP to reach Level 3
- Carry 50 XP into Level 3
Result: Level 3, 50 / 300 XP
```

Experience beyond the configured maximum level is discarded because no later level exists.

---

## 7. How the Boar Awards XP

The existing sword calls the boar's health component like this:

```text
HealthComponent.apply_damage(damage, player)
```

When the killing hit reaches zero health, the existing health component emits:

```text
died(source)
```

The boar uses that killing source to find the responsible player:

1. Start at the supplied damage source.
2. Walk upward through its parents.
3. Stop at the node in the existing `players` group.
4. Find its direct `PlayerProgression` child.
5. Call `add_experience(40)`.

This does not depend on a fragile path such as `../../Player`.

### Boar Inspector value

```text
Experience Reward: 40
```

Each boar scene instance may use a different reward later.

---

## 8. Duplicate-Reward Protection

The boar has a private per-life flag:

```text
_experience_reward_granted
```

Rules:

- The flag starts as `false`.
- The first valid death reward changes it to `true`.
- Additional death callbacks during the same defeated life cannot award XP.
- The flag returns to `false` only in the existing respawn callback.
- Removing or freeing the boar does not award XP because reward logic exists only in the health death callback.

The training dummy is unchanged and gives no XP.

---

## 9. Progression UI Hierarchy and Placement

```text
ProgressionUI (CanvasLayer)
├── ProgressionPanel (PanelContainer)
│   └── MarginContainer
│       └── VBoxContainer
│           ├── LevelLabel
│           ├── ExperienceLabel
│           ├── ExperienceBar
│           └── LevelUpLabel
└── LevelUpTimer
```

The panel is positioned directly below the existing health UI:

```text
Left: 24
Top: 112
Right: 344
Bottom: 246
```

The UI listens to:

```text
experience_changed
levelled_up
```

It does not use `_process()`.

### Level-up message

```text
Message: Level Up!
Duration: 1.6 seconds
```

The timer restarts when another level is gained, including when one large reward produces multiple levels.

---

## 10. Health Growth Decision

The existing `HealthComponent` safely supports:

- Reading health.
- Applying damage.
- Restoring health.
- Resetting to its current maximum.

It does not currently provide a public method that safely changes maximum health, clamps current health, and emits a consistent update.

Therefore M5 does not increase maximum health. The possible `+5 maximum HP per level and full heal` behavior is recorded as a future task instead of directly changing an exported property and risking inconsistent health state.

---

## 11. Opening the Project

1. Extract the archive without changing its folders.
2. Open the outer folder containing `project.godot` in Godot 4.7.
3. Let Godot import the new scripts and create their `.uid` files normally.
4. Do not move the nested `AincradProject/` folder.
5. Press F5 to run the existing test world.

No new Input Map action is required for progression.

---

## 12. Required Test Sequence

The existing boar gives 40 XP and respawns after five seconds.

### Initial state

- Confirm the health UI still shows `HP: 100 / 100`.
- Confirm the progression UI shows `Level 1`.
- Confirm it shows `XP: 0 / 100`.
- Confirm the experience bar is empty.

### First boar defeat

- Defeat the boar with four successful sword hits.
- Confirm the boar still dies normally.
- Confirm the UI changes to `XP: 40 / 100`.
- Confirm the player remains Level 1.
- Confirm no `Level Up!` message appears.

### Second boar defeat

- Wait for the boar to respawn.
- Defeat it again.
- Confirm the UI changes to `XP: 80 / 100`.
- Confirm the player remains Level 1.

### Third boar defeat

- Wait for the next respawn.
- Defeat it a third time.
- Confirm the player becomes Level 2.
- Confirm excess XP is carried forward as `XP: 20 / 200`.
- Confirm the progress bar now represents 20 out of 200.
- Confirm `Level Up!` appears for approximately 1.6 seconds.
- Confirm the Output panel prints the Level 1 to Level 2 debug message.

---

## 13. Duplicate and Source Tests

- Confirm one boar death never adds 80 XP.
- Keep attacking the defeated boar and confirm no additional XP is added.
- Confirm the boar can award another 40 XP only after its respawn.
- Attack and defeat the training dummy repeatedly.
- Confirm the training dummy never changes the player's XP.
- Confirm a boar that is removed from the scene for a non-health reason would not run reward logic.

---

## 14. Regression Checklist

### Player and camera

- WASD movement still works.
- Mouse camera control still works.
- Jumping and gravity still work.
- Shift sprinting still works.
- Escape still releases and captures the mouse.

### Interaction

- The interaction prompt still appears and disappears correctly.
- The sign still displays its message.
- The NPC still displays dialogue.
- The chest still opens only once.

### Health and combat

- The health UI remains visible and updates when the boar hits the player.
- The sword still swings once per accepted input.
- The training dummy still takes 25 damage and resets.
- The boar still takes 25 damage per sword hit.

### Boar behavior

- The boar remains idle while the player is far away.
- It detects and chases the player.
- It stops at attack range.
- It damages the player only once per attack.
- It returns to spawn when the player escapes.
- It reacts when hit.
- It stops after death.
- It respawns at full health at its original transform.

### Errors

- Confirm there are no parser errors.
- Confirm there are no missing-resource errors.
- Confirm there are no missing-node errors from `ProgressionUI`.
- Confirm no existing `.uid` file was manually changed or deleted.

---

## 15. Expected Milestone Result

After three valid boar defeats, the exact progression state should be:

```text
Level 2
XP: 20 / 200
```

All existing M1–M4 features should continue to work unchanged.
