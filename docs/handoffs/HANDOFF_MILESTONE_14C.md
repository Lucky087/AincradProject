# Handoff — Milestone 14C

**Milestone:** Southern Terrain Acceptance and Empty Floor 1 Production Shell  
**Date:** 2026-07-11  
**Status:** Implementation and static validation complete; local Godot 4.7 F6 verification required

---

## Current Project State

The project now contains a permanent, player-independent production shell for
the real 49-chunk southern Floor 1 terrain dataset. The region is separate from
the three technical terrain tests and is not used by normal F5 startup.

The uploaded milestone instruction stated that the southern terrain was generated
and validated locally. The dataset is therefore recorded as accepted for
production iteration, while detailed unrecorded runtime measurements are not
invented.

---

## Work Completed

- Inspected every file under `AincradProject/docs/`.
- Inspected the main scene, existing player architecture, Floor 1 plan, southern
  terrain profile, completed manifest, 14B scene/controller, and reusable
  streamer.
- Created a permanent production region with environment, terrain streaming,
  empty production containers, stable markers, safe-zone volume, region bounds,
  and metadata.
- Created a valid data-driven region configuration JSON.
- Created a separate F6 preview using the existing player scene.
- Added collision-derived safe spawn, preview-only fall recovery, debug UI,
  chunk boundaries, safe-zone circle, and stable-marker guides.
- Broadened the reusable streamer's target from `CharacterBody3D` to `Node3D`
  without changing existing scene paths or removing public methods.
- Added `set_streaming_target()` and `get_streaming_target()`.
- Created the terrain acceptance document.
- Updated current tasks, technical architecture, and decision history.
- Removed the two orphaned Git conflict-marker lines in `DECISION_LOG.md`.

---

## Files Created

```text
AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
AincradProject/scripts/world/floor_001_southern_region.gd
AincradProject/data/floors/floor_001_southern_region.json
AincradProject/scenes/world/floor_001_southern_region_preview.tscn
AincradProject/scripts/world/floor_001_southern_region_preview.gd
AincradProject/docs/floors/FLOOR_001_SOUTHERN_TERRAIN_ACCEPTANCE.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_14C.md
```

---

## Files Modified

```text
AincradProject/scripts/world/floor_chunk_streamer.gd
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
AincradProject/docs/TECHNICAL_ARCHITECTURE.md
```

No existing file was moved, renamed, or deleted.

---

## Documentation Conflict Cleanup

`DECISION_LOG.md` contained two orphaned lines after D-074:

```text
=======
>>>>>>> 61eba00fefd3ea4dbb53cd012620dfa990f1e2e0
```

Only those two lines were removed. There was no surviving `<<<<<<<` marker, no
alternate text between the markers, and no project decision was discarded.
D-074 and D-075 remain intact.

---

## Important Paths

```text
Permanent production region:
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn

Production controller:
res://AincradProject/scripts/world/floor_001_southern_region.gd

Region configuration:
res://AincradProject/data/floors/floor_001_southern_region.json

F6 preview:
res://AincradProject/scenes/world/floor_001_southern_region_preview.tscn

Preview controller:
res://AincradProject/scripts/world/floor_001_southern_region_preview.gd

Reusable streamer:
res://AincradProject/scripts/world/floor_chunk_streamer.gd

Terrain manifest:
res://AincradProject/assets/environments/floor_001/terrain/southern_region/floor_001_southern_manifest.json

Acceptance document:
res://AincradProject/docs/floors/FLOOR_001_SOUTHERN_TERRAIN_ACCEPTANCE.md
```

---

## Technical Decisions

### Permanent region versus preview

The permanent region represents the world and contains no player instance. The
preview instances the existing player separately and assigns it as the streamer's
target. Future main-world logic should follow the same ownership boundary.

### Streamer reuse

The existing streamer remains the only chunk-streaming implementation. Existing
nine-chunk and 14B scenes keep their player paths and defaults. The new production
scene starts with a stable `Marker3D` streaming anchor and the preview switches
to the existing player through the new target API.

### Production cache

The permanent region leaves `retain_loaded_resources_in_memory` false. The 14B
technical test keeps its isolated validation cache. A bounded production cache
still requires measured profiling.

### Stable region data

The production region ID is:

```text
region_floor_001_southern
```

The terrain dataset remains:

```text
floor_001_southern_region_v1
```

The configuration validates the 49-chunk range, 256-metre chunk size, stable
marker positions, safe-zone data, content-container paths, and approved
streaming values.

### Safe zone

The city-gate safe zone is a 305-metre-radius cylinder centred at `(0, 9, 3835)`.
It only tracks bodies and emits enter/exit signals. It does not alter combat,
enemy spawning, checkpoints, progression, or saves.

### Reconstruction status

The terrain and marker layout are project reconstruction guided by the locked
Floor 1 plan. They are accepted as a production base, not canon-exact final art.

---

## Validation Completed

The final static validation completed successfully:

- 1,190 structural, data, resource, preservation, and consistency checks passed.
- Region JSON, terrain profile, Floor 1 plan, and southern manifest parse.
- All 49 manifest records register and all 147 GLB paths plus Godot import
  records exist.
- Region marker definitions match scene node names, stable IDs, and positions.
- Safe-zone centre and 305-metre radius match the terrain profile.
- Road markers match the profile control points.
- Production streaming values match the region JSON.
- The production scene contains no player instance.
- The preview references the unchanged existing player scene.
- All three changed GDScript files pass the GDScript parser and `gdlint`.
- Existing test scenes remain byte-for-byte unchanged.
- `project.godot`, normal F5 scene, player scene/scripts, SaveManager, `.uid`
  files, and `.godot/` remain byte-for-byte unchanged.
- `DECISION_LOG.md` contains no remaining conflict-marker lines.
- Exactly seven files were created, four intended files were modified, no files
  were moved, and no files were deleted.

Godot 4.7 was not available in the execution environment, so F6 rendering,
physics, collision placement, and regression execution must be completed locally.

---

## Local Tests Still Required

1. Open `floor_001_southern_region.tscn` and verify there are no missing
   resources or parser errors.
2. Open `floor_001_southern_region_preview.tscn` and press F6.
3. Confirm manifest validation passes and 49 chunks register.
4. Confirm the player lands safely at `PlayerSpawnCityGate`.
5. Confirm movement, sprint, jump, camera, and existing controls work.
6. Walk north across at least three chunk borders.
7. Confirm LOD0, LOD1, collision, and unload counts change correctly.
8. Confirm the safe-zone state changes when crossing the green preview circle.
9. Press B to toggle current/loaded chunk boundaries.
10. Press M to toggle marker and safe-zone guides.
11. Press F1 to return safely to the gate.
12. Trigger fall recovery and confirm no progression or save state changes.
13. Run `terrain_chunk_test.tscn` unchanged.
14. Run `terrain_streaming_test.tscn` unchanged.
15. Run `floor_001_southern_streaming_test.tscn` unchanged.
16. Press F5 and confirm the existing outskirts world still starts.
17. Confirm no duplicate players, roots, visual LODs, or collision bodies
    accumulate.

---

## Known Limitations

- Production terrain still uses placeholder materials.
- No final terrain art, roads, walls, gate, buildings, foliage, rocks, water,
  enemies, NPCs, navigation, quests, or encounters exist.
- Safe-zone gameplay rules are not implemented.
- Region bounds are exposed as data/hooks, not hard blocking volumes.
- Production resource-cache policy remains unprofiled.
- Detailed local 14B runtime measurements were not archived in the uploaded
  project.
- The permanent region is intentionally not integrated into F5.

---

## Exact Recommended Next Milestone

**Milestone 15A — Starting City North-Gate Architecture Greybox**

Use these locked anchors:

```text
CityGateCentre
CityWallWestConnection
CityWallEastConnection
MainRoadStart
PlayerSpawnCityGate
safe_zone_starting_city_gate_plateau
```

Create modular greybox architecture only. Preserve the production region,
terrain generators, terrain GLBs, stable marker IDs, technical test scenes, and
normal F5 startup.
