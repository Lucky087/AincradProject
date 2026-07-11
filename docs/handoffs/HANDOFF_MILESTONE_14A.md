# Handoff — Milestone 14A

**Milestone:** Actual Southern Floor 1 Terrain Generation  
**Date:** 2026-07-11  
**Implementation status:** Script, data, documentation, manifest preflight, and mathematical validation complete  
**Local approval status:** Blocked only on running Blender 5.1.2 and inspecting the real exports

---

## 1. Current Project State

The project still uses the complete uploaded outer structure:

```text
aincrad/
├── project.godot
├── .godot/
├── AincradProject/
└── BlenderSource/
```

All existing gameplay, player, UI, save, Godot project, Floor 1 outskirts,
nine-chunk terrain test, fixed terrain test, runtime streaming test, test GLBs,
test manifest, Blender test generator, Blender test source, `.uid` files, and
`.godot/` contents remain unchanged.

Milestone 14A adds a separate map-aware southern terrain dataset. The dataset
is not integrated into normal F5 gameplay and does not replace any regression
scene.

---

## 2. Work Completed

- Created a validated data-driven southern terrain profile.
- Locked the requested 7 × 7 range: X `-3…+3`, Z `+11…+17`.
- Created a Blender 5.1.2 generator with practical Blender 4.x compatibility.
- Added deterministic global-coordinate terrain generation.
- Added city-gate plateau and safe-zone grading.
- Added a curved northbound future-road terrain corridor.
- Added beginner grasslands with gradually increasing northern variation.
- Added western woodland-transition ridges and sheltered terrain.
- Added eastern lowland and drainage tendencies without water.
- Added authored height-control influence.
- Added LOD0, LOD1, and collision sampling rules.
- Added safe generator-owned collections, materials, and marker objects.
- Added seam, shared-corner, placement, dimension, cross-resolution, and slope
  validation.
- Added a mathematical preflight mode for environments without Blender.
- Created a 49-record pending manifest and explicit preflight log.
- Added complete generation documentation.
- Updated current tasks and decision records without deleting existing content.

---

## 3. Files Created

```text
AincradProject/data/floors/floor_001_southern_terrain_profile.json
AincradProject/assets/environments/floor_001/terrain/southern_region/floor_001_southern_manifest.json
AincradProject/docs/floors/FLOOR_001_SOUTHERN_TERRAIN_GENERATION.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_14A.md
BlenderSource/floor_001/scripts/generate_floor_001_southern_terrain.py
BlenderSource/floor_001/logs/floor_001_southern_terrain.log
```

The manifest and log currently record mathematical preflight status. They are
real validated text outputs, not claims that Blender exported meshes.

---

## 4. Files Modified

```text
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

No existing content was intentionally removed. New Milestone 14A status and
decisions were added.

---

## 5. Files Intentionally Not Created Yet

```text
BlenderSource/floor_001/source/floor_001_southern_terrain.blend
147 GLB files under AincradProject/assets/environments/floor_001/terrain/southern_region/
```

Blender was unavailable in the delivery environment. No fake `.blend` or GLB
files were created.

---

## 6. Important Paths

### Source data

```text
AincradProject/data/floors/floor_001.json
AincradProject/data/floors/floor_001_southern_terrain_profile.json
```

### Generator

```text
BlenderSource/floor_001/scripts/generate_floor_001_southern_terrain.py
```

### Local Blender outputs

```text
BlenderSource/floor_001/source/floor_001_southern_terrain.blend
BlenderSource/floor_001/logs/floor_001_southern_terrain.log
AincradProject/assets/environments/floor_001/terrain/southern_region/
AincradProject/assets/environments/floor_001/terrain/southern_region/floor_001_southern_manifest.json
```

### Documentation

```text
AincradProject/docs/floors/FLOOR_001_SOUTHERN_TERRAIN_GENERATION.md
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

### Regression terrain that must remain unchanged

```text
AincradProject/assets/environments/floor_001/terrain/test_chunks/
AincradProject/scenes/world/terrain_chunk_test.tscn
AincradProject/scenes/world/terrain_streaming_test.tscn
AincradProject/scripts/world/terrain_chunk_test_loader.gd
AincradProject/scripts/world/floor_chunk_streamer.gd
AincradProject/scripts/world/terrain_streaming_test.gd
BlenderSource/floor_001/scripts/generate_floor_001_terrain_test.py
BlenderSource/floor_001/source/floor_001_terrain_test.blend
```

---

## 7. Technical Decisions

### Chunk range

```text
X: -3 through +3
Z: +11 through +17
Centre: floor_001_chunk_x+00_z+14
Coverage: X -768…+1024, Z +2816…+4608
```

The planned gate point `(0, 3835)` lies inside the centre chunk.

### Profile-owned terrain decisions

The profile, rather than hidden Python constants, owns the seed, plateau,
road, transitions, drainage, height controls, slope limits, range, and
reconstruction labels.

### Global terrain sampling

All vertices use global Floor 1 X/Z coordinates. No chunk-local random state is
used. LOD1 and collision vertices are aligned subsets of LOD0.

### Safe reruns

The generator removes only a tagged `Floor001SouthernTerrain` hierarchy. It
stops on an untagged name conflict. Existing Blender objects are not cleared.

### Preflight manifest

Before Blender execution, the manifest status is:

```text
preflight_validated_blender_export_pending
```

After a successful Blender run it becomes:

```text
complete_blender_exports_generated
```

The local run must not be considered complete while the pending status remains.

---

## 8. Validation Completed

- Python syntax compilation passed.
- Floor 1 master JSON parsed and validated.
- Southern terrain profile parsed and validated.
- Exactly 49 chunk coordinates generated.
- 49 LOD0 grids sampled at 65 × 65 vertices.
- 49 LOD1 grids aligned at 33 × 33 vertices.
- 49 collision grids aligned at 17 × 17 vertices.
- East/west and north/south borders passed.
- Shared corners passed.
- Cross-resolution footprints passed.
- Logical dimensions and placements passed.
- Configured slope limits passed.

Recorded results:

```text
Border values compared:           9660
Shared-corner values compared:     324
Cross-resolution values compared: 67522
Placement checks:                  294
Dimension checks:                  294
Maximum sampled slope ratio:       0.098960
Maximum safe-zone slope ratio:     0.017429
Maximum road-corridor slope ratio: 0.033653
```

The preflight printed:

```text
SOUTHERN TERRAIN SEAM VALIDATION PASSED
```

---

## 9. Local Tests Still Required

1. Open Blender 5.1.2.
2. Open and run:

```text
BlenderSource/floor_001/scripts/generate_floor_001_southern_terrain.py
```

3. Confirm 49 LOD0, 49 LOD1, and 49 collision objects.
4. Confirm every mesh is 256 × 256 metres horizontally.
5. Inspect the gate plateau, road corridor, northward grasslands, western
   transition, and eastern lowlands.
6. Confirm marker objects are useful and not included in GLBs.
7. Confirm the exact seam-validation success message.
8. Confirm exactly 147 GLBs exist.
9. Confirm `floor_001_southern_terrain.blend` exists.
10. Confirm the manifest reports complete Blender exports and 147 actual GLBs.
11. Confirm the log reports Blender execution and exports as true.
12. Open Godot 4.7 and allow the GLBs to import normally.
13. Run the unchanged fixed and streaming terrain regression scenes.
14. Run normal F5 gameplay and confirm it remains unchanged.

Use the complete checklist in:

```text
AincradProject/docs/floors/FLOOR_001_SOUTHERN_TERRAIN_GENERATION.md
```

---

## 10. Known Limitations

- Blender did not execute in the delivery environment.
- The real 147 GLBs do not exist yet.
- The southern `.blend` source does not exist yet.
- Godot has not imported or rendered this dataset yet.
- The placeholder materials are not final art.
- There are no roads, props, water, navigation, actors, city structures, or
  gameplay integration.
- Exact terrain contours are project reconstruction, not official canon.
- `DECISION_LOG.md` already contained pre-existing merge-conflict marker text
  near the Milestone 13C decisions. It was not removed or rewritten during
  14A because unrelated existing content was preserved.

---

## 11. Exact Recommended Next Milestone

After every Milestone 14A local Blender and regression check passes, proceed to:

```text
MILESTONE 14B: SOUTHERN TERRAIN GODOT IMPORT AND 7 × 7 STREAMING VALIDATION
```

Recommended 14B scope:

- Reject a pending or incomplete manifest.
- Create a separate F6 test scene for the 49-chunk dataset.
- Reuse the existing chunk-streamer architecture rather than creating a second
  streaming system.
- Verify Godot axes, 1 metre scale, bounds, materials, and GLB origins.
- Stream LOD0, LOD1, and collision independently across the full 7 × 7 area.
- Add terrain-only test spawn and fall recovery.
- Test every outer boundary and negative-X coordinate transition.
- Keep `project.godot`, normal F5 gameplay, existing tests, saves, player, UI,
  and `.uid` files unchanged.
- Do not create final roads, city structures, vegetation, water, enemies, NPCs,
  or navigation yet.
