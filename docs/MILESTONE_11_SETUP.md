# Milestone 11 — Floor 1 Outskirts Greybox

**Engine:** Godot 4.7  
**Language:** Typed GDScript  
**Playable scene:** `res://AincradProject/world/floors/floor_001/floor_001_outskirts.tscn`  
**Debug scene retained:** `res://AincradProject/scenes/world/test_world.tscn`

---

## 1. What This Milestone Adds

Milestone 11 creates the first proper Floor 1 outdoor route using only Godot
primitive meshes, simple materials, and existing reusable scenes.

The route contains:

1. Starting City gate and safe plaza.
2. Beginner grasslands.
3. A clear main road.
4. An east forest branch.
5. A west ruins branch.
6. A sealed southern labyrinth landmark.
7. Visible world boundaries and a below-map recovery volume.

No final buildings, imported terrain, new enemies, minibosses, dungeon
interiors, streaming, multiplayer, or external art are included.

---

## 2. Files Added

```text
res://AincradProject/world/floors/floor_001/floor_001_outskirts.tscn
res://AincradProject/scripts/world/floor_001_outskirts.gd
res://AincradProject/docs/MILESTONE_11_SETUP.md
```

The allowed folder `scripts/world/` was created for the floor-level safety
coordinator.

---

## 3. Files Modified

```text
res://AincradProject/scenes/main.tscn
res://AincradProject/docs/CURRENT_TASKS.md
res://AincradProject/docs/DECISION_LOG.md
res://project.godot
```

`test_world.tscn`, the player scene, existing NPCs, enemies, items, components,
UI scenes, and SaveManager were not modified.

---

## 4. Startup Flow

The project now starts through:

```text
project.godot
    ↓
res://AincradProject/scenes/main.tscn
    ↓
res://AincradProject/world/floors/floor_001/floor_001_outskirts.tscn
```

The test world is still available at its existing path. Open it manually and
press F6 whenever a compact debugging environment is preferred.

---

## 5. Floor Scene Hierarchy

```text
Floor001Outskirts
├── Environment
│   ├── WorldEnvironment
│   └── DirectionalLight3D
├── Terrain
│   ├── Ground
│   ├── SurroundingWater
│   └── HeightVariation
├── CityGateArea
│   ├── SafePlaza
│   └── CityWall
├── MainRoad
├── Grasslands
│   └── Rocks
├── Forest
│   ├── ForestFloorTint
│   └── Trees
├── Ruins
├── LabyrinthEntrance
├── WorldBoundaries
│   └── FallSafetyVolume
├── SafeZone
│   └── CityGateCheckpoint
├── NPCs
│   ├── QuestNpc
│   └── ShopNpc
├── Enemies
│   ├── GrasslandsBoar01
│   ├── GrasslandsBoar02
│   └── GrasslandsBoar03
├── Interactables
│   ├── MainRoadSign
│   ├── JunctionSign
│   ├── LabyrinthClosedSign
│   └── BeginnerChest
├── SpawnMarkers
├── DebugLabels
└── Player
```

Related content is grouped beneath zone parents rather than being placed
directly under the scene root.

---

## 6. Coordinate and Scale Rules

- One Godot unit represents one metre.
- The ground is approximately `350 × 350` metres.
- The playable coordinate range is approximately:

```text
X: -168 to 168
Y: -5 to 60
Z: -168 to 168
```

- North is the Starting City wall at positive Z.
- South is the sealed labyrinth entrance at negative Z.
- East contains the forest.
- West contains the ancient ruins.

---

## 7. Region Layout

### Starting City gate

Approximate location:

```text
Z: 140 to 170
```

Contains:

- Closed stone city wall.
- Two gate towers.
- Closed metal gate.
- Stone safe plaza.
- Player spawn.
- City-gate checkpoint.
- Road Warden.
- Shopkeeper.
- Bronze Sword chest.
- Road sign.

The wall is intentionally closed because the full Starting City is not part of
this outdoor milestone.

### Beginner grasslands

The central route contains open green terrain, broad half-buried sphere hills,
primitive rocks, three separated boars, and room for later beginner content.

The boars are positioned far enough apart that their nine-metre detection
ranges should not overlap during normal travel.

### Main road

The main road runs from the gate toward the southern labyrinth landmark.

Branches:

- East toward the forest.
- West toward the ruins.

Primitive posts, signs, and zone labels make the route readable during testing.

### Small forest

The forest occupies the eastern side of the map. Trees are grouped into four
clusters and use shared trunk and canopy meshes. Trees are decorative and do
not have collision, keeping the prototype path easy to navigate and reducing
physics cost.

### Ancient ruins

The western ruins contain:

- Raised platform.
- Broken perimeter walls.
- Primitive columns of different heights.
- Stable marker for a future miniboss.

No miniboss is created in this milestone.

### Labyrinth entrance

The southern landmark contains:

- Large tower mass.
- Two doorway pillars.
- Stone lintel.
- Closed metal doorway.
- Sign stating that the route is unavailable during the prototype.

The doorway cannot be entered.

---

## 8. Player and UI Reuse

The floor instances exactly one copy of:

```text
res://AincradProject/scenes/player/player.tscn
```

That scene already owns:

- Movement and camera.
- Health and health HUD.
- Combat and weapon equipment.
- Interaction targeting and prompt UI.
- Experience and progression HUD.
- Quest log and tracker.
- Inventory and inventory UI.
- Wallet and gold HUD.
- Shop UI.
- Save-status UI.
- Death, fade, checkpoint, and respawn behavior.

No player component or HUD script is duplicated in the Floor 1 scene.

Player start position:

```text
(0, 0.05, 145)
```

This matches the `PlayerSpawn` marker.

---

## 9. Checkpoint Setup

The floor uses the existing checkpoint scene:

```text
res://AincradProject/scenes/interactions/checkpoint_crystal.tscn
```

Instance settings:

```text
Node: SafeZone/CityGateCheckpoint
Position: (7, 0, 146)
Checkpoint ID: floor_001_starting_city_gate
```

The checkpoint's existing child `RespawnPoint` is two metres in front of the
crystal, keeping the respawn position clear.

It continues to:

- Use E interaction.
- Fully heal on first activation.
- Change from blue to green.
- Become the active respawn transform.
- Save and load through `PlayerRespawn` and SaveManager.
- Prevent repeated activation effects.

---

## 10. NPC and Interactable Placement

### Road Warden

```text
Position: (-8, 0, 140)
```

Uses the existing Boar Hunt quest scene and data.

### Shopkeeper

```text
Position: (9, 0, 140)
```

Uses the existing Iron Sword purchase flow.

### Beginner chest

```text
Position: (-13, 0, 126)
```

Uses the existing one-use Bronze Sword reward behavior.

### Signs

Three existing sign instances are used:

1. Gate-road orientation sign.
2. Forest/ruins/labyrinth junction sign.
3. Sealed-labyrinth prototype notice.

No new sign script or interaction path was created.

---

## 11. Boar Placement

Existing scene:

```text
res://AincradProject/scenes/enemies/boar_enemy.tscn
```

Instances:

| Node | Position | Loot seed |
|---|---:|---:|
| `GrasslandsBoar01` | `(-42, 0.05, 55)` | `1301` |
| `GrasslandsBoar02` | `(48, 0.05, 10)` | `1302` |
| `GrasslandsBoar03` | `(-38, 0.05, -55)` | `1303` |

Each boar records its own scene-instance global transform during `_ready()` and
returns to that position after disengaging or respawning.

Every existing reward remains active:

- 40 XP.
- 12 gold.
- 50% Boar Tusk roll.
- Boar Hunt progress when active.

The training dummy remains only in `test_world.tscn`.

---

## 12. Stable Markers

The following `Marker3D` nodes exist under `SpawnMarkers`:

```text
PlayerSpawn
CityGateCheckpoint
GrasslandsEnemySpawn01
GrasslandsEnemySpawn02
GrasslandsEnemySpawn03
FutureForestEnemySpawn
FutureRuinsMinibossSpawn
FutureLabyrinthEntrance
```

These do not spawn content automatically yet. They establish stable locations
for later procedural spawning, floor transitions, and streaming work.

---

## 13. Lighting and Environment

The floor uses:

- Procedural daytime sky.
- Bright warm `DirectionalLight3D` with shadows.
- Sky-based ambient light.
- Very light fog for distance separation.
- Simple shared materials.

The lighting is intentionally brighter and more adventurous than the compact
test world while remaining placeholder art.

---

## 14. World Boundaries

Visible boundaries include:

- Starting City wall to the north.
- High cliff walls to the east, west, and south.
- Water visible below and beyond the terrain edge.
- Closed labyrinth doorway.

The boundary geometry uses simplified collision. Tiny decorative rocks and tree
canopies do not use collision.

---

## 15. Fall-Safety Volume

The floor root uses:

```text
res://AincradProject/scripts/world/floor_001_outskirts.gd
```

A large `Area3D` is positioned below the map:

```text
Node: WorldBoundaries/FallSafetyVolume
Position: (0, -20, 0)
Size: approximately 380 × 20 × 380 metres
Collision mask: World/player layer
```

When the player enters it:

1. Resolve the active checkpoint through the existing `PlayerRespawn` component.
2. Use that checkpoint only when its transform lies inside Floor 1 bounds.
3. Otherwise use `PlayerSpawn`.
4. Move the existing player instance.
5. Clear velocity.
6. Restore health to maximum.

No inventory, XP, quest, equipment, gold, or checkpoint value is removed.

---

## 16. Save-Position Fallback

SaveManager remains unchanged at save version 4.

After a successful load, the floor script validates:

- Player X, Y, and Z position.
- Active checkpoint transform when one exists.

If the loaded player position is outside Floor 1 or below its terrain, the
player is placed at `PlayerSpawn`.

If a saved checkpoint transform is outside Floor 1, it is migrated to:

```text
floor_001_starting_city_gate
```

Older saves without checkpoint data still use the player scene's original
spawn fallback through the existing `PlayerRespawn` behavior.

All existing save data remains intact:

- Health.
- Level and XP.
- Quest state and reward ownership.
- Inventory and equipped weapon.
- Gold.
- Valid checkpoint data.

---

## 17. Opening the Test World

The debug scene remains at:

```text
res://AincradProject/scenes/world/test_world.tscn
```

To run it:

1. Open it in Godot.
2. Press F6.
3. Complete the compact regression tests.

F5 starts Floor 1 through `scenes/main.tscn`.

---

## 18. Complete Testing Checklist

### Startup and HUD

- [ ] Press F5.
- [ ] Confirm `Main` loads `Floor001Outskirts`.
- [ ] Confirm the player starts near the closed city gate.
- [ ] Confirm health, progression, quest, gold, interaction, inventory,
      save-status, shop, and death UI systems are present.
- [ ] Confirm only one player exists.

### Safe gate area

- [ ] Activate `floor_001_starting_city_gate`.
- [ ] Confirm the checkpoint heals the player.
- [ ] Confirm the crystal changes to its active visual.
- [ ] Confirm repeated E interaction does not replay activation.
- [ ] Read the nearby road sign.
- [ ] Open the chest and confirm the existing Bronze Sword behavior.

### Quest and shop

- [ ] Talk to the Road Warden and accept Boar Hunt.
- [ ] Confirm the quest tracker appears.
- [ ] Talk to the Shopkeeper and confirm the shop UI opens.
- [ ] Confirm movement, combat, interaction, and inventory opening are blocked
      while the shop is open.
- [ ] Close the shop and confirm controls return.

### Region readability

- [ ] Follow the stone road south from the city gate.
- [ ] Confirm the grasslands feel open and beginner-friendly.
- [ ] Confirm the junction sign clearly identifies forest, ruins, and labyrinth.
- [ ] Follow the east branch through the primitive forest.
- [ ] Confirm trees do not block the intended path.
- [ ] Follow the west branch to the ancient ruins.
- [ ] Confirm the raised future-miniboss platform is reachable.
- [ ] Continue south and confirm the labyrinth entrance is visible.
- [ ] Confirm the sealed door is not enterable.
- [ ] Read the unavailable-prototype sign.

### Boar encounters and rewards

- [ ] Approach each boar separately from the road.
- [ ] Confirm entering one encounter does not immediately aggro all three.
- [ ] Confirm each boar chases, attacks, returns, dies, and respawns normally.
- [ ] Confirm one valid death gives exactly 40 XP and 12 gold.
- [ ] Confirm active Boar Hunt progress increases once per defeated boar life.
- [ ] Confirm Boar Tusks can drop and collect into the existing inventory.
- [ ] Confirm the shop and weapon damage values still work after earning gold.

### Death and checkpoint

- [ ] Let a boar defeat the player after activating the gate checkpoint.
- [ ] Confirm gameplay controls stop and the death UI appears.
- [ ] Confirm the player respawns at the gate checkpoint.
- [ ] Confirm health returns to maximum.
- [ ] Confirm XP, quest progress, inventory, equipped weapon, and gold remain unchanged.
- [ ] Confirm the boar returns to its own spawn during the death sequence.
- [ ] Confirm two seconds of respawn protection still work.

### Save and load

- [ ] Save at a valid Floor 1 position.
- [ ] Restart and load.
- [ ] Confirm position, health, level, XP, quests, inventory, equipment, gold,
      and checkpoint data return.
- [ ] Confirm a completed Boar Hunt still cannot reward twice.
- [ ] Test a version-1, version-2, version-3, or version-4 older save.
- [ ] Confirm no missing optional section causes a crash.
- [ ] Temporarily edit a test save position below `Y = -5` or outside `±168`.
- [ ] Load and confirm the player appears at `PlayerSpawn`.
- [ ] Temporarily use an invalid checkpoint transform and confirm migration to
      `floor_001_starting_city_gate`.

### Boundaries and recovery

- [ ] Walk into the city wall, cliffs, and sealed labyrinth door.
- [ ] Confirm the visible geometry prevents normal escape.
- [ ] Deliberately fall below the map.
- [ ] Confirm the player returns to the active valid checkpoint or PlayerSpawn.
- [ ] Confirm health is restored and velocity is cleared.

### Test-world regression

- [ ] Open `scenes/world/test_world.tscn` manually.
- [ ] Press F6.
- [ ] Confirm the old compact test world still exists unchanged.
- [ ] Re-test movement, interaction, combat, dummy, boar, quest, shop,
      inventory, saving, checkpoint, death, and respawn.

### Error check

- [ ] Confirm no parser errors appear.
- [ ] Confirm no missing-resource or missing-node errors appear.
- [ ] Confirm Godot generates the new script `.uid` automatically.
- [ ] Confirm no existing `.uid` file is edited or deleted.

---

## 19. Current Limitations

- The floor is one scene and does not stream chunks yet.
- Boars use direct movement and do not navigate around dense obstacles.
- Trees are decorative and have no collision.
- Height variation is made from simple broad sphere caps.
- The labyrinth and Starting City are sealed greybox landmarks.
- Zone labels are development aids and may be removed during polish.
- Local Godot 4.7 runtime testing is still required.
