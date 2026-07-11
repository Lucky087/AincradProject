# Handoff — Milestone 14B

**Milestone:** Southern Terrain Godot Import and 7 × 7 Streaming Validation  
**Date:** 2026-07-11  
**Implementation status:** Complete  
**Static validation status:** Passed  
**Local Godot 4.7 approval status:** Required

---

## 1. Current Project State

The complete outer structure remains:

```text
aincrad/
├── project.godot
├── .godot/
├── AincradProject/
└── BlenderSource/
```

The uploaded 14B input already contained:

- The completed Milestone 14A southern manifest.
- `generation_status = complete_blender_exports_generated`.
- 49 LOD0 GLBs.
- 49 LOD1 GLBs.
- 49 collision GLBs.
- 147 matching Godot `.import` records.
- The generated southern Blender source file and generation log.

Milestone 14B adds a separate F6 scene. It does not replace the normal game or
either earlier terrain regression scene.

---

## 2. Work Completed

- Read all files under `AincradProject/docs/` before implementation.
- Inspected the complete uploaded archive and existing terrain systems.
- Verified the real 147 southern GLBs are present.
- Verified the southern manifest reports completed Blender exports and passed
  seams.
- Extended the reusable `FloorChunkStreamer` without removing any public API.
- Preserved the original nine-chunk manifest and scene defaults.
- Added support for nested southern `lod_paths` entries.
- Added optional strict manifest expectations configurable per scene.
- Added strict dataset, count, range, export-status, GLB-count, seam, and path
  validation.
- Added an explicit safe failure when Blender exports are pending or invalid.
- Added reusable debug counters and update-duration measurements.
- Added optional retained resource caching for the isolated southern route.
- Added collision-active and loaded-coordinate query methods.
- Created the separate 49-chunk southern streaming test scene.
- Reused the existing player scene without modifying it.
- Added manifest-derived safe placement with collision raycasts.
- Added F1, F2, F3, F4, and F9 test locations.
- Added local B-key boundary toggling without Input Map changes.
- Added test-only fall recovery that does not touch persistence.
- Added current and nearby loaded chunk boundary lines.
- Added periodic debug UI with loaded IDs, LOD counts, collision counts,
  requests, failures, completed loads, unloads, cache size, and timing.
- Created complete test documentation.
- Updated current tasks and decision history without deleting existing content.

---

## 3. Files Created

```text
AincradProject/scenes/world/floor_001_southern_streaming_test.tscn
AincradProject/scripts/world/floor_001_southern_streaming_test.gd
AincradProject/docs/floors/FLOOR_001_SOUTHERN_STREAMING_TEST.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_14B.md
```

---

## 4. Files Modified

```text
AincradProject/scripts/world/floor_chunk_streamer.gd
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

No existing file was moved, renamed, or deleted.

---

## 5. Important Paths

### Southern dataset

```text
AincradProject/assets/environments/floor_001/terrain/southern_region/
AincradProject/assets/environments/floor_001/terrain/southern_region/floor_001_southern_manifest.json
```

### New test

```text
AincradProject/scenes/world/floor_001_southern_streaming_test.tscn
AincradProject/scripts/world/floor_001_southern_streaming_test.gd
```

### Reusable streamer

```text
AincradProject/scripts/world/floor_chunk_streamer.gd
```

### Documentation

```text
AincradProject/docs/floors/FLOOR_001_SOUTHERN_STREAMING_TEST.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_14B.md
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

### Regression scenes that remain unchanged

```text
AincradProject/scenes/world/terrain_chunk_test.tscn
AincradProject/scenes/world/terrain_streaming_test.tscn
AincradProject/scripts/world/terrain_chunk_test_loader.gd
AincradProject/scripts/world/terrain_streaming_test.gd
AincradProject/scenes/main.tscn
AincradProject/scenes/world/test_world.tscn
AincradProject/world/floors/floor_001/floor_001_outskirts.tscn
project.godot
```

---

## 6. Technical Decisions

### Reuse rather than duplication

`floor_chunk_streamer.gd` remains the only terrain streaming implementation.
The southern scene configures it through exported values rather than copying
its queue, LOD, collision, or unloading code.

### Backward-compatible manifest normalisation

The streamer accepts the original flat test-manifest paths and the southern
nested `lod_paths` object. Existing public methods, signals, default manifest,
and default radii remain present.

### Strict expectations are opt-in

The original nine-chunk scene does not set strict expectations. The southern
scene explicitly requires:

```text
dataset floor_001_southern_region_v1
49 chunks
X -3…+3
Z +11…+17
147 actual GLBs
complete Blender exports
passed seams
all paths present and imported
```

### Independent LOD and collision

Defaults in the southern scene are:

```text
LOD0 radius 1
LOD1 visual radius 2
collision radius 1
unload radius 3
update interval 0.20 seconds
```

### Safe placement

The player is paused above manifest height bounds until the target collision is
active. A downward physics ray then places the same player on the collision
surface. Missing collision leaves the player suspended with an error instead
of allowing an unsafe fall.

### Test cache

The southern scene retains loaded resources in the streamer's local cache so
returning through the documented route does not repeatedly request identical
GLBs. Runtime nodes and collision still unload. A production cache budget is
deferred.

### Local controls

```text
F1 city gate
F2 north edge
F3 west transition
F4 east transition
F9 centre chunk
B boundary visibility
```

No Input Map changes were made.

---

## 7. Validation Completed

### Manifest and file validation

- Dataset ID matched.
- Floor ID matched.
- Chunk size was 256 metres.
- Range was X `-3…+3`, Z `+11…+17`.
- Exactly 49 unique chunk IDs existed.
- Exactly 49 unique coordinates existed.
- Exactly 49 unique LOD0 paths existed.
- Exactly 49 unique LOD1 paths existed.
- Exactly 49 unique collision paths existed.
- Exactly 147 GLB files existed.
- Exactly 147 matching `.import` records existed.
- Blender execution and export flags were true.
- Actual GLB count was 147.
- Seam validation passed.

### GLB validation

- All 147 GLB headers parsed.
- All embedded JSON chunks parsed.
- Every GLB contained position primitives.
- Combined local X/Z bounds for every GLB were `0…256` by `0…256`.

### Script validation

- GDScript parser/linter passed both changed scripts.
- Every original public method in `floor_chunk_streamer.gd` remains present.
- The new scene references existing resources only.

### Preservation validation

The following remained byte-for-byte unchanged from the uploaded archive:

- `project.godot`
- Normal main and test world scenes
- Floor 1 outskirts scene
- Fixed nine-chunk test scene
- Original nine-chunk streaming scene
- Original terrain test controller scripts
- Player scene
- Every existing `.uid` file
- Every file under `.godot/`

---

## 8. Local Tests Still Required

1. Open the outer `aincrad/` folder in Godot 4.7.
2. Allow resource import to finish.
3. Open `floor_001_southern_streaming_test.tscn`.
4. Press F6.
5. Confirm manifest validation reports PASSED and 49/49.
6. Confirm pending requests reach zero and failed requests remain zero.
7. Confirm the player raycasts onto the city-gate plateau.
8. Walk, sprint, and jump normally.
9. Walk north across Z 3584, 3328, and 3072.
10. Confirm LOD0, LOD1, collision, and unload counts change correctly.
11. Confirm no duplicate chunk roots, visuals, or static bodies accumulate.
12. Press F3 and inspect western ridges.
13. Press F4 and inspect eastern lowlands.
14. Press F2 and inspect the northern continuation edge.
15. Press F1 and confirm safe return and useful cache behaviour.
16. Press B and confirm boundaries toggle.
17. Deliberately fall below the terrain and confirm gate recovery.
18. Run `terrain_chunk_test.tscn` with F6.
19. Run `terrain_streaming_test.tscn` with F6.
20. Press F5 and confirm normal gameplay is unchanged.

Use the complete route and diagnostics guide in:

```text
AincradProject/docs/floors/FLOOR_001_SOUTHERN_STREAMING_TEST.md
```

---

## 9. Known Limitations

- Godot 4.7 was unavailable in the delivery environment, so no claim is made
  that F6 runtime physics or rendering was executed here.
- The retained test cache has no production memory budget or eviction policy.
- Runtime trimesh creation from collision GLBs should be measured locally.
- The debug boundary height is based on manifest maximum height.
- This is not normal-game integration.
- No navigation, roads, city structures, props, enemies, NPCs, or multiplayer
  streaming are included.

---

## 10. Exact Recommended Next Milestone

After local 14B approval, proceed to:

**Milestone 14C — Southern Terrain Acceptance and Empty Floor 1 Production Shell**

Create a separate production-oriented Floor 1 shell that reuses the approved
southern manifest and streamer, establishes production ownership and spawn
boundaries, and prepares a later city-gate/road blockout. Keep normal F5 startup
unchanged until that shell passes its own review.
