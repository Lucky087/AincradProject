# Milestone 10 Setup — Player Death, Respawning, and Checkpoints

**Engine:** Godot 4.7  
**Milestone:** M10  
**Save format:** Version 4, with versions 1–3 still supported

## Added systems

- `PlayerRespawn` owns temporary death state, fallback spawn data, active
  checkpoint data, respawn sequencing, and post-respawn invulnerability.
- `DeathUI` displays the death message, black fades, and a temporary respawn
  protection label.
- `CheckpointCrystal` is a primitive reusable Interactable with a stable ID and
  separate respawn marker.
- The existing boar treats dead, respawning, and protected players as invalid
  attack targets and returns toward its original spawn.
- Save version 4 stores checkpoint ID, position, and rotation while older saves
  use the original player spawn.

## New player hierarchy

```text
Player
├── HealthComponent
├── PlayerProgression
├── PlayerQuestLog
├── PlayerInventory
├── PlayerWallet
├── PlayerRespawn
│   ├── DeathWaitTimer
│   └── InvulnerabilityTimer
├── existing movement / combat / interaction nodes
├── existing HUD scenes
├── InventoryUI
├── ShopUI
├── DeathUI
└── InteractionUI
```

The player is never deleted or replaced. The same `CharacterBody3D` is moved to
its active checkpoint transform.

## PlayerRespawn Inspector values

```text
Death Wait Seconds: 3.0
Fade To Black Seconds: 0.45
Fade From Black Seconds: 0.55
Respawn Invulnerability Seconds: 2.0

Health Component Path: ../HealthComponent
Player Controller Path: ..
Player Combat Path: ../PlayerCombat
Player Interactor Path: ../PlayerInteractor
Inventory UI Path: ../InventoryUI
Shop UI Path: ../ShopUI
Death UI Path: ../DeathUI
Death Wait Timer Path: DeathWaitTimer
Invulnerability Timer Path: InvulnerabilityTimer
```

## Death sequence

1. `HealthComponent.died` reaches `PlayerRespawn`.
2. Health becomes invulnerable so no later hit can change death state.
3. Inventory and shop close if open and are temporarily blocked.
4. Movement, camera mouse input, attacks, and interactions are disabled.
5. Player velocity is cleared and the death message appears.
6. `DeathWaitTimer` waits 3 seconds.
7. The screen fades to black.
8. At full black, the existing player moves to the active checkpoint or fallback
   spawn and health resets to maximum.
9. The screen fades back in.
10. Normal controls return and 2 seconds of damage immunity begin.
11. The protection label hides when immunity ends.

Persistent XP, level, quest, inventory, equipment, and gold components are not
changed during this sequence.

## PlayerRespawn signals

```text
player_died
respawn_started
player_respawned(checkpoint_id)
respawn_invulnerability_started(duration_seconds)
respawn_invulnerability_ended
checkpoint_changed(checkpoint_id, checkpoint_transform)
```

Enemies and future systems should observe these signals or use
`can_be_targeted_by_enemies()` rather than copying death state.

## Checkpoint scene

```text
CheckpointCrystal (StaticBody3D / Interactable)
├── Base
├── CrystalVisual
│   ├── InactiveCrystal
│   └── ActiveCrystal
│       └── ActiveGlow
├── CollisionShape3D
├── RespawnPoint
└── StatusLabel
```

Important values:

```text
Checkpoint ID: test_world_safe_zone
Collision Layer: World + Interactable
Collision Mask: World
Respawn Point: local position (0, 0.05, -2)
World Position: (0, 0, 17)
```

The player therefore respawns at approximately `(0, 0.05, 15)`, safely in
front of the crystal and close to the starting NPC area.

First activation:

```text
Press E to activate checkpoint
Checkpoint activated
```

Activation fully heals the player, records the marker transform, changes the
crystal from blue to glowing green, and refreshes every checkpoint in the
`checkpoints` group. An already-active checkpoint is unavailable to the
interaction ray, preventing repeated healing or duplicate activation effects.

## Fallback spawn

`PlayerRespawn` captures the player's world transform during `_ready()`. If no
checkpoint has been activated, or an older save has no checkpoint section, this
original transform is used.

## Boar behavior

The boar still resolves the player through the existing `players` group. It now
also finds the player's direct `PlayerRespawn` child.

When `player_died` is emitted, the boar:

- Cancels any active lunge.
- Stops its attack cooldown.
- Stops horizontal attack movement.
- Changes to Returning when away from spawn.

`_has_living_player()` also rejects players who are dead, currently respawning,
or inside the 2-second protection window. The boar may detect the player again
after protection ends and normal detection-range rules allow it.

No boar XP, gold, loot, quest, death, or respawn reward code was replaced.

## Save format

Version 4 adds:

```json
"respawn": {
  "active_checkpoint_id": "test_world_safe_zone",
  "checkpoint_position": {
    "x": 0.0,
    "y": 0.05,
    "z": 15.0
  },
  "checkpoint_rotation": {
    "x": 0.0,
    "y": 0.0,
    "z": 0.0
  }
}
```

SaveManager continues storing the existing player position, health,
progression, quests, inventory, equipment, and wallet sections.

Compatibility:

```text
Version 1: starter inventory fallback, zero gold, original-spawn checkpoint
Version 2: inventory restored, zero gold, original-spawn checkpoint
Version 3: inventory and wallet restored, original-spawn checkpoint
Version 4: inventory, wallet, and checkpoint restored
```

Temporary death state, fade progress, invulnerability timers, boar attack state,
and enemy targets are never serialized. Saving is rejected during player death
or the black-screen respawn phase.

## Complete local test checklist

### Checkpoint activation

- [ ] Confirm the blue checkpoint appears behind the starting player/NPC area.
- [ ] Aim at it and confirm `Press E to activate checkpoint`.
- [ ] Press E and confirm `Checkpoint activated`.
- [ ] Confirm the player is fully healed.
- [ ] Confirm the crystal changes to the glowing active visual.
- [ ] Confirm the prompt no longer appears for the active checkpoint.

### Player death and respawn

- [ ] Let the boar reduce player HP to zero.
- [ ] Confirm movement, jump, sprint, camera mouse look, attacks, and E interaction stop.
- [ ] Confirm open inventory or shop closes immediately.
- [ ] Confirm `You Died` and the respawn message appear.
- [ ] Confirm the system waits approximately 3 seconds.
- [ ] Confirm the screen fades to black.
- [ ] Confirm the same player appears at the checkpoint position.
- [ ] Confirm health returns to maximum.
- [ ] Confirm horizontal and vertical velocity are cleared.
- [ ] Confirm the screen fades back in and controls return.

### Respawn protection

- [ ] Confirm `Respawn protection` appears after the fade.
- [ ] Confirm the player can move during protection.
- [ ] Confirm the boar cannot damage or target the player for 2 seconds.
- [ ] Confirm the label disappears after approximately 2 seconds.
- [ ] Confirm the boar can detect the player again after protection ends.

### Boar reset behavior

- [ ] Begin a boar attack and allow the player to die.
- [ ] Confirm the current attack is cancelled without another damage event.
- [ ] Confirm the boar changes to Returning when away from spawn.
- [ ] Confirm it reaches its original spawn and becomes Idle.
- [ ] Confirm its XP, gold, loot, quest progress, death, and respawn behavior still works.

### Persistent values across death

Before death, note level, XP, gold, quest progress, inventory quantities, and
current equipment.

- [ ] Die and respawn.
- [ ] Confirm every noted value is unchanged.
- [ ] Confirm no item, gold, or experience penalty occurs.

### Save and load checkpoint

- [ ] Activate the checkpoint.
- [ ] Press K to save.
- [ ] Restart and press L to load.
- [ ] Walk away from the safe area and die.
- [ ] Confirm respawn still uses `test_world_safe_zone`.
- [ ] Confirm all existing saved data also restores correctly.

### Older saves

- [ ] Load a valid version-3 save without a `respawn` section.
- [ ] Confirm the game does not crash.
- [ ] Confirm the checkpoint visual is inactive.
- [ ] Die before activating a checkpoint.
- [ ] Confirm the original player spawn is used.
- [ ] Repeat with version-1 and version-2 saves if available.

### Regression

- [ ] Movement, camera, jump, sprint, gravity, and Escape work while alive.
- [ ] Sign, test NPC, quest NPC, shop NPC, chest, and checkpoint interactions work.
- [ ] Health, XP, quest, gold, inventory, shop, and save-status UI still work.
- [ ] Training dummy and all three weapon damage values remain correct.
- [ ] Boar rewards, loot pickup, quest progress, and shop purchase remain correct.
- [ ] K/L save and load still work while the player is alive.
- [ ] No parser, missing-node, missing-resource, or runtime errors appear.
