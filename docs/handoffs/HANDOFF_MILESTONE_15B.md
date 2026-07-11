# Handoff — Milestone 15B

**Milestone:** North-Gate Godot Import and Production Placement Preview  
**Date:** 2026-07-11  
**Implementation status:** Complete  
**Runtime acceptance status:** Failed on original road collision; 15B.1 fix implemented and awaiting local F6 retest

---

## Current Project State

The project contains:

- The accepted 49-chunk southern Floor 1 terrain dataset.
- The permanent player-independent southern production region.
- The unchanged southern production-region F6 preview.
- The completed Blender-generated north-gate architecture kit.
- 16 render architecture GLBs.
- 16 dedicated simplified collision GLBs.
- A reusable manifest-driven Godot north-gate assembly.
- A separate F6 placement and collision preview using the existing player.

The north-gate assembly has not been added to the permanent production region
and normal F5 startup is unchanged.

---

## Work Completed

- Read every file under `AincradProject/docs/`.
- Inspected the uploaded project structure and current 14C/15A implementation.
- Parsed and validated the completed architecture manifest.
- Confirmed 16 unique stable piece IDs.
- Confirmed 16 render and 16 collision GLBs exist.
- Parsed all 32 GLBs successfully during static validation.
- Confirmed one unit per metre and Godot north along negative Z.
- Confirmed the 14-metre-wide and 12-metre-high passage values.
- Confirmed the central collision GLB contains two side piers and one lintel.
- Confirmed 30 unique reference placement records.
- Confirmed continuous wall-module intervals and endpoints at X -210 and +210.
- Created a reusable architecture-only Godot assembly.
- Loaded all 16 render and 16 collision resources through stable IDs.
- Instantiated the manifest reference placements below stable category containers.
- Created physics only from the dedicated collision GLBs.
- Recorded the local runtime failure where road contact stopped player movement.
- Inspected the actual straight, curved, intersection, and edging collision GLBs.
- Confirmed inverted straight-road top/bottom triangle winding, terrain overlap,
  coincident module-end faces, and overlapping intersection slabs.
- Disabled flat road and road-edging physics while retaining their render and
  source-debug GLBs.
- Made streamed terrain collision authoritative beneath the visual road.
- Added road collision counts, duplicate detection, transform reporting, and
  road-surface-versus-terrain diagnostics.
- Added hidden collision-source visualization for local inspection.
- Added placement markers and runtime alignment calculations.
- Added safe pending/invalid-manifest handling.
- Created a separate F6 preview with the permanent terrain region and existing
  player.
- Added F1–F4 safe teleports, G marker toggle, C collision visualization, and B
  terrain-boundary toggle.
- Added preview-only fall recovery without save or progression changes.
- Added periodic architecture, alignment, player, passage, and terrain debug UI.
- Added beginner-facing documentation.
- Updated current tasks, decision log, and technical architecture documentation.
- Kept all existing regression scenes and normal F5 startup unchanged.

---

## Files Created

```text
AincradProject/world/floors/floor_001/architecture/
└── floor_001_north_gate_assembly.tscn

AincradProject/scripts/world/
├── floor_001_north_gate_assembly.gd
└── floor_001_north_gate_preview.gd

AincradProject/scenes/world/
└── floor_001_north_gate_preview.tscn

AincradProject/docs/floors/
└── FLOOR_001_NORTH_GATE_GODOT_PREVIEW.md

AincradProject/docs/handoffs/
└── HANDOFF_MILESTONE_15B.md
```

No placement JSON was created because the Blender architecture manifest already
contains complete stable placement records.

---

## Files Modified

```text
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
AincradProject/docs/TECHNICAL_ARCHITECTURE.md
```

### Milestone 15B.1 modified files

```text
AincradProject/scripts/world/floor_001_north_gate_assembly.gd
AincradProject/scripts/world/floor_001_north_gate_preview.gd
AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
AincradProject/docs/floors/FLOOR_001_NORTH_GATE_GODOT_PREVIEW.md
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_15B.md
```

No production region, existing test scene, player file, gameplay system,
SaveManager file, project setting, `.uid` file, `.godot/` file, terrain asset,
architecture asset, manifest, or Blender generator was modified.

---

## Important Paths

```text
Architecture manifest:
res://AincradProject/assets/environments/floor_001/architecture/north_gate/floor_001_north_gate_architecture_manifest.json

Reusable assembly:
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn

Assembly controller:
res://AincradProject/scripts/world/floor_001_north_gate_assembly.gd

F6 preview:
res://AincradProject/scenes/world/floor_001_north_gate_preview.tscn

Preview controller:
res://AincradProject/scripts/world/floor_001_north_gate_preview.gd

Permanent terrain region:
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn

Documentation:
res://AincradProject/docs/floors/FLOOR_001_NORTH_GATE_GODOT_PREVIEW.md
```

---

## Manifest Validation

Required and statically confirmed:

```text
Asset-set ID: floor_001_starting_city_north_gate_architecture_v1
Generation status: complete_blender_exports_generated
Stable pieces: 16
Render GLBs: 16
Collision GLBs: 16
Actual GLB total: 32
Reference placements: 30
Units per metre: 1
North direction: -Z
Passage width: 14 m
Passage height: 12 m
Preflight: passed
Open passage: preserved
```

If the manifest later reports pending exports, the assembly displays a clear
failure and creates no fake architecture.

---

## Placement and Alignment Decisions

- The reusable assembly root is placed at `CityGateCentre` `(0, 9, 3835)`.
- All placement records remain local to that stable root.
- The gate and road centre match `MainRoadStart`.
- The gate passage faces negative Z.
- Towers are symmetrical at local X -25 and +25.
- Connectors are placed at local X -40 and +40.
- Wall sections use the exact Blender reference transforms.
- The final wall module on each side uses X scale `0.8333333333` to terminate at
  the ±210-metre markers.
- The assembly validates marker positions with a 0.05-metre target tolerance.
- The permanent southern production region remains unmodified until local
  acceptance is recorded.

---

## Render and Collision Decisions

- All 16 render resources are loaded and validated.
- All 16 collision resources are loaded and validated.
- Only manifest reference placements are instantiated into the visible gate
  layout.
- Each placement keeps a stable root and exact manifest transform.
- Imported placeholder render materials remain unchanged.
- Every placed physics body is built from the matching collision GLB.
- Collision meshes become `CollisionShape3D` children under one
  `StaticBody3D` per placement.
- Render meshes are never used as collision substitutes.
- Collision GLB visuals are hidden by default and used only for the C-key debug
  inspection mode.

### Milestone 15B.1 road policy

- Flat straight, curved, and intersection road physics is disabled by default.
- Straight road-edging physics is disabled by default.
- The current three straight road and six edging placements create no
  `StaticBody3D` nodes.
- Terrain collision is the walking surface beneath the road render geometry.
- The expected active totals are 21 architecture bodies and 23 shapes.
- The expected road totals are zero bodies and zero shapes.
- Nine road/edging placements are expected to report disabled.
- Duplicate collision-placement count must remain zero.
- C-key source visualization remains available: red is active, amber is disabled.
- Player movement, player shape, terrain, terrain streaming, and Blender assets
  remain unchanged.

---


## Milestone 15B.1 Runtime Bug and Confirmed Cause

Observed locally:

- Movement worked on terrain.
- Standing or landing on road pieces stopped horizontal movement.
- Teleporting away restored movement.

Confirmed from the shipped GLBs and placements:

- Three straight-road and six edging concave bodies were active.
- Straight-road collision top triangles face downward.
- Straight-road collision bottom triangles face upward at world Y 9.02.
- Terrain beneath the road intersects or closely approaches that lower surface.
- Exact road-module joins add coincident vertical triangle planes.
- The intersection kit collision contains overlapping thin slabs.
- Manifest placement IDs are unique; duplicate assembly creation was not the
  cause.

The capsule was therefore resolving simultaneous terrain and concave road
contacts, including bottom, side, and join triangles. This explains why the
failure was isolated to road contact without requiring a player-controller
change.

## Validation Completed

Static validation completed in the delivery environment:

- All documentation files were read.
- Architecture JSON parsed.
- Stable piece IDs are unique.
- All 32 GLB paths exist.
- All 32 GLBs parsed successfully with non-empty geometry.
- Gate collision has exactly three intended mesh parts.
- Reference placement IDs are unique.
- Road-category placement IDs are unique.
- Current reference layout contains three flat road and six edging placements.
- 15B.1 policy statically omits physics for all nine road/edging placements.
- Expected active collision totals are 21 bodies and 23 shapes.
- Expected road collision totals are zero bodies and zero shapes.
- Wall placement intervals are continuous.
- West endpoint resolves to -210 metres.
- East endpoint resolves to +210 metres.
- New scene resource references exist.
- New GDScript files parse through `gdtoolkit`.
- New GDScript files pass `gdlint`.
- New GDScript files pass `gdformat --check`.

Godot 4.7 was not available in the execution environment. Runtime rendering,
physics, player traversal, and F5/F6 regression execution were not claimed.

---

## Local Tests Still Required

### Mandatory Milestone 15B.1 road retest

- [ ] Confirm flat road physics reports OFF.
- [ ] Confirm road edging physics reports OFF.
- [ ] Confirm active road bodies and shapes both report zero.
- [ ] Confirm disabled road/edging placements report nine.
- [ ] Confirm duplicate collision placements report zero.
- [ ] Press C and confirm road and edging source meshes are amber.
- [ ] Walk from terrain onto the first visible road section.
- [ ] Walk and sprint the full three-section road in both directions.
- [ ] Cross both joins repeatedly.
- [ ] Jump and land on each section and across both joins.
- [ ] Walk from the road back onto terrain.
- [ ] Walk beside both road edges without wedging.
- [ ] Walk through the gate passage in both directions.
- [ ] Confirm walls, towers, gate piers, stairs, and platform still block/support
      the player correctly.
- [ ] Review road-surface-versus-terrain diagnostics and record visual contact
      differences separately from collision acceptance.


### Import and startup

- [ ] Open the project in Godot 4.7.
- [ ] Allow all architecture GLBs to finish importing.
- [ ] Open `floor_001_north_gate_assembly.tscn` without missing resources.
- [ ] Run `floor_001_north_gate_preview.tscn` with F6.
- [ ] Confirm manifest status passes.
- [ ] Confirm render assets report 16/16.
- [ ] Confirm collision assets report 16/16.
- [ ] Confirm failed assets remain zero.

### Alignment

- [ ] Confirm gate centre error is at most 0.05 metres.
- [ ] Confirm west endpoint error is at most 0.05 metres.
- [ ] Confirm east endpoint error is at most 0.05 metres.
- [ ] Confirm road centreline error is at most 0.05 metres.
- [ ] Confirm gate forward reports negative Z.
- [ ] Press G and inspect the stable placement markers.

### Passage and collision

- [ ] Press F1 and walk through the gate to the city side.
- [ ] Confirm the passage is physically open.
- [ ] Confirm the debug UI detects the player inside the passage.
- [ ] Walk back out through the opening.
- [ ] Walk into the gate piers, towers, connectors, and walls.
- [ ] Confirm they block the player correctly.
- [ ] Confirm no invisible collision spans the passage.
- [ ] Press C and compare collision-source visuals with the render layout.
- [ ] Confirm no duplicate StaticBody3D nodes accumulate.

### Road and access

- [ ] Walk across all three straight road modules.
- [ ] Confirm road joins are traversable.
- [ ] Confirm road edging does not block the centreline.
- [ ] Confirm the road does not float or bury substantially.
- [ ] Test the left access stair ramp.
- [ ] Confirm the platform is reachable.

### Endpoints and terrain

- [ ] Press F3 and inspect the west endpoint.
- [ ] Press F4 and inspect the east endpoint.
- [ ] Confirm no large wall gaps or heavy wall overlaps.
- [ ] Confirm architecture rests acceptably on the existing plateau.
- [ ] Document any small foundation mismatch for later correction.
- [ ] Do not edit terrain during this test.

### Regression

- [ ] Run `terrain_chunk_test.tscn`.
- [ ] Run `terrain_streaming_test.tscn`.
- [ ] Run `floor_001_southern_streaming_test.tscn`.
- [ ] Run `floor_001_southern_region_preview.tscn`.
- [ ] Press F5 and confirm the existing normal game still starts.
- [ ] Confirm no save or progression state changes from preview teleports or fall
      recovery.

---

## Known Limitations

- The gate is an original project greybox reconstruction, not final canon art.
- Terrain contact along the complete 420-metre wall has not been runtime
  inspected in this environment.
- One connector/tower overlap of approximately one metre per side is intentional
  to avoid a visible seam.
- The current road is only a short northbound test strip.
- Curves and intersection assets are loaded and validated but not placed.
- The neutral and inner wall variants remain kit assets rather than reference
  placements.
- Raised architecture collision is created from dedicated concave trimesh
  GLBs. Flat road and edging collision are disabled after the 15B.1 runtime
  failure; future raised roads require authored simple collision.
- Non-uniform X scaling is used only for the two manifest-approved wall end
  trims and requires local Godot physics inspection.
- No final textures, decorative architecture, city interiors, navigation, actors,
  or main-game integration are included.

---

## Exact Recommended Next Milestone

**Milestone 15C — North-Gate Production Acceptance and Provisional Region
Integration**

Only after the complete 15B.1 road retest and all 15B regression checks pass:

- Record the measured runtime results.
- Instance the reusable assembly scene beneath
  `StaticContent/CityGateArchitecture`.
- Do not copy individual GLBs into the production region.
- Keep the assembly removable and regenerable.
- Address only accepted foundation/terrain-contact issues.
- Preserve all technical previews as regression tools.
- Do not begin the full Starting City, final art, NPCs, enemies, quests, or
  navigation yet.
