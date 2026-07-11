# Handoff — Milestone 15A

**Milestone:** Starting City North-Gate Architecture Greybox  
**Date:** 2026-07-11  
**Status:** Generator and static preflight complete; local Blender 5.1.2 generation required

---

## Current Project State

The project contains the accepted 49-chunk southern Floor 1 terrain, permanent
player-independent southern production shell, isolated production preview, and
all previous terrain regression scenes.

Milestone 15A adds a separate Blender architecture pipeline for the Starting
City north-gate area. It does not place architecture into the production scene
and does not alter terrain or normal F5 startup.

Blender was unavailable in the execution environment. The project therefore
contains a complete Blender-compatible generator, validated pending manifest,
preflight log, documentation, and handoff, but no fake GLBs and no fake `.blend`
source.

---

## Work Completed

- Inspected every file under `AincradProject/docs/`.
- Inspected the permanent region JSON, southern terrain profile, permanent
  production scene, existing terrain generators, naming rules, architecture
  rules, current tasks, and decision history.
- Read and cross-validated the locked `CityGateCentre`,
  `CityWallWestConnection`, `CityWallEastConnection`, and `MainRoadStart`
  markers from both JSON and the production `.tscn` scene.
- Created a Blender 5.1.2-compatible Python generator with practical Blender 4.x
  glTF fallback behaviour.
- Added `PROJECT_ROOT_OVERRIDE` and preserved outer-folder auto-detection.
- Added safe generator-owned collection and material cleanup.
- Added 16 reusable stable architecture pieces.
- Added separate render and simplified collision generation for every piece.
- Preserved a 14 m wide and 12 m high open gate passage in both variants.
- Added straight, left-curved, right-curved, intersection, and edging road
  modules.
- Added a Blender-only global reference assembly aligned to the permanent
  production markers.
- Calculated west and east wall runs that terminate exactly at X -210 and +210.
- Added source scene marker empties for visual verification in Blender.
- Added an explicitly pending architecture manifest for environments without
  Blender.
- Added a generation log that states Blender was unavailable.
- Created beginner-friendly local generation and future Godot-placement
  documentation.
- Updated `CURRENT_TASKS.md` and `DECISION_LOG.md` without deleting unrelated
  content.
- Performed Python syntax, JSON, scene-marker, path, naming, placement, and
  preservation validation.

---

## Files Created

```text
BlenderSource/floor_001/scripts/generate_floor_001_north_gate_architecture.py
BlenderSource/floor_001/logs/floor_001_north_gate_architecture.log

AincradProject/assets/environments/floor_001/architecture/north_gate/
└── floor_001_north_gate_architecture_manifest.json

AincradProject/docs/floors/FLOOR_001_NORTH_GATE_ARCHITECTURE_GENERATION.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_15A.md
```

---

## Files Modified

```text
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
```

No existing file was moved, renamed, deleted, or reorganized.

---

## Files Intentionally Not Created Yet

```text
BlenderSource/floor_001/source/floor_001_north_gate_architecture.blend
AincradProject/assets/environments/floor_001/architecture/north_gate/render/*.glb
AincradProject/assets/environments/floor_001/architecture/north_gate/collision/*.glb
```

Blender was not installed in the execution environment. Creating empty files or
non-Blender substitutes would falsely imply that Blender generated and validated
the assets.

A local Blender 5.1.2 run should create 16 render GLBs, 16 collision GLBs, and
the editable `.blend` file.

---

## Important Paths

### Generator

```text
BlenderSource/floor_001/scripts/generate_floor_001_north_gate_architecture.py
```

### Blender source output

```text
BlenderSource/floor_001/source/floor_001_north_gate_architecture.blend
```

### Log

```text
BlenderSource/floor_001/logs/floor_001_north_gate_architecture.log
```

### Runtime export root

```text
AincradProject/assets/environments/floor_001/architecture/north_gate/
```

### Manifest

```text
AincradProject/assets/environments/floor_001/architecture/north_gate/floor_001_north_gate_architecture_manifest.json
```

### Documentation

```text
AincradProject/docs/floors/FLOOR_001_NORTH_GATE_ARCHITECTURE_GENERATION.md
```

### Stable source data

```text
AincradProject/data/floors/floor_001_southern_region.json
AincradProject/data/floors/floor_001_southern_terrain_profile.json
AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
```

---

## Technical Decisions

### Local-origin modules and a global Blender reference assembly

Every runtime kit piece is generated at a predictable local origin. The
Blender-only reference assembly places copies at the real global gate location
for marker validation. The reference assembly is not exported as a monolithic
runtime GLB.

This keeps the kit reusable while proving exact world alignment.

### Locked orientation

The wall follows Godot X through Z 3835. The passage and road point toward
negative Godot Z. Blender +Y is used as the northbound local direction so the
glTF conversion produces the required Godot orientation.

### Wall connection fit

Each side uses:

```text
12 m connector
6 × 24 m full wall modules
1 × 20 m scaled end module
```

The wall run begins at absolute X 46 and ends exactly at absolute X 210.
Preflight west and east endpoint errors are both zero metres.

### Open passage

The central gate is built from two side piers and one overhead lintel. The
collision export follows the same open structure rather than using a solid box.

### Dedicated collision

Each of the 16 pieces has a separate collision GLB. Stairs use a ramp prism,
curved roads use fewer segments, detailed battlements are simplified, and the
open gate remains traversable.

### Reconstruction status

Dimensions and visual proportions are project reconstruction for a production
greybox. No claim of canon-exact SAO architecture is made.

---

## Validation Completed

- Generator Python compiles successfully.
- Ordinary-Python preflight executes successfully.
- 117 preflight checks pass.
- Region ID and Floor ID are correct.
- One unit equals one metre.
- Godot axes are validated as east +X, north -Z, and up +Y.
- All four required markers exist in the region JSON.
- All four required Marker3D nodes exist in the production scene.
- Stable IDs match between JSON and scene.
- Marker positions match between JSON, scene, and terrain profile.
- Gate centre and MainRoadStart error: 0 metres.
- West wall connection error: 0 metres.
- East wall connection error: 0 metres.
- Gate opening: 14 m wide and 12 m high.
- Sixteen unique stable piece IDs register.
- Sixteen unique render paths register.
- Sixteen unique collision paths register.
- Thirty-two expected GLB paths register.
- Reference assembly placement IDs are unique.
- Terrain is not modified.
- No existing `.uid` or `.godot/` file is modified.
- No existing file is deleted or moved.

---

## Local Tests Still Required

1. Open Blender 5.1.2.
2. Open and run
   `BlenderSource/floor_001/scripts/generate_floor_001_north_gate_architecture.py`.
3. Confirm the console prints both completion messages.
4. Confirm the four Blender marker empties match the reference assembly.
5. Confirm the west and east walls reach their locked connection markers.
6. Confirm the open passage remains unobstructed in render and collision.
7. Inspect wall, tower, connector, battlement, stair, platform, straight road,
   curved road, intersection, and edging modules.
8. Confirm road modules point north after Godot import.
9. Confirm `KitRender` contains 16 stable piece roots.
10. Confirm `KitCollision` contains 16 stable piece roots.
11. Confirm exactly 16 render GLBs and 16 collision GLBs are exported.
12. Confirm no unexpected GLBs exist in the owned export folders.
13. Confirm the editable `.blend` file is saved.
14. Confirm manifest status is `complete_blender_exports_generated`.
15. Confirm the manifest actual GLB count is 32.
16. Confirm the generation log reports Blender execution and exports as true.
17. Rerun the generator and confirm only generator-owned content is replaced.
18. Open Godot 4.7 and allow all GLBs to import.
19. Confirm one-metre scale, axes, local origins, and materials.
20. Do not integrate the kit into the permanent scene during 15A.
21. Run all existing terrain tests unchanged.
22. Press F5 and confirm normal gameplay remains unchanged.

---

## Known Limitations

- Blender did not execute in the delivery environment.
- No real architecture GLBs exist until the local Blender run.
- The editable `.blend` does not exist until the local Blender run.
- Greybox materials are placeholders.
- No final gate art, doors, interiors, city buildings, vegetation, actors,
  navigation, or gameplay exists.
- Road pieces are modular greybox assets and are not fitted to every terrain
  contour yet.
- The production region does not instance the kit yet.
- The normal F5 world remains unchanged.

---

## Exact Recommended Next Milestone

**Milestone 15B — North-Gate Godot Import and Production Placement Preview**

After local Blender generation succeeds, create a separate Godot placement
asset or controller that reads the architecture manifest, instances render and
collision pieces beneath the existing `CityGateArchitecture` and `Roads`
containers, validates the four stable markers, and provides an isolated F6
walk-through. Preserve all terrain tests and normal F5 startup.
