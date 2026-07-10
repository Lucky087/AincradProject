# Milestone 6 Setup — First Quest

**Project:** Aincrad-Inspired RPG  
**Engine:** Godot 4.7  
**Language:** Typed GDScript  
**Last updated:** 2026-07-10

---

## 1. Milestone Result

Milestone 6 adds one reusable resource-driven quest system and one complete
quest named **Boar Hunt**.

The complete flow is:

```text
Talk to Road Warden
  → Read the offer
  → Press E again to accept
  → Defeat three respawning wild boars
  → Return to Road Warden
  → Turn in the quest
  → Receive 100 XP
  → Quest remains completed and cannot reward twice
```

All earlier systems remain in place:

- Third-person movement and camera.
- Jumping, gravity, and sprinting.
- Sign, existing test NPC, and chest interactions.
- Health and health UI.
- Sword combat and training dummy.
- Boar AI, damage, death, return, and respawn.
- The boar's normal 40 XP reward.
- Player experience, levelling, and progression UI.

---

## 2. New Files

```text
res://AincradProject/scripts/quests/quest_definition.gd
res://AincradProject/scripts/components/player_quest_log.gd
res://AincradProject/scripts/interactions/quest_npc.gd
res://AincradProject/scripts/ui/quest_ui.gd

res://AincradProject/data/quests/boar_hunt.tres

res://AincradProject/scenes/interactions/quest_npc.tscn
res://AincradProject/scenes/ui/quest_ui.tscn

res://AincradProject/docs/MILESTONE_6_SETUP.md
```

Godot should generate new script `.uid` files normally after opening the
project. Do not create, edit, or delete those files manually.

---

## 3. Modified Files

```text
res://AincradProject/scenes/player/player.tscn
res://AincradProject/scenes/world/test_world.tscn
res://AincradProject/scripts/enemies/boar_enemy.gd
res://AincradProject/scenes/enemies/boar_enemy.tscn
res://AincradProject/docs/CURRENT_TASKS.md
res://AincradProject/docs/DECISION_LOG.md
```

The following important files remain unchanged:

```text
res://AincradProject/scripts/player/player_controller.gd
res://AincradProject/scripts/player/player_combat.gd
res://AincradProject/scripts/components/health_component.gd
res://AincradProject/scripts/components/player_progression.gd
res://AincradProject/scripts/interactions/interactable.gd
res://AincradProject/scripts/interactions/player_interactor.gd
res://AincradProject/scripts/enemies/training_dummy.gd
res://AincradProject/scenes/enemies/training_dummy.tscn
res://AincradProject/scenes/interactions/test_npc.tscn
res://AincradProject/scenes/interactions/test_sign.tscn
res://AincradProject/scenes/interactions/test_chest.tscn
res://AincradProject/scenes/ui/health_ui.tscn
res://AincradProject/scenes/ui/progression_ui.tscn
res://AincradProject/scenes/ui/interaction_ui.tscn
```

---

## 4. Quest Definition

`QuestDefinition` is a reusable `Resource` containing design data rather than
one player's live state.

The Boar Hunt data asset is stored at:

```text
res://AincradProject/data/quests/boar_hunt.tres
```

### Boar Hunt values

```text
Quest ID: boar_hunt
Title: Boar Hunt
Description: The boars outside the city have become aggressive. Defeat three
             wild boars and return to me.
Objective ID: wild_boar
Objective Label: Defeat wild boars
Objective Target: 3
Experience Reward: 100
```

The quest ID and objective ID are stable internal identifiers. Visible text may
change later without changing those IDs.

---

## 5. Quest States

`PlayerQuestLog` supports four states:

### Not Started

The player has not accepted the quest. Boar deaths do not count and the quest
tracker stays hidden.

### Active

The quest has been accepted. Valid `wild_boar` defeats increase progress from
0 to 3.

### Ready to Turn In

The objective has reached 3 / 3. Further boar defeats do not add more progress.
The reward is not granted automatically. The tracker displays:

```text
Boar Hunt
Return to the quest giver
```

### Completed

The player returned to the Road Warden and received the reward. The quest can
no longer be accepted, progressed, turned in, or rewarded again.

---

## 6. Player Scene Additions

The existing player gains a quest-log component and a separate quest UI:

```text
Player
├── HealthComponent
├── PlayerProgression
├── PlayerQuestLog
├── existing movement, camera, interaction, and combat nodes
├── HealthUI
├── ProgressionUI
├── QuestUI
└── InteractionUI
```

### `PlayerQuestLog` Inspector value

```text
Initial Quest Definition:
res://AincradProject/data/quests/boar_hunt.tres
```

### `QuestUI` Inspector values

```text
Quest Log Path: ../PlayerQuestLog
Tracked Quest ID: boar_hunt
Completion Message Seconds: 2.5
```

---

## 7. PlayerQuestLog Public Interface

Important methods include:

```gdscript
register_quest(definition: QuestDefinition) -> bool
has_quest(quest_id: StringName) -> bool
get_quest_definition(quest_id: StringName) -> QuestDefinition
get_quest_state(quest_id: StringName) -> int
get_objective_progress(quest_id: StringName) -> int
get_objective_target(quest_id: StringName) -> int
accept_quest(quest_id: StringName) -> bool
record_objective_progress(objective_id: StringName, amount: int = 1) -> int
turn_in_quest(
    quest_id: StringName,
    progression: PlayerProgression
) -> bool
```

Signals:

```gdscript
quest_state_changed(quest_id, previous_state, current_state)
quest_progress_changed(quest_id, current_progress, target_progress)
quest_reward_granted(quest_id, requested_experience, applied_experience)
```

The UI listens to state and progress signals. It does not poll in `_process()`.

---

## 8. How Boar Defeats Are Recorded

The existing sword already supplies the player root as the source of damage.
When the killing hit reaches zero health, the existing `HealthComponent` emits:

```text
died(source)
```

The boar now performs two independent actions:

1. It grants its existing 40 XP reward.
2. It reports one objective event with the stable ID `wild_boar`.

To find the responsible quest log, the boar:

1. Starts from the killing damage source.
2. Walks upward until it finds the node in the existing `players` group.
3. Finds that player's direct `PlayerQuestLog` child.
4. Calls:

```gdscript
record_objective_progress(&"wild_boar", 1)
```

No absolute test-world player path is used.

The quest log only applies the event while Boar Hunt is in the `ACTIVE` state.
Therefore:

- Defeats before accepting do not count.
- Defeats after reaching 3 / 3 do not count.
- The training dummy does not count because it never reports `wild_boar`.
- Only the player responsible for the killing hit receives progress.

---

## 9. Duplicate Protection

### One objective event per boar life

The boar uses:

```text
_quest_progress_reported
```

The flag becomes true during the death callback and resets only during the
existing respawn callback. Combined with the existing `_is_dead` guard, one
spawned boar life cannot report several defeats.

### One quest reward

The quest log stores one reward-granted flag for each quest ID.

During turn-in it:

1. Confirms the quest is `READY_TO_TURN_IN`.
2. Confirms the reward flag is false.
3. Sets the reward flag before calling the progression component.
4. Adds the configured 100 XP.
5. Changes the state to `COMPLETED`.

Talking to the Road Warden again only shows the completed dialogue and gives no
additional XP.

---

## 10. Quest NPC Interaction

The new NPC inherits the existing `Interactable` base class and uses the same
camera ray, E input, prompt, maximum distance, and interaction-message UI.

### Quest NPC hierarchy

```text
QuestNpc (StaticBody3D)
├── BodyMesh
├── HeadMesh
├── FacingMarker
├── QuestMarkerStem
├── QuestMarkerDot
├── NameLabel
└── CollisionShape3D
```

All visible objects are Godot primitive meshes.

### Important Inspector values

```text
Collision Layer: World + Interactable (layers 1 and 2)
Collision Mask: World (layer 1)
Quest ID: boar_hunt
Player Group: players
Speaker Name: Road Warden
Interaction Prompt: Press E to hear quest
```

### Dialogue behavior

First interaction while not started:

```text
Road Warden: The boars outside the city are becoming dangerous. Can you defeat
three of them?

Boar Hunt
The boars outside the city have become aggressive. Defeat three wild boars and
return to me.
Objective: Defeat wild boars: 0 / 3
Reward: 100 XP
Press E again to accept.
```

Second interaction:

```text
Road Warden: Quest accepted. Defeat three wild boars and return to me.
```

While active:

```text
Road Warden: You have defeated X of 3 boars.
```

Ready to turn in:

```text
Road Warden: You did it. The road is safer now.
Quest complete. Reward: 100 XP.
```

Completed:

```text
Road Warden: Thank you again for your help.
```

---

## 11. Quest UI Hierarchy and Placement

```text
QuestUI (CanvasLayer)
├── QuestPanel (PanelContainer)
│   └── MarginContainer
│       └── VBoxContainer
│           ├── TitleLabel
│           └── ObjectiveLabel
└── CompletionTimer
```

The panel is below the existing progression panel:

```text
Left: 24
Top: 260
Right: 394
Bottom: 350
```

Behavior:

- Hidden while Boar Hunt is not started.
- Visible immediately after acceptance.
- Updates after every valid defeat.
- Displays `Return to the quest giver` at 3 / 3.
- Displays `Quest complete!` for 2.5 seconds after turn-in.
- Hides after the completion message.

---

## 12. Test-World Placement

The existing `TestInteractables` node now also contains:

```text
TestWorld
└── TestInteractables
    └── QuestNpc
```

Transform:

```text
Position: (-3.5, 0, 14)
Rotation Y: -90 degrees
```

This places the Road Warden near the player's existing starting position while
preserving the sign, test NPC, chest, training dummy, boar, and greybox objects.

---

## 13. Complete Testing Checklist

### Project loading

- [ ] Open the folder containing `project.godot` in Godot 4.7.
- [ ] Allow Godot to generate new script `.uid` files normally.
- [ ] Confirm no parser errors appear.
- [ ] Confirm no missing-resource or missing-node errors appear.

### Existing systems

- [ ] WASD movement works.
- [ ] Mouse camera control works.
- [ ] Jumping, gravity, and sprinting work.
- [ ] Escape releases and captures the mouse.
- [ ] The sign, existing test NPC, and chest still work.
- [ ] The health UI still updates after boar attacks.
- [ ] The progression UI still updates after XP gains.
- [ ] The training dummy still takes damage and resets.
- [ ] The boar still detects, chases, attacks, returns, dies, and respawns.
- [ ] Every valid boar death still grants its normal 40 XP.

### Defeats before acceptance

- [ ] Defeat the boar before accepting Boar Hunt.
- [ ] Confirm the player still receives 40 XP.
- [ ] Confirm no quest tracker appears.
- [ ] Confirm the later accepted quest begins at 0 / 3.

### Offer and acceptance

- [ ] Find the gold Road Warden near the player start.
- [ ] Aim at the NPC and confirm `Press E to hear quest` appears.
- [ ] Press E once and confirm the offer, description, objective, and reward appear.
- [ ] Confirm the prompt changes to `Press E to accept Boar Hunt`.
- [ ] Press E again.
- [ ] Confirm the acceptance message appears.
- [ ] Confirm the quest tracker appears with:

```text
Boar Hunt
Defeat wild boars: 0 / 3
```

### Objective progress

- [ ] Defeat the boar once after acceptance.
- [ ] Confirm its normal 40 XP is awarded.
- [ ] Confirm the tracker changes to 1 / 3.
- [ ] Wait for respawn and defeat it again.
- [ ] Confirm the tracker changes to 2 / 3.
- [ ] Wait for respawn and defeat it a third time.
- [ ] Confirm the tracker changes to `Return to the quest giver`.
- [ ] Confirm the quest reward has not yet been granted.
- [ ] Confirm further kills before turn-in do not increase progress beyond 3.

### Expected fresh-save XP sequence

When starting at Level 1 with 0 / 100 XP and accepting the quest before the
first boar defeat:

```text
First boar:  Level 1 — 40 / 100 XP; quest 1 / 3
Second boar: Level 1 — 80 / 100 XP; quest 2 / 3
Third boar:  Level 2 — 20 / 200 XP; ready to turn in
Quest reward: Level 2 — 120 / 200 XP
```

### Turn-in and reward

- [ ] Return to the Road Warden.
- [ ] Confirm the prompt reads `Press E to turn in Boar Hunt`.
- [ ] Press E.
- [ ] Confirm the completion dialogue appears.
- [ ] Confirm exactly 100 quest XP is added in addition to boar XP already earned.
- [ ] Confirm `Quest complete!` appears briefly in the tracker.
- [ ] Confirm the tracker hides after approximately 2.5 seconds.
- [ ] Talk to the Road Warden again.
- [ ] Confirm the thank-you dialogue appears.
- [ ] Confirm no additional 100 XP reward is granted.

### Duplicate and ownership checks

- [ ] Confirm one boar death changes progress by only one.
- [ ] Confirm the defeated boar cannot report another kill before respawn.
- [ ] Confirm a respawned boar may report another valid kill.
- [ ] Confirm the training dummy never changes quest progress.
- [ ] Confirm no quest progress is granted from a non-player killing source.

Milestone 6 is complete after all checks pass in the local Godot 4.7 editor.
