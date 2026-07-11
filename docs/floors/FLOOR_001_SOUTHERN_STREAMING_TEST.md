# Floor 1 Southern Terrain Streaming Test

**Milestone:** 14B — Southern Terrain Godot Import and 7 × 7 Streaming Validation  
**Engine target:** Godot 4.7  
**Date:** 2026-07-11  
**Status:** Implementation and static validation complete; local F6 runtime approval required

---

## 1. Purpose

This milestone adds a separate technical scene for loading, streaming, and
walking across the real 49-chunk southern Floor 1 terrain dataset generated in
Milestone 14A.

It does not replace normal gameplay and does not modify:

```text
AincradProject/scenes/main.tscn
AincradProject/scenes/world/test_world.tscn
AincradProject/world/floors/floor_001/floor_001_outskirts.tscn
AincradProject/scenes/world/terrain_chunk_test.tscn
AincradProject/scenes/world/terrain_streaming_test.tscn
AincradProject/scenes/player/player.tscn
project.godot
```

The new scene is:

```text
res://AincradProject/scenes/world/floor_001_southern_streaming_test.tscn
```

Run it directly with **F6**.

---

## 2. Manifest Loaded

The test uses:

```text
res://AincradProject/assets/environments/floor_001/terrain/southern_region/floor_001_southern_manifest.json
```

The scene configures `FloorChunkStreamer` to require:

- `floor_id = floor_001`
- `dataset_id = floor_001_southern_region_v1`
- `chunk_size_m = 256`
- X range `-3…+3`
- Z range `+11…+17`
- Exactly 49 valid chunk records
- Exactly 49 unique LOD0 paths
- Exactly 49 unique LOD1 paths
- Exactly 49 unique collision paths
- `generation_status = complete_blender_exports_generated`
- Blender execution and export flags set to true
- `actual_glb_count = 147`
- Seam validation passed
- Every referenced GLB present and imported as a `PackedScene`

Milestone 14B extends the reusable streamer so it understands both manifest
formats already in the project:

1. The original nine-chunk manifest with flat `lod0_path` and `lod1_path`
   fields.
2. The southern manifest with nested `lod_paths.lod0` and `lod_paths.lod1`
   fields.

The streamer normalises the southern entries internally. It does not modify the
manifest file.

If the southern manifest still reports pending Blender exports, has a wrong
count, references missing files, or fails any strict expectation, the streamer
stops before registering the dataset. The debug panel shows the failure and the
player remains suspended safely rather than falling or pretending loading
succeeded.

---

## 3. Registering All 49 Chunks

Every validated manifest record is registered twice:

```text
Vector2i grid coordinate -> normalised chunk record
stable chunk ID          -> Vector2i grid coordinate
```

The complete registry is:

```text
X = -3, -2, -1, 0, +1, +2, +3
Z = +11, +12, +13, +14, +15, +16, +17
Total = 49 chunks
```

Each runtime chunk gets one stable root named with its manifest chunk ID:

```text
LoadedChunks/
└── floor_001_chunk_x+00_z+14/
    ├── Visual/
    └── Collision/
```

The dictionary-backed root registry prevents duplicate roots for the same grid
coordinate.

---

## 4. Player Coordinate and Current Chunk

The player grid is calculated with floor-based coordinates:

```gdscript
grid_x = floor(player_world_x / 256.0)
grid_z = floor(player_world_z / 256.0)
```

Using `floor()` is important for negative X values. For example:

```text
X = -1 metre   -> grid X = -1
X = -256 metres -> grid X = -1
X = -257 metres -> grid X = -2
```

East remains positive X, west remains negative X, north remains negative Z,
and south remains positive Z.

The debug panel shows the player position, current grid, stable chunk ID, and
whether the coordinate exists in the southern manifest.

---

## 5. LOD Selection

The test uses Chebyshev distance so each radius forms a square chunk
neighbourhood around the player.

Default settings:

```text
LOD0 radius:        1 chunk
LOD1 visual radius: 2 chunks
Collision radius:   1 chunk
Unload radius:      3 chunks
Update interval:    0.20 seconds
```

When the player is away from a dataset edge, the target state is:

```text
LOD0:      3 × 3 = 9 nearby chunks
LOD1:      outer ring of the 5 × 5 visual area = 16 chunks
Visual:    25 chunks total
Collision: 3 × 3 = 9 chunks
```

A chunk has only one active visual LOD. When a replacement LOD finishes
loading, the old visual is removed before the new visual becomes the active
node. The chunk root position never changes during a LOD transition.

Dataset edges naturally produce fewer targets because only manifest chunks may
load.

---

## 6. Collision Selection

Collision is independent from visual LOD.

The streamer loads only each chunk's dedicated exported collision GLB. It does
not use hidden LOD0 or LOD1 meshes as collision substitutes.

For an active collision target, the streamer:

1. Instantiates the collision GLB temporarily.
2. Collects its `MeshInstance3D` meshes.
3. Creates trimesh `CollisionShape3D` resources.
4. Places them under one `StaticBody3D` in the chunk's `Collision` container.
5. Removes the temporary visible collision source.

This allows a chunk to use LOD1 visually while retaining collision when the
collision radius requires it.

Collision is removed when the coordinate leaves the collision radius, even if
the chunk still has LOD1 visuals.

---

## 7. Loading, Caching, and Unloading

The streamer does not perform heavy resource loading every rendered frame.

It uses:

- A `0.20` second update timer.
- A controlled request queue.
- Up to eight new threaded requests per update in this scene.
- `ResourceLoader.load_threaded_request()`.
- A dictionary of queued paths.
- A dictionary of active threaded requests.
- A dictionary of failed paths.
- A test-scene resource cache.

A path already queued, loading, or cached is not requested again.

The southern test enables `retain_loaded_resources_in_memory`. This keeps
previously visited GLB resources cached during the isolated test route so
returning to an area does not repeatedly read the same files. Runtime nodes and
physics still unload normally. This is a validation choice, not yet a final
production memory policy.

When a chunk is outside both visual and collision radii:

- Its visual node is removed.
- Its collision body is removed.
- Its empty root may remain temporarily inside the three-chunk retention
  radius.
- Its root is removed when its distance exceeds the unload radius.

The debug panel reports pending requests, completed loads, failed loads, cached
resources, unloads, and recent update duration.

---

## 8. Safe Initial Spawn and Teleports

The player scene is reused directly:

```text
res://AincradProject/scenes/player/player.tscn
```

No player script or player scene was duplicated or modified.

For initial placement and every debug teleport, the test controller:

1. Reads the target chunk bounds from the manifest.
2. Places the player above the chunk's recorded maximum height.
3. Clears velocity.
4. Temporarily pauses only the player's physics process.
5. Forces an immediate streaming refresh.
6. Waits for the target chunk's dedicated collision to become active.
7. Raycasts downward against terrain collision layer 1.
8. Places the same player slightly above the hit point.
9. Clears velocity again.
10. Restores normal player physics, movement, sprint, jump, camera, and controls.

If collision cannot become active, the player stays suspended and the panel
shows an explicit error. The test does not drop the player through missing
terrain.

The test camera far distance is raised locally to 1100 metres. The reusable
player scene and camera controls remain unchanged.

---

## 9. Debug Teleports

These keys are handled locally. The project Input Map is unchanged.

| Key | Location | World X/Z | Grid |
|---|---|---:|---:|
| F1 | City-gate plateau | `(0, 3835)` | `(0, 14)` |
| F2 | Northern continuation edge | `(20, 2840)` | `(0, 11)` |
| F3 | Western ridge transition | `(-700, 3400)` | `(-3, 13)` |
| F4 | Eastern lowland transition | `(880, 3400)` | `(3, 13)` |
| F9 | Centre of centre chunk | `(128, 3712)` | `(0, 14)` |
| B | Toggle chunk boundaries | — | — |

Every teleport clears velocity, requests an immediate target recalculation,
waits for collision, and performs a downward placement raycast.

---

## 10. Debug UI

The periodically updated panel shows:

- Dataset ID
- Manifest validation result
- Manifest generation/export status
- Seam validation result
- Registered chunk count
- Player world position
- Current grid coordinate
- Current stable chunk ID
- Current test location
- Loaded root count
- LOD0 count
- LOD1 count
- Active collision count
- Pending load count
- Failed load count
- Completed load count
- Unload count
- Cached resource count
- Most recent streaming update duration
- Recent smoothed update duration
- Loaded stable chunk IDs
- Local debug controls
- Most recent test message or warning

The panel updates every `0.25` seconds rather than every rendered frame.

---

## 11. Chunk-Boundary Visualization

The current chunk boundary is drawn with a lightweight `ImmediateMesh` line
rectangle.

Nearby loaded roots can also be drawn in one separate line mesh. The controller
creates no node per boundary. It rebuilds the line meshes only when the current
coordinate or loaded-root set changes.

Press **B** to toggle both boundary views.

The line height uses each manifest chunk's recorded maximum height plus a small
offset. It is a diagnostic outline, not terrain geometry.

---

## 12. Fall Recovery

A large test-only `Area3D` sits below the southern dataset.

When the same player enters it:

- The player returns to the city-gate test spawn.
- Velocity is cleared.
- Target collision is refreshed and raycast again.
- Save data is not written.
- Checkpoints are not modified.
- XP, levels, health progression, inventory, gold, quests, and equipment are
  not reset.

This behaviour exists only in
`floor_001_southern_streaming_test.tscn`.

---

## 13. Running the Test with F6

1. Open the outer `aincrad/` project in Godot 4.7.
2. Allow Godot to finish importing resources.
3. In the FileSystem dock, open:

```text
AincradProject/scenes/world/floor_001_southern_streaming_test.tscn
```

4. Press **F6** to run the current scene.
5. Confirm the debug panel reports:

```text
Dataset: floor_001_southern_region_v1
Manifest validation: PASSED
Manifest status: Manifest registry ready
Export status: complete_blender_exports_generated
Seam validation: PASSED
Registered chunks: 49 / 49
```

6. Wait for pending loads to reach zero.
7. Confirm the player is placed on the city-gate terrain rather than inside or
   below it.

Do not use F5 to run this test. F5 must continue to start the unchanged normal
game.

---

## 14. Required Test Route

### Stage 1 — City-gate plateau

- Start at F1.
- Walk around the safe plateau.
- Sprint and jump.
- Confirm no pits, collision gaps, or duplicate roots appear.

### Stage 2 — Northbound corridor

Walk north from approximately Z `3835` toward Z `3000`.

This crosses at least these chunk borders:

```text
Z 3584: grid +14 -> +13
Z 3328: grid +13 -> +12
Z 3072: grid +12 -> +11
```

During the route, confirm:

- New nearby chunks become LOD0.
- The outer visible ring uses LOD1.
- Collision follows the player independently.
- Old collisions disappear outside radius 1.
- Old visuals disappear outside radius 2.
- Old roots unload beyond radius 3.
- The road corridor terrain remains readable and gently graded.

### Stage 3 — Western transition

- Press F3.
- Wait for the safe placement message.
- Inspect the broader ridges and sheltered terrain.
- Walk across at least one west-side chunk boundary.

### Stage 4 — Eastern transition

- Press F4.
- Inspect the lower, gentler terrain and eastward drainage tendency.
- Confirm no water or lake mesh exists yet.

### Stage 5 — Northern edge

- Press F2.
- Inspect the continuation edge near Z `2816`.
- Confirm the streamer never requests grid Z `10`, because it is outside the
  manifest.

### Stage 6 — Return

- Press F1.
- Confirm cached resources can reactivate without duplicate roots.
- Confirm completed-load and unload counters remain sensible.

---

## 15. Detecting Seams, Scale Errors, and Axis Errors

### Visual seam symptoms

- A visible vertical crack between neighbouring chunks.
- Different edge heights at the same border.
- Two LODs visible on the same root.
- A chunk offset by exactly 256 metres.

### Collision seam symptoms

- The player falls at a border while the visual terrain continues.
- Jumping across a border catches on an invisible step.
- Duplicate `StaticBody3D` nodes appear under one chunk root.
- Collision remains active far outside radius 1.

### Scale symptoms

- A chunk appears much larger or smaller than 256 metres.
- The player takes an unreasonable time to cross one chunk.
- Debug boundaries do not align with terrain edges.

### Axis symptoms

- Moving north increases Z instead of decreasing it.
- Western terrain appears on the east side.
- The city gate appears near the wrong Z range.
- Manifest roots align only after manually rotating a chunk.

If any of these occur, stop before production integration and record the exact
chunk IDs, player coordinates, and debug counts.

---

## 16. Regression Checks

After testing the southern scene:

1. Run `terrain_chunk_test.tscn` with F6.
2. Confirm its fixed nine chunks still load and align.
3. Run `terrain_streaming_test.tscn` with F6.
4. Confirm its original nine-chunk streaming controls still work unchanged.
5. Press F5.
6. Confirm the normal game starts normally.
7. Confirm no normal-game save, player, UI, quest, combat, or world behaviour
   changed.

The reusable streamer keeps its original manifest path and original defaults.
The southern strict settings exist only as exported values on the new scene.

---

## 17. Static Validation Completed in the Delivery Environment

The following checks passed without running Godot:

- Southern manifest JSON parsed.
- Dataset ID and floor ID matched.
- Chunk size was exactly 256 metres.
- Grid range was exactly X `-3…+3`, Z `+11…+17`.
- Exactly 49 unique chunk records registered in validation data.
- Exactly 49 unique LOD0 paths existed.
- Exactly 49 unique LOD1 paths existed.
- Exactly 49 unique collision paths existed.
- Exactly 147 GLB files existed.
- All 147 Godot `.import` records existed.
- Every GLB header and JSON chunk parsed.
- Combined primitive bounds for every GLB covered local X/Z `0…256`.
- Manifest Blender-export status was complete.
- Manifest actual GLB count was 147.
- Manifest seam validation passed.
- GDScript syntax/lint validation passed for both changed scripts.
- Every original public method in `floor_chunk_streamer.gd` remained present.
- Protected scenes, player scene, project settings, `.uid` files, and `.godot/`
  contents remained byte-for-byte unchanged.

Godot 4.7 was not available in the delivery environment, so real F6 physics,
movement, rendering, threaded import, and regression execution remain local
approval steps.

---

## 18. Current Limitations

- The scene is an isolated technical test, not normal-game integration.
- Terrain resources visited during this test are retained in the streamer's
  test cache; a final production cache budget or eviction policy is not yet
  selected.
- Collision shapes are generated at runtime from the dedicated collision GLB
  meshes.
- Boundary lines use manifest maximum height and do not follow every terrain
  contour.
- No navigation mesh exists.
- No roads, walls, gates, buildings, trees, rocks, grass, rivers, lakes,
  enemies, or NPCs are included.
- Multiplayer streaming is not included.
- Runtime approval still requires Godot 4.7 on the user's computer.

---

## 19. Recommended Next Milestone

After every local checklist item passes, proceed to:

**Milestone 14C — Southern Terrain Acceptance and Empty Floor 1 Production Shell**

That milestone should create a separate production-oriented Floor 1 shell that
reuses the approved manifest and streamer, establishes production spawn and
world ownership boundaries, and prepares a later city-gate/road blockout. It
should still avoid changing normal F5 startup until the production shell is
approved independently.
