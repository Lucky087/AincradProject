# Floor 1 North-Gate Godot Import and Placement Preview

**Milestone:** 15B — North-Gate Godot Import and Production Placement Preview  
**Engine target:** Godot 4.7  
**Status:** Milestone 15B.1 runtime accepted by user; assembly provisionally integrated into the production region in Milestone 15C  
**Normal F5 world changed:** No

---

## 1. Purpose

Milestone 15B imports the Blender-generated Floor 1 Starting City north-gate
architecture as a reusable, manifest-driven Godot assembly and places that
assembly in a separate F6 preview.

The preview verifies:

- One-metre scale.
- Godot north orientation along negative Z.
- Gate, tower, connector, and wall placement.
- A physically open 14-metre-wide and 12-metre-high gate passage.
- West and east wall endpoint alignment.
- Road centreline alignment.
- Dedicated render assets.
- Dedicated simplified collision assets.
- Player movement through the greybox architecture.

The assembly is now provisionally instanced once inside the permanent southern
production region. The preview reuses that production-owned instance, while the
normal F5 world remains unchanged.

---

## 2. Manifest Loaded

The assembly loads:

```text
res://AincradProject/assets/environments/floor_001/architecture/north_gate/floor_001_north_gate_architecture_manifest.json
```

The controller requires:

- Asset-set ID `floor_001_starting_city_north_gate_architecture_v1`.
- Generation status `complete_blender_exports_generated`.
- Exactly 16 piece records.
- Exactly 16 render GLBs.
- Exactly 16 collision GLBs.
- Actual total GLB count 32.
- Unique stable piece IDs.
- Existing render and collision paths for every piece.
- One unit per metre.
- Godot north equal to negative Z and up equal to positive Y.
- Gate passage width 14 metres.
- Gate passage height 12 metres.
- Blender architecture preflight passed.
- Open gate passage preserved.

If the manifest is still pending or invalid, the assembly reports a clear error,
loads no fake architecture, keeps the preview scene alive, and does not crash.

---

## 3. Reusable Assembly Scene

The reusable assembly is:

```text
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
```

Its controller is:

```text
res://AincradProject/scripts/world/floor_001_north_gate_assembly.gd
```

The scene contains architecture only:

```text
Floor001NorthGateAssembly
├── Render
│   ├── Gate
│   ├── Towers
│   ├── Connectors
│   ├── Walls
│   ├── Battlements
│   ├── Stairs
│   ├── Platforms
│   └── Roads
├── Collision
│   ├── Gate
│   ├── Towers
│   ├── Connectors
│   ├── Walls
│   ├── Battlements
│   ├── Stairs
│   ├── Platforms
│   └── Roads
├── PlacementMarkers
│   ├── GateCentre
│   ├── WestWallEndpoint
│   ├── EastWallEndpoint
│   ├── MainRoadStart
│   └── GateForward
└── Debug
    ├── CollisionVisuals
    └── PlacementMarkerVisualization
```

It does not contain terrain, a player, NPCs, enemies, quests, global UI,
SaveManager, or navigation.

---

## 4. How Render Pieces Are Instantiated

At startup the assembly loads every one of the 16 render GLBs as a `PackedScene`.
This validates the complete reusable kit even though the Blender reference
assembly uses only the pieces needed for the current gate-and-road layout.

For each manifest placement record the controller:

1. Finds the stable `piece_id`.
2. Selects the matching render `PackedScene`.
3. Creates a stable `Node3D` placement root named from `placement_id`.
4. Applies the recorded local position, Y rotation, and scale.
5. Instances the imported render scene beneath `RenderAsset`.
6. Keeps the imported placeholder materials unchanged.

Nothing is merged into one mesh. Materials are not duplicated or modified at
runtime, and no random corrective scale is applied.

The manifest contains 30 placement records for the actual reference layout.
Curved roads, the intersection, neutral wall variant, inner wall variant, and
standalone battlement remain validated reusable kit resources but are not added
to the current gate reference layout merely to fill space.

---

## 5. How Collision Pieces Are Converted

Every one of the 16 collision GLBs is loaded independently from its matching
render GLB.

For each placed architecture piece the controller:

1. Loads the dedicated collision `PackedScene`.
2. Recursively finds its `MeshInstance3D` nodes.
3. Preserves each collision mesh transform relative to the imported root.
4. Calls `create_trimesh_shape()` on the collision mesh.
5. Creates a `CollisionShape3D` beneath one `StaticBody3D` for the placement.
6. Applies the exact same placement position, rotation, and scale as the render
   placement.
7. Frees the temporary source instance used for physics conversion.

The render meshes are never used as hidden collision substitutes.

The central gate collision contains three meshes only:

- West pier from X -15 to -7 metres.
- East pier from X +7 to +15 metres.
- Overhead lintel beginning at Y 12 metres.

This leaves the intended passage open from X -7 to +7 metres and from ground
level to Y 12 metres.

The simplified stair collision remains the Blender-generated ramp. Walls,
towers, gate piers, connectors, stairs, and the access platform continue using
their dedicated simplified collision GLBs.

Milestone 15B.1 makes the three placed flat road surfaces and six placed road
edging pieces visual-only by default. The existing streamed terrain collision is
the authoritative walking surface beneath the road. The curved road and
intersection collision resources remain loaded and validated as kit assets, but
they will also be skipped if they are placed while flat-road collision remains
disabled.

A second hidden collision-GLB visual copy is created only below
`Debug/CollisionVisuals`. Pressing C still toggles this inspection view. Active
physics sources are transparent red; collision GLBs deliberately disabled by the
15B.1 road policy are transparent amber. These visual copies never provide
physics.

---


## 5A. Runtime Road-Collision Bugfix (Milestone 15B.1)

Local runtime testing found that the player moved normally on terrain but became
unable to move after standing or landing on the stone road. Teleporting away
immediately restored movement, confirming that the player controller itself was
not the source of the failure.

### Confirmed geometry-level cause

The original 15B assembly converted every placed collision GLB into a concave
trimesh. That created nine road-category `StaticBody3D` placements:

- Three straight road slabs.
- Six road-edging boxes.

Inspection of the actual GLBs confirmed:

- The straight-road collision slab spans local Y `0.00 ... 0.35` metres.
- Its top triangles at Y `0.35` are wound downward.
- Its bottom triangles at Y `0.00` are wound upward.
- The slab is placed with local Y `0.02`, so its lower collision surface is at
  world Y `9.02`.
- Sampled terrain beneath the three road centres is approximately Y `9.087`,
  `8.976`, and `8.865` metres.
- The first slab therefore intersects the terrain collision, while later slabs
  remain very close to it.
- Adjacent straight modules meet with coincident vertical end faces.
- The intersection collision GLB contains two overlapping thin slabs.
- The road edging uses another thin concave box that intersects the terrain near
  the curb.

These overlapping and nearly coplanar triangle surfaces gave the player capsule
competing floor and side contacts. The solver could keep the body grounded while
also resolving it against a road bottom, side, or join triangle, which is why
horizontal movement stopped only on the road.

No duplicate manifest placement IDs were found, and the assembly's rebuild
cleanup was not creating a second copy. The problem was the collision geometry
and terrain overlap, not duplicated player or terrain systems.

### Applied fix

The reusable assembly now has two explicit settings, both locked to `false` in
the assembly scene:

```text
flat_road_collision_enabled = false
road_edging_collision_enabled = false
```

With those defaults:

- Straight road surface collision is omitted.
- Curved road surface collision is omitted when those pieces are later placed.
- Road-intersection surface collision is omitted when later placed.
- Straight road-edging collision is omitted.
- Road render pieces and placeholder materials remain unchanged.
- Terrain collision remains the walking surface.
- Gate, wall, tower, connector, stair, platform, and other raised architecture
  collision remains active.
- All 16 collision GLBs still load and validate; no asset or Blender source was
  deleted or regenerated.

The expected 15B.1 runtime counts for the current 30-placement reference
assembly are:

```text
Total active architecture collision bodies: 21
Total active architecture collision shapes: 23
Active road collision bodies: 0
Active road collision shapes: 0
Disabled road/edging placements: 9
Duplicate collision placements: 0
```

### Added debug diagnostics

The preview panel and console now report:

- Whether flat-road collision is enabled.
- Whether road-edging collision is enabled.
- Active road collision body and shape counts.
- Disabled road placement count.
- Duplicate collision-placement count.
- Every road and edging placement transform and whether physics is on or off.
- Road-render surface height compared with raycast terrain height at each placed
  straight-road centre.

Press C to compare the source collision geometry. Amber road/edging meshes are
loaded for inspection but are not physics; red meshes remain active physics
sources.

## 6. Gate and Wall Placement

The assembly root is placed at the manifest `CityGateCentre`:

```text
(0, 9, 3835)
```

All reference placements are local to that gate centre.

Important local placements include:

```text
Central gate:       (0, 0, 0)
Left tower:         (-25, 0, 0)
Right tower:        (25, 0, 0)
Left connector:     (-40, 0, 0)
Right connector:    (40, 0, 0)
```

The wall runs east–west along X. Each side uses six full 24-metre outer wall
modules and one final 20-metre effective end module. The final module uses the
manifest-recorded X scale of `0.8333333333`.

The wall intervals touch continuously:

```text
West connection: -210 m
West run to gate: -210 … -46 m
Left connector:   -46 … -34 m
Left tower:       approximately -35 … -15 m
Central gate:     -15 … +15 m
Right tower:      approximately +15 … +35 m
Right connector:  +34 … +46 m
East run:         +46 … +210 m
East connection: +210 m
```

The one-metre connector/tower overlap is intentional greybox overlap that avoids
a visible crack. Wall modules meet edge-to-edge without large gaps or heavy
overlap.

---

## 7. Alignment Validation

The assembly creates stable placement markers and compares their global
positions to the locked manifest anchors.

Calculated values shown in the debug UI are:

- Gate centre error.
- West wall endpoint error.
- East wall endpoint error.
- Road centreline error.
- Forward-direction angle error.

The target position error is 0.05 metres or less.

The expected result from the manifest placement is:

```text
Gate centre error:       0.0000 m
West endpoint error:     0.0000 m
East endpoint error:     0.0000 m
Road centreline error:   0.0000 m
Forward angle error:     0.000 degrees
```

If runtime transforms exceed the target, the preview remains usable but prints a
warning and displays the measured error instead of hiding it.

---

## 8. Road Orientation

The Blender kit records its open gate and road as facing north. After Blender to
Godot axis conversion this is negative Godot Z.

The assembly tests its transformed local `Vector3.FORWARD`, which is `(0, 0,
-1)`, against the locked north direction.

Three straight road pieces are placed at local Z values:

```text
-20 m
-44 m
-68 m
```

Each is 24 metres long, so the test road is continuous from near the gate toward
the north. Matching edging pieces sit at local X -7.4 and +7.4 metres.

The road centreline matches `MainRoadStart` at `(0, 9, 3835)`.

---

## 9. Preview Scene

The F6 preview is:

```text
res://AincradProject/scenes/world/floor_001_north_gate_preview.tscn
```

Its controller is:

```text
res://AincradProject/scripts/world/floor_001_north_gate_preview.gd
```

The preview instances three existing responsibilities separately:

```text
Floor001NorthGatePreview
├── Player                 existing player.tscn
├── SouthernRegion         permanent terrain production region
├── NorthGateAssembly      reusable architecture assembly
├── PreviewSafety
├── DebugVisualization
└── DebugUI
```

The permanent southern region is not edited. The preview assigns the existing
player as the region streamer's target, exactly as the earlier production-region
preview does.

---

## 10. Safe Preview Teleports

The preview uses local key handling and does not modify `project.godot` or the
Input Map.

```text
F1  Outside the north gate on the outgoing road
F2  Inside the city side of the gate
F3  Near the west wall endpoint
F4  Near the east wall endpoint
G   Toggle architecture placement markers
C   Toggle collision-GLB debug visuals
B   Toggle current and loaded terrain chunk boundaries
```

For every teleport the preview:

1. Keeps the same existing player instance.
2. Clears velocity.
3. Temporarily disables player physics.
4. Requests an immediate terrain-streaming update.
5. Waits until target-chunk collision is active.
6. Raycasts downward against world collision.
7. Places the player on the first terrain, road, or architecture surface hit.
8. Re-enables the existing movement controller.

Teleport and fall recovery do not modify saves, checkpoints, progression,
inventory, quests, equipment, health progression, XP, or gold.

---

## 11. Running the Preview with F6

1. Open the outer `aincrad/` folder in Godot 4.7.
2. Allow Godot to finish importing all 32 architecture GLBs.
3. Open:

```text
res://AincradProject/scenes/world/floor_001_north_gate_preview.tscn
```

4. Press F6 to run only this scene.
5. Wait for terrain and architecture initialization.
6. Confirm the debug panel reports:

```text
Manifest status: PASSED
Render assets: 16 / 16
Collision assets: 16 / 16
Failed assets: 0
```

7. Confirm all four positional errors are at or below 0.05 metres.
8. Confirm the forward direction reports negative Z.

Do not use F5 to test Milestone 15B. F5 intentionally remains the existing
normal game.

---

## 12. Testing the Open Passage

1. Press F1 to stand outside the gate.
2. Walk south toward positive Z along the road.
3. Enter between the two gate piers.
4. Walk beneath the central lintel.
5. Continue to the city side.
6. Turn around and walk north through the passage again.

The debug panel should switch `Player inside` to `YES` while the player root is
inside the 14-by-12-metre passage volume.

Failure signs include:

- Invisible collision across the opening.
- A render mesh being used as collision.
- Passage width visibly less than 14 metres.
- Player colliding with the overhead lintel at normal ground level.
- Architecture buried far below the plateau.

---

## 13. Testing Wall, Tower, Road, and Stair Collision

### Walls and towers

- Walk into each gate pier, tower, connector, and wall.
- Confirm each blocks the player.
- Press F3 and F4 to inspect both wall endpoints.
- Confirm the wall reaches the marker without a large gap.
- Confirm no duplicate collision causes unusual sticking.

### Road

- Walk along all three straight road pieces.
- Cross both road-piece boundaries.
- Confirm the road does not float far above the plateau.
- Confirm it does not disappear deeply beneath the terrain.
- Confirm the road edging does not block the centreline.

### Stairs and platform

- Move to the city-side left tower access geometry.
- Confirm the stair uses a smooth ramp-style collision.
- Confirm the player can reach the access platform.
- Confirm there is no detailed stair-step collision jitter.

The stair and platform are greybox access placeholders, not a final tower route.

---

## 14. Detecting Wrong Scale or Orientation

The import is probably at the wrong scale if:

- The passage is not approximately 14 metres wide.
- The existing player appears tiny or enormous beside the gate.
- A 24-metre wall module does not span its expected marker interval.
- The total wall does not approach 420 metres from endpoint to endpoint.

The import is probably facing the wrong direction if:

- The road runs east or west instead of north.
- The gate opening does not follow negative Z.
- Forward-direction agreement reports `NO`.
- Road edging appears across the passage rather than beside it.

Do not fix these problems by applying arbitrary corrective scale or rotation in
the preview. Correct the manifest or Blender generator and regenerate the source
assets.

---

## 15. Known Greybox Limitations

- Architecture proportions are project reconstruction, not canon-exact SAO art.
- Placeholder materials are intentionally simple.
- The wall is straight across the current plateau and has not been blended into
  a complete Starting City perimeter.
- Terrain under every long wall module has not been individually foundation-fit.
- Small terrain intersections or floating edges may require later foundation
  blocks, authored terrain grading, or adjusted wall supports.
- The current road is a short alignment test, not the final road network.
- Curved roads and the intersection are validated kit resources but are not
  placed in this reference assembly.
- Only one tower-access stair and platform are placed.
- No doors, portcullis, interiors, decorative gate mechanisms, banners, statues,
  vegetation, navigation, NPCs, or enemies exist.
- Raised architecture still uses runtime-created concave trimesh shapes from
  the dedicated simplified collision GLBs. Flat road and edging collision are
  intentionally disabled in 15B.1 so terrain remains the walking surface.
- Final production-nesting regression must still be completed locally after
  Milestone 15C; the pre-integration road and gate results are user-confirmed.

---


### Milestone 15B.1 road retest

- Confirm `Road physics: flat=OFF | edging=OFF`.
- Confirm active road bodies and shapes both report zero.
- Confirm disabled road placements report nine.
- Confirm duplicate collision placements report zero.
- Press C and confirm road/edging source meshes are amber, not red.
- Walk from terrain onto the first road module.
- Walk and sprint along all three straight modules.
- Cross both module joins in both directions.
- Jump and land near the centre of each module.
- Jump and land directly across both joins.
- Walk from the road back onto terrain at both ends.
- Walk beside both visible road edges without becoming wedged.
- Walk through the complete gate passage in both directions.
- Confirm walls, towers, gate piers, stairs, and platform still collide.
- Review the three road-surface-versus-terrain height lines and record any visual
  sinking or floating separately from physics acceptance.

## 16. Regression Requirements

After the north-gate preview is accepted, run these unchanged scenes:

```text
res://AincradProject/scenes/world/terrain_chunk_test.tscn
res://AincradProject/scenes/world/terrain_streaming_test.tscn
res://AincradProject/scenes/world/floor_001_southern_streaming_test.tscn
res://AincradProject/scenes/world/floor_001_southern_region_preview.tscn
```

Then press F5 and confirm the existing normal game still starts.

Milestone 15B does not alter these scenes, existing terrain assets, player
scripts, gameplay systems, SaveManager, `project.godot`, `.uid` files, or
anything inside `.godot/`.

---

## 17. Recommended Next Milestone

Milestone 15C remains blocked until the 15B.1 road retest confirms walking,
sprinting, jumping, landing, every road join, gate passage traversal, and
terrain-to-road transitions without sticking. After that complete local F6 and
regression acceptance passes, proceed to:

**Milestone 15C — North-Gate Production Acceptance and Provisional Region
Integration**

That milestone should:

- Record the local 15B acceptance results.
- Instance only the reusable assembly beneath
  `StaticContent/CityGateArchitecture`.
- Keep individual GLBs out of the production scene file.
- Preserve easy removal and regeneration.
- Add only accepted foundation or terrain-contact adjustments.
- Avoid full Starting City construction, final materials, actors, or navigation.


---

## 18. Milestone 15C Acceptance and Production Integration

The user confirmed the following local runtime results after the 15B.1 road fix:

- Gate renders correctly.
- Wall endpoints align.
- Player can walk through the open passage.
- Walls and towers block the player.
- The road-collision bug is fixed.
- Walking, sprinting, jumping, and landing on the road work.
- Road-piece joins can be crossed without sticking.
- Terrain streaming remains functional.

No additional result is inferred.

The permanent region now owns one reusable assembly at:

```text
SouthernRegion/StaticContent/CityGateArchitecture/NorthGateAssembly
```

The north-gate preview no longer instances another assembly beside the region.
All existing teleports, alignment information, passage detection, G marker
toggle, C collision-source toggle, B chunk-boundary toggle, road diagnostics,
and fall recovery resolve the integrated assembly instead.

The accepted road policy remains:

- Terrain collision is authoritative beneath flat road renders.
- Flat road and edging physics remain disabled.
- Raised and blocking architecture retains dedicated collision.

See `FLOOR_001_NORTH_GATE_ACCEPTANCE.md` for the provisional acceptance record.

## 19. Updated Recommended Next Milestone

After the production-nesting F6 and normal F5 regression checklist passes,
proceed to **Milestone 16A — Starting City North-Gate District Layout and
City-Side Plaza Greybox**.
