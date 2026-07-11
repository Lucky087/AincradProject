# Handoff — Milestone 16A

**Milestone:** Main Northbound Road Greybox and Spline Placement  
**Date:** 2026-07-11  
**Implementation status:** Complete  
**Static validation status:** Passed  
**Local Godot 4.7 runtime status:** Required

## Current Project State

The project contains:

- The accepted 49-chunk southern terrain dataset.
- The permanent player-independent southern production region.
- The provisionally accepted north-gate assembly integrated once in that region.
- The accepted terrain-authoritative road-collision fix.
- A new reusable main-road assembly and separate F6 preview.
- No normal F5 main-road integration.

## Work Completed

- Read every file under `AincradProject/docs/`.
- Inspected the accepted gate assembly, production region, terrain profile,
  region JSON, stable markers, road GLBs, architecture manifest, player preview
  architecture, and terrain-streamer API.
- Created stable main-road route data.
- Used the five control points shared by production JSON and Marker3D nodes.
- Kept terrain-profile-only `road_04` out of permanent route data.
- Authored editable Bezier handle offsets in JSON.
- Created a reusable `Path3D`-based road assembly.
- Reused the existing straight, left-curve, right-curve, intersection, and
  edging asset IDs from the architecture manifest.
- Validated the intersection asset but did not place it because no branch exists.
- Added straight-versus-curve selection from spline heading change.
- Added stable placement IDs and three route-section containers.
- Preserved terrain-authoritative flat-road collision with zero new road physics.
- Reused the accepted gate road for the first 80 metres.
- Began new placements at the gate-road north edge to prevent duplication.
- Added a 48-metre visual height blend from the accepted gate-road base Y `9.02`
  into the terrain-following spline, with pitched straight modules.
- Added sparse visual-only edging, disabled by default.
- Added spline, control-point, placement, and direction debug visualization.
- Added an F6 preview with the existing player and production region.
- Added safe local teleports, fall recovery, road statistics, nearest-segment
  reporting, and terrain-boundary visualization.

## Files Created

```text
AincradProject/data/floors/floor_001_main_road.json
AincradProject/world/floors/floor_001/roads/floor_001_main_road_assembly.tscn
AincradProject/scripts/world/floor_001_main_road_assembly.gd
AincradProject/scenes/world/floor_001_main_road_preview.tscn
AincradProject/scripts/world/floor_001_main_road_preview.gd
AincradProject/docs/floors/FLOOR_001_MAIN_ROAD_PREVIEW.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_16A.md
```

## Files Modified

```text
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
AincradProject/docs/TECHNICAL_ARCHITECTURE.md
```

## Road Route and Control Points

```text
road_gate                    (0, 9, 3835)
road_01                     (12, 8.3, 3665)
road_02                    (-28, 8.8, 3480)
road_03                     (34, 10.2, 3280)
road_north_continuation     (20, 14, 2816)
```

The spline begins and ends at the locked production anchors and progresses
northward along negative Z. Static mathematical preflight measures approximately
1,036.26 metres.

## Modular Placement

Static preflight predicts:

```text
Total placements: 41
Straight:         38
Left curve:        1
Right curves:      2
```

Godot runtime reports the actual baked result in the preview debug panel.

Straight modules use a 24-metre horizontal chord. Curves use the existing
15.529-metre chord. Placement endpoints are found along the baked spline rather
than by hard-coded world transforms.

## Gate Transition Decision

The integrated gate assembly already supplies three straight road modules over
the first 80 metres north of the gate. The new spline includes the gate start for
route continuity, but generated 16A modules begin at distance 80 metres.

This avoids both a duplicate road inside the gate and a second gate assembly.

## Collision Policy

```text
terrain_authoritative_flat_road_visual_only
```

- Straight road collision: disabled.
- Curved road collision: disabled.
- Intersection collision: disabled.
- Road-edging collision: disabled.
- Terrain collision: authoritative.
- No collision GLB is loaded by the main-road assembly.

This preserves the accepted Milestone 15B.1 runtime fix.

## Important Paths

```text
res://AincradProject/data/floors/floor_001_main_road.json
res://AincradProject/world/floors/floor_001/roads/floor_001_main_road_assembly.tscn
res://AincradProject/scenes/world/floor_001_main_road_preview.tscn
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
```

## Validation Completed

- All project documentation was inspected.
- Road JSON parses successfully.
- All five route positions match the production-approved data.
- Route Z values preserve northward progression.
- The route starts and ends at the required coordinates.
- The architecture manifest reports completed Blender exports.
- All five required road render assets exist and parse as GLBs.
- Straight and curved geometry dimensions match manifest expectations.
- The gate-transition distance matches the accepted three-piece road strip.
- Static spline and modular-placement preflight completes without loops.
- No flat road collision is created by either new scene or script.
- GDScript parser, lint, and format checks pass.
- New scene resource references resolve statically.
- Existing protected scenes, assets, `.uid`, `.godot/`, player code, terrain
  streamer, SaveManager, and `project.godot` remain unchanged.

Godot 4.7 was unavailable in the delivery environment, so local F6 traversal is
not claimed.

## Local Tests Still Required

- [ ] Run `floor_001_main_road_preview.tscn` with F6.
- [ ] Confirm road status is READY and failed assets are zero.
- [ ] Confirm the runtime placement count and piece counts look reasonable.
- [ ] Confirm there is no duplicate road inside the gate.
- [ ] Walk and sprint from the gate to the northern exit.
- [ ] Jump and land along straight and curved pieces.
- [ ] Cross every visible road-piece join without becoming stuck.
- [ ] Leave the road onto terrain and re-enter it.
- [ ] Confirm curves bend in the intended direction.
- [ ] Inspect the spline with R and placement markers with P.
- [ ] Toggle sparse edging with E and confirm it stays outside the walkway.
- [ ] Toggle terrain boundaries with B and cross several chunks.
- [ ] Confirm terrain streaming remains functional at every teleport.
- [ ] Re-run north-gate and southern-region previews.
- [ ] Run the three existing technical terrain tests unchanged.
- [ ] Press F5 and confirm the existing normal game remains unchanged.

## Known Greybox Limitations

- Curved modules approximate rather than deform to the spline.
- Road pieces do not dynamically conform to every terrain vertex.
- Minor visual sinking or floating may need later placement refinement.
- Edging is sparse, visual-only, and disabled by default.
- No branches or intersection placement exists.
- No final paving, decals, drainage, vegetation blending, signs, actors,
  navigation, or gameplay integration exists.
- The road assembly is not yet instanced in the permanent production region.

## Exact Recommended Next Milestone

**Milestone 16B — Main Northbound Road Acceptance and Provisional Southern
Region Integration**

Begin it only after the full local route, road-collision, terrain-streaming,
preview-regression, and F5 checklist passes. Integrate one reusable road assembly
beneath `StaticContent/Roads`; do not copy individual GLBs.
