# Floor 1 Main Northbound Road Greybox Preview

**Milestone:** 16A — Main Northbound Road Greybox and Spline Placement  
**Engine target:** Godot 4.7  
**Status:** Implementation and static validation complete; local F6 traversal required  
**Normal F5 world changed:** No  
**Road ID:** `road_floor_001_starting_city_northbound`

---

## 1. Purpose

Milestone 16A creates the first reusable permanent road route north of the
Starting City gate. It is still evaluated in a separate F6 preview and is not
part of the normal F5 world.

The route reuses the existing Milestone 15A road GLBs. It does not create a
second architecture kit, duplicate road GLBs, modify terrain, or add road
collision over the terrain.

Important paths:

```text
res://AincradProject/data/floors/floor_001_main_road.json
res://AincradProject/world/floors/floor_001/roads/floor_001_main_road_assembly.tscn
res://AincradProject/scripts/world/floor_001_main_road_assembly.gd
res://AincradProject/scenes/world/floor_001_main_road_preview.tscn
res://AincradProject/scripts/world/floor_001_main_road_preview.gd
```

## 2. Road Data

The assembly loads:

```text
res://AincradProject/data/floors/floor_001_main_road.json
```

The JSON contains:

- Stable road, floor, and region IDs.
- Road width and route type.
- Ordered production control points.
- Editable Bezier handle offsets.
- Exact architecture-manifest path.
- Actual stable road-piece IDs from that manifest.
- Straight and curve geometry measurements.
- Gate-transition policy.
- Terrain-conformance and collision policies.
- Sparse visual-edging policy.
- Reconstruction confidence and dataset version.

The JSON is the route-specific authority. The architecture manifest remains the
asset authority.

## 3. Approved Control Points

The route uses the five points shared by the permanent region JSON and its
stable Marker3D nodes:

| Stable ID | Marker | Position |
|---|---|---:|
| `road_gate` | `MainRoadStart` | `(0, 9, 3835)` |
| `road_01` | `MainRoadControl01` | `(12, 8.3, 3665)` |
| `road_02` | `MainRoadControl02` | `(-28, 8.8, 3480)` |
| `road_03` | `MainRoadControl03` | `(34, 10.2, 3280)` |
| `road_north_continuation` | `MainRoadNorthernExit` | `(20, 14, 2816)` |

The terrain profile also contains an internal grading point named `road_04`.
That point is not present in the approved production-region marker set, so it is
not promoted to a Milestone 16A route control point. This prevents a terrain-only
helper point from silently changing permanent world data.

## 4. Spline Generation

`Floor001MainRoadAssembly` creates an editable `Curve3D` beneath `RoadPath`.
Each JSON control point supplies:

- Its approved position.
- An incoming Bezier handle offset.
- An outgoing Bezier handle offset.

The first handle keeps the road almost straight through the accepted 80-metre
gate approach before the route gradually moves toward `road_01`. Later handles
smooth the west/east changes through the beginner grasslands.

Static mathematical preflight gives an approximate route length of **1,036.26
metres**. The exact baked length is shown by the runtime debug panel.

The route:

- Begins exactly at `MainRoadStart`.
- Ends exactly at `MainRoadNorthernExit`.
- Progresses generally north along negative Z.
- Contains no authored loop or branch.

## 5. Modular Piece Selection

The script loads these existing render assets once:

```text
floor_001_arch_stone_road_straight
floor_001_arch_stone_road_curved_left
floor_001_arch_stone_road_curved_right
floor_001_arch_stone_road_intersection
floor_001_arch_road_edging_straight
```

The intersection resource is validated but is not placed because no real branch
exists in this route.

Placement works forward from the gate-transition distance:

1. Test a 24-metre straight chord.
2. Compare the spline heading near the start and end.
3. Use a left or right 30-degree curve module only when the heading change
   exceeds the configured nine-degree threshold.
4. Otherwise place a straight module.
5. Trim only the final straight module longitudinally when required to terminate
   at the northern marker.

Static preflight predicts:

```text
Total road placements: 41
Straight pieces:       38
Left curves:            1
Right curves:           2
```

The runtime panel reports the actual Godot `Curve3D` result.

Every placement receives a predictable ID such as:

```text
road_floor_001_starting_city_northbound_segment_001
```

## 6. Placement Spacing and Joins

Straight modules use their actual 24-metre manifest length. Curved modules use
the 15.529-metre chord produced by the existing 30-metre-radius, 30-degree kit
piece.

For each placement, the script searches forward along the baked spline until the
horizontal chord matches the selected piece. This keeps placement endpoints
continuous without repeatedly guessing fixed world transforms.

Curve roots align their actual local start-to-end chord with the matching spline
chord. Straight roots are centred between their start and end points.

The assembly limits itself to 128 placements as a safety check. The expected
route requires only about 41.

## 7. Terrain Height Conformance

The route uses the approved Y values stored in its control points. The Bezier
curve interpolates those heights between markers.

Road render pieces receive a configurable **0.05-metre visual offset**. The
imported road mesh origin is at its lower surface, so this small offset helps
prevent flickering while remaining close to the graded terrain corridor.

At the accepted gate-road edge, the existing render base is Y `9.02` while the
terrain spline has already started its gentle descent. The first 48 metres of
new placement therefore use a smooth height blend from Y `9.02` to the normal
spline-plus-offset height. Straight pieces are pitched along that visual chord,
preventing an abrupt greybox step without changing terrain or adding collision.

This milestone does not:

- Modify terrain vertices.
- Regenerate the terrain.
- Add collision to hide visual misalignment.
- Raycast and rebuild every segment every frame.

Small greybox sinking or floating must be documented during local review and
fixed through later visual placement refinement, not by restoring overlapping
road collision.

## 8. Collision Policy

The accepted Milestone 15B.1 policy is preserved:

```text
terrain_authoritative_flat_road_visual_only
```

Therefore:

- Straight road surfaces create no physics.
- Curved road surfaces create no physics.
- Ground-level intersections create no physics.
- Road edging creates no physics.
- Imported road collision GLBs are not loaded by this assembly.
- Streamed terrain remains the walking surface.

This prevents the player capsule from being wedged between nearly coplanar
terrain and concave road triangles.

Raised bridges, stairs, or platforms added in future milestones require separate
non-overlapping authored collision.

## 9. Gate-Road Transition

The provisionally accepted north-gate assembly already contains three straight
road sections centred 20, 44, and 68 metres north of `CityGateCentre`. Together
they cover the first 80 metres of the route.

The new `Curve3D` still begins at `MainRoadStart`, preserving route-data
continuity. Modular 16A placement begins at distance 80 metres, at the north edge
of the accepted gate-road strip.

This means the preview contains:

- One integrated north-gate assembly.
- Its accepted three-piece gate approach.
- One separate 16A main-road assembly beginning after that approach.

No duplicate road module is placed inside the gate.

## 10. Road Edging

Road edging is visual-only and disabled by default.

When enabled with **E**, the assembly shows a sparse pair on every third straight
segment. Curves and the accepted gate-transition area receive no new edging.
This keeps the centre walkway clear and avoids creating a continuous obstruction
or unnecessary node count.

Edging visibility does not change physics.

## 11. Running the Preview

Open:

```text
res://AincradProject/scenes/world/floor_001_main_road_preview.tscn
```

Press **F6**.

Controls:

```text
F1  MainRoadStart / gate-road start
F2  MainRoadControl01
F3  MainRoadControl02
F4  MainRoadControl03
N   MainRoadNorthernExit
R   Toggle spline visualization
P   Toggle placement markers and directions
E   Toggle sparse visual road edging
B   Toggle current and loaded terrain chunk boundaries
```

`N` is used instead of F5 so the preview does not conflict with the editor's
normal project-run shortcut.

Each teleport:

- Keeps the same player instance.
- Clears velocity.
- Moves the player above the target terrain chunk.
- Forces an immediate terrain-streaming update.
- Waits for collision.
- Raycasts onto authoritative terrain.
- Does not change save data or progression.

## 12. Complete Local Test Route

1. Run the preview with F6.
2. Confirm road status reports `READY` and failed assets report zero.
3. Press F1 and walk through the north gate.
4. Cross the transition from the accepted gate road onto the new route.
5. Walk and sprint north to `MainRoadControl01`.
6. Continue through the westward change near `MainRoadControl02`.
7. Continue through the eastward change near `MainRoadControl03`.
8. Cross several terrain chunk boundaries.
9. Leave the visible road onto terrain and re-enter it.
10. Jump and land on straight and curved modules.
11. Press N and inspect the northern continuation edge.
12. Return through the route or use F1.

Check for:

- Large visible gaps.
- Heavy overlap.
- Incorrect 180-degree rotations.
- Curves bending to the wrong side.
- Floating or deeply buried modules.
- Duplicate road inside the gate.
- Road edging intruding into the centre.
- Any loss of movement while touching the road.

## 13. Known Greybox Limitations

- The road uses simple placeholder stone modules.
- Curved modules have a fixed 30-degree greybox shape and only approximate the
  authored spline between their endpoints.
- Pieces do not deform continuously to the terrain.
- The road has no final paving textures, decals, dirt, wear, drainage, or
  vegetation blending.
- Sparse edging is a debug option, not an approved final roadside design.
- No branches, intersections, bridges, culverts, signs, actors, enemies, or
  navigation are included.
- The road is not integrated into the permanent production region or F5 world in
  this milestone.

## 14. Recommended Next Milestone

After the complete local traversal and regression checklist passes, proceed to:

**Milestone 16B — Main Northbound Road Acceptance and Provisional Southern
Region Integration**

That milestone should record runtime results and instance the reusable road once
beneath `Floor001SouthernRegion/StaticContent/Roads`, without copying individual
GLBs or changing normal F5 gameplay.
