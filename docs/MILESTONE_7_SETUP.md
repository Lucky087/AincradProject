# Milestone 7 Setup — Save and Load

**Project:** Aincrad-Inspired RPG  
**Engine:** Godot 4.7  
**Save version:** 1  
**Save path:** `user://savegame.json`  
**Last updated:** 2026-07-10

---

## 1. Milestone Result

Milestone 7 adds a reusable, versioned JSON save system without replacing the existing player, health, progression, quest, combat, enemy, or UI systems.

The save contains:

- Player global position.
- Current health.
- Maximum health.
- Current level.
- Current experience.
- Configured maximum level.
- Every registered quest ID.
- Quest state.
- Quest objective progress.
- Whether the quest reward has already been claimed.

It deliberately does not save:

- Boar attack, chase, death, or respawn state.
- Active attack animations or timers.
- Training-dummy state.
- Temporary interaction messages.
- Camera rotation.
- Inventory, equipment, gold, or items.

---

## 2. New Files

```text
res://AincradProject/scripts/systems/save_manager.gd
res://AincradProject/scripts/ui/save_status_ui.gd
res://AincradProject/scenes/ui/save_status_ui.tscn
res://AincradProject/docs/MILESTONE_7_SETUP.md
```

Godot should generate `.uid` files for the two new scripts when the project is opened. Do not create, edit, or delete those UID files manually.

---

## 3. Modified Files

```text
res://project.godot
res://AincradProject/scenes/player/player.tscn
res://AincradProject/scripts/components/health_component.gd
res://AincradProject/scripts/components/player_progression.gd
res://AincradProject/scripts/components/player_quest_log.gd
res://AincradProject/scripts/ui/quest_ui.gd
res://AincradProject/docs/CURRENT_TASKS.md
res://AincradProject/docs/DECISION_LOG.md
```

No existing public method, signal, node, resource, or path was removed or renamed.

---

## 4. Where the Save File Is Stored

The virtual path is:

```text
user://savegame.json
```

`user://` is Godot's writable per-user data directory. It is separate from the project folder and remains writable in exported games.

The exact physical path depends on the operating system and project settings. Every successful save and load prints the globalized path in Godot's Output panel.

The current project name is:

```text
Aincrad-Inspired Greybox
```

The file can also be located by opening the project's user-data directory from Godot or by reading the printed path.

---

## 5. Input Map

The supplied `project.godot` already includes:

| Action | Physical key | Purpose |
|---|---|---|
| `save_game` | K | Save the current player state |
| `load_game` | L | Load `user://savegame.json` |

The manager uses `_unhandled_input()` and ignores keyboard echo events. Saving or loading therefore runs once when the key is pressed, not continuously while it is held.

To create the actions manually:

1. Open **Project → Project Settings → Input Map**.
2. Add `save_game`.
3. Bind it to the physical K key.
4. Add `load_game`.
5. Bind it to the physical L key.
6. Keep the names lowercase and exact.

---

## 6. SaveManager Autoload

`project.godot` contains:

```ini
[autoload]

SaveManager="*res://AincradProject/scripts/systems/save_manager.gd"
```

The Autoload is appropriate because saving and loading are application-wide actions that must remain available independently of the currently loaded gameplay scene.

`SaveManager` has one responsibility:

```text
Find the current local player, coordinate existing component save interfaces,
read or write the versioned file, and announce user-facing status messages.
```

It does not own duplicate health, progression, or quest variables.

The script's typed class is named `SaveManagerService`. The Autoload node is named `SaveManager`, preventing a global class-name conflict.

---

## 7. Save File Structure

A normal save resembles:

```json
{
  "save_version": 1,
  "player": {
    "position": {
      "x": 0.0,
      "y": 1.0,
      "z": 0.0
    },
    "current_health": 76.0,
    "maximum_health": 100.0
  },
  "progression": {
    "current_level": 1,
    "current_xp": 40,
    "maximum_level": 100
  },
  "quests": {
    "boar_hunt": {
      "state": "active",
      "progress": 2,
      "reward_claimed": false
    }
  }
}
```

### `save_version`

Current value:

```text
1
```

A save with a missing, invalid, or unsupported version is rejected safely. Later formats can add explicit migration code without guessing what an older file means.

### `player`

Stores position and the existing health component's persistent values.

### `progression`

Stores the current level, current-level XP, and configured maximum level.

### `quests`

Uses stable quest IDs as JSON keys. Each quest stores a readable state name, objective progress, and its permanent reward gate.

---

## 8. Health Save Interface

`HealthComponent` now provides:

```gdscript
get_save_data() -> Dictionary
load_save_data(data: Dictionary) -> void
```

Saved fields:

```text
current_health
maximum_health
```

Loading:

- Accepts integer or floating-point JSON numbers.
- Requires maximum health to be at least 1.
- Clamps current health between 0 and maximum health.
- Emits `health_changed` so `HealthUI` refreshes immediately.
- Does not emit `damage_taken`, `health_restored`, or `died`.

Not replaying those gameplay signals prevents a save load from acting like a new attack, heal, or death.

---

## 9. Progression Save Interface

`PlayerProgression` now provides:

```gdscript
get_save_data() -> Dictionary
load_save_data(data: Dictionary) -> void
```

Saved fields:

```text
current_level
current_xp
maximum_level
```

Loading:

- Clamps the level between 1 and maximum level.
- Rejects negative XP by clamping it to zero.
- Recalculates the current XP requirement using the existing formula.
- Normalizes oversized XP safely across levels.
- Emits `experience_changed` so `ProgressionUI` refreshes immediately.
- Does not emit `levelled_up`, because loading an existing level must not replay a Level Up event.

The existing formula remains unchanged:

```text
required XP = 100 × current level
```

---

## 10. Quest Save Interface

`PlayerQuestLog` now provides:

```gdscript
get_save_data() -> Dictionary
load_save_data(data: Dictionary) -> void
```

It also adds:

```gdscript
signal quest_data_loaded
```

`QuestUI` listens for that signal and refreshes without replaying the normal quest-completion animation.

Supported saved state names:

```text
not_started
active
ready_to_turn_in
completed
```

Unknown saved quest IDs are skipped with a warning. This prevents an old or modified save from crashing when quest content is no longer registered.

---

## 11. Completed-Quest Reward Protection

Boar Hunt already protects its reward with both quest state and a per-quest reward gate.

During load, `PlayerQuestLog` normalizes these values:

- `completed` always forces `reward_claimed = true`.
- `reward_claimed = true` always forces the state to `completed`.
- Completed progress is forced to the objective target.
- A ready-to-turn-in quest is restored at full objective progress.
- A not-started quest is restored at zero progress with no reward claim.

Therefore, a completed Boar Hunt cannot be loaded into a rewardable state accidentally.

After loading a completed quest:

1. The NPC reads the quest as Completed.
2. It displays the thank-you dialogue.
3. `turn_in_quest()` cannot run because the state is not Ready to Turn In.
4. The reward gate also remains closed.
5. No second 100 XP reward is possible.

---

## 12. Save-Status UI

Player scene addition:

```text
Player
└── SaveStatusUI
```

Scene hierarchy:

```text
SaveStatusUI (CanvasLayer)
├── StatusPanel
│   └── MarginContainer
│       └── MessageLabel
└── StatusTimer
```

Important values:

| Property | Value |
|---|---:|
| Canvas layer | `20` |
| Save manager path | `/root/SaveManager` |
| Message duration | `2.0` seconds |
| Position | Top-centre of the viewport |

The panel is hidden by default. It listens to the Autoload's typed `status_message_requested` signal.

Possible messages include:

```text
Game saved
Game loaded
No save file found
Save file could not be read
Save version is not supported
Player could not be found
```

No `_process()` loop is used.

---

## 13. Error Handling

The system fails safely when:

- The save file does not exist.
- The file cannot be opened.
- The file is empty.
- JSON parsing fails.
- The root value is not a dictionary.
- The save version is missing or unsupported.
- The player cannot be found through the existing `players` group.
- Required player components are missing.
- A nested section is missing or has the wrong type.
- Numeric values use the wrong type.
- A saved quest ID no longer exists.

Missing optional sections leave the current in-memory values unchanged and print warnings. The system never creates duplicate progression or quest state inside the manager.

---

## 14. Test 1 — Position, Health, and XP

1. Start a fresh run.
2. Confirm the player begins at Level 1 with `0 / 100` XP.
3. Defeat one boar.
4. Confirm `40 / 100` XP.
5. Let the boar damage the player.
6. Move to an obvious different position.
7. Press K.
8. Confirm `Game saved` appears.
9. Note the position, health, level, and XP.
10. Stop and restart the game.
11. Press L.
12. Confirm `Game loaded` appears.
13. Confirm the player returns to the saved global position.
14. Confirm current and maximum health are restored.
15. Confirm Level 1 and `40 / 100` XP are restored.

---

## 15. Test 2 — Active Quest Progress

1. Talk to the Road Warden twice to accept Boar Hunt.
2. Defeat two valid boars.
3. Confirm the tracker shows `2 / 3`.
4. Press K.
5. Restart the game.
6. Press L.
7. Confirm the tracker reappears immediately.
8. Confirm it still shows `Defeat wild boars: 2 / 3`.
9. Defeat one more boar.
10. Confirm the quest changes to `Return to the quest giver`.

---

## 16. Test 3 — Completed Quest Protection

1. Accept Boar Hunt.
2. Defeat three valid boars.
3. Return to the Road Warden.
4. Turn in the quest and receive exactly 100 XP.
5. Press K.
6. Restart and press L.
7. Talk to the Road Warden again.
8. Confirm the thank-you dialogue appears.
9. Confirm no additional 100 XP is awarded.
10. Repeat the conversation several times and confirm XP never changes.

---

## 17. Test 4 — Missing Save

1. Close the game.
2. Rename or remove `savegame.json` from the project's user-data folder.
3. Start the game.
4. Press L.
5. Confirm `No save file found` appears.
6. Confirm the game continues normally.
7. Confirm there is no crash or parser error.

---

## 18. Corrupt-File Tests

Use copies of the save file when testing corruption.

### Empty file

1. Replace the file contents with nothing.
2. Press L.
3. Confirm `Save file could not be read`.

### Broken JSON

1. Replace the file with `{ broken`.
2. Press L.
3. Confirm `Save file could not be read`.
4. Confirm the Output panel includes the JSON line and error message.

### Unsupported version

1. Change `save_version` to `999`.
2. Press L.
3. Confirm `Save version is not supported`.

### Unknown quest

1. Add an extra quest key named `removed_test_quest`.
2. Press L.
3. Confirm Boar Hunt still loads.
4. Confirm the unknown ID produces only a warning.

---

## 19. Full Regression Checklist

After save/load testing, confirm all existing systems still work:

- WASD movement.
- Mouse-controlled camera.
- Jumping and gravity.
- Shift sprinting.
- Escape mouse capture.
- Sign interaction.
- Existing test NPC interaction.
- One-use chest interaction.
- Quest NPC offer, acceptance, progress, turn-in, and completed dialogue.
- Player health and health UI.
- Sword attacks.
- Training-dummy damage and reset.
- Boar detection, chasing, attack, hit reaction, death, return, and respawn.
- 40 XP boar reward.
- Level and progression UI.
- Boar Hunt progress and 100 XP completion reward.
- No duplicate boar XP.
- No duplicate quest reward.
- No critical debugger errors.

---

## 20. File-Safety Check

Before accepting Milestone 7:

- Confirm no existing file or folder moved.
- Confirm no existing file or folder was renamed.
- Confirm no duplicate project hierarchy was created.
- Confirm no existing `.uid` file changed or disappeared.
- Allow Godot to create UIDs for only the new scripts.
- Commit the milestone as one focused Git change after local testing.
