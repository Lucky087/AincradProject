# Floor 1 Starting City North-Gate Architecture Generation

**Milestone:** 15A — Starting City North-Gate Architecture Greybox  
**Engine target:** Godot 4.7  
**Generator target:** Blender 5.1.2  
**Scale:** 1 Blender unit = 1 metre  
**Status in this package:** Generator and mathematical preflight complete; local Blender export required

---

## 1. Purpose

This milestone creates a reusable greybox architecture kit for the Floor 1
Starting City north-gate area. It is an asset-generation milestone, not a Godot
production-placement milestone.

The generator does not alter:

- Southern terrain meshes.
- The permanent production region scene.
- The normal F5 world.
- Existing terrain tests.
- Player, SaveManager, gameplay, UI, `.uid`, or `.godot/` files.

The kit is intentionally simple. It proves dimensions, reusable module origins,
open passage clearance, marker alignment, separate collision exports, and a safe
Blender rerun workflow before final architecture art is attempted.

---

## 2. Source Files and Locked Anchors

The generator reads and cross-validates these three existing project sources:

```text
AincradProject/data/floors/floor_001_southern_region.json
AincradProject/data/floors/floor_001_southern_terrain_profile.json
AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
```

The following production markers are treated as locked placement anchors:

| Marker | Stable ID | Godot position |
|---|---|---:|
| `CityGateCentre` | `landmark_city_gate_centre` | `(0, 9, 3835)` |
| `CityWallWestConnection` | `landmark_city_wall_west_connection` | `(-210, 9, 3835)` |
| `CityWallEastConnection` | `landmark_city_wall_east_connection` | `(210, 9, 3835)` |
| `MainRoadStart` | `road_gate` | `(0, 9, 3835)` |

The gate centre and road start coincide. The wall runs east–west along X. The
open gate passage and outgoing road point north along negative Godot Z.

Blender uses this equivalent orientation:

```text
Blender +X -> Godot +X
Blender -Y -> Godot +Z
Blender +Z -> Godot +Y
```

Therefore, northbound architecture points along Blender +Y.

---

## 3. Files Created by Milestone 15A

### Generator and preflight log

```text
BlenderSource/floor_001/scripts/generate_floor_001_north_gate_architecture.py
BlenderSource/floor_001/logs/floor_001_north_gate_architecture.log
```

### Runtime export root and manifest

```text
AincradProject/assets/environments/floor_001/architecture/north_gate/
└── floor_001_north_gate_architecture_manifest.json
```

A successful local Blender run also creates:

```text
BlenderSource/floor_001/source/floor_001_north_gate_architecture.blend

AincradProject/assets/environments/floor_001/architecture/north_gate/render/
AincradProject/assets/environments/floor_001/architecture/north_gate/collision/
```

The two export folders will contain 16 render GLBs and 16 simplified collision
GLBs, for 32 GLBs total.

---

## 4. Modular Kit Contents

The manifest registers these stable kit pieces:

1. `floor_001_arch_city_wall_straight`
2. `floor_001_arch_city_wall_straight_outer`
3. `floor_001_arch_city_wall_straight_inner`
4. `floor_001_arch_north_gate_central_structure`
5. `floor_001_arch_gate_tower_left`
6. `floor_001_arch_gate_tower_right`
7. `floor_001_arch_wall_to_tower_connector_left`
8. `floor_001_arch_wall_to_tower_connector_right`
9. `floor_001_arch_battlement_section`
10. `floor_001_arch_access_stairs`
11. `floor_001_arch_access_platform`
12. `floor_001_arch_stone_road_straight`
13. `floor_001_arch_stone_road_curved_left`
14. `floor_001_arch_stone_road_curved_right`
15. `floor_001_arch_stone_road_intersection`
16. `floor_001_arch_road_edging_straight`

Every piece has a separate render and collision path. Stable IDs and filenames
use lowercase snake case and begin with `floor_001_arch_`.

---

## 5. Gate and Wall Dimensions

The greybox uses these initial proportions:

```text
Open passage width:       14 m
Open passage height:      12 m
Central structure:        30 × 16 × 24 m
Tower centres:            X = -25 m and X = +25 m
Each tower:               18 × 18 × 30 m
Wall module length:       24 m
Wall connection span:     -210 m to +210 m
Road width:               14 m
Straight road module:     24 m long
```

These are project-reconstruction dimensions intended for iteration. They are
not described as exact Sword Art Online canon architecture.

The reference assembly uses six full 24-metre wall modules per side plus one
20-metre scaled end module. The final west and east wall ends therefore meet the
locked connection markers with zero mathematical alignment error.

---

## 6. Open Gate Passage

The central gate collision is not one solid box. It is built from:

- A west pier.
- An east pier.
- An overhead lintel.

This preserves the 14-metre-wide and 12-metre-high opening in both render and
collision exports. No gate door, portcullis, invisible wall, or blocked passage
is created in this milestone.

---

## 7. Render and Collision Separation

Render GLBs contain the visible greybox detail, including:

- Battlement blocks.
- Wall buttresses.
- Inner access ledges.
- Stair steps.
- Platform rails.
- Road joint guides.

Collision GLBs are deliberately simpler:

- Walls and towers use basic solid boxes.
- The gate keeps its open passage using three simplified solids.
- Stairs use a walkable ramp prism instead of ten individual steps.
- Battlements use one parapet collision box.
- Curved roads use fewer arc segments.
- Road pieces remain thin collision slabs.

Future Godot placement must use the dedicated collision GLBs. Render GLBs must
not be used as hidden collision substitutes.

---

## 8. Blender Collection Layout

A successful run creates only this generator-owned hierarchy:

```text
Floor001NorthGateArchitecture
├── KitRender
├── KitCollision
├── ReferenceAssembly
└── Markers
```

`KitRender` and `KitCollision` contain local-origin reusable modules.

`ReferenceAssembly` contains a Blender-only placement proof at the real global
gate coordinates. It is not exported as a monolithic runtime GLB. This avoids
locking the production scene to one giant asset while still proving the module
layout against the stable markers.

`Markers` contains Blender empties for the four locked Godot anchors.

---

## 9. Safe Rerun Behaviour

The generator owns only the collection named:

```text
Floor001NorthGateArchitecture
```

It also tags every generated collection, object, and material with:

```text
generator_id = aincrad_floor_001_north_gate_architecture_v1
```

On rerun, it deletes only that tagged collection hierarchy. It stops instead of
deleting anything when:

- A conflicting root collection exists without the correct generator tag.
- A generated collection contains an untagged object.
- A required material name exists but is not owned by this generator.
- Unexpected GLBs exist in the generator-owned render or collision folder.

It never clears the Blender scene and never deletes unrelated objects.

---

## 10. How to Run the Generator in Blender 5.1.2

1. Extract the project while keeping the outer `aincrad/` folder.
2. Open Blender 5.1.2.
3. Choose the **Scripting** workspace.
4. Open this file:

```text
BlenderSource/floor_001/scripts/generate_floor_001_north_gate_architecture.py
```

5. Normally leave this line empty:

```python
PROJECT_ROOT_OVERRIDE: str = r""
```

6. When automatic path detection fails, set it to the outer folder containing
   `project.godot`, `AincradProject/`, and `BlenderSource/`.

Windows example:

```python
PROJECT_ROOT_OVERRIDE: str = r"C:\Users\YourName\Documents\aincrad"
```

7. Choose **Window → Toggle System Console** so progress and errors are visible.
8. Press **Run Script** in Blender's text editor.
9. Wait until the console prints:

```text
NORTH-GATE ARCHITECTURE PREFLIGHT PASSED
NORTH-GATE ARCHITECTURE EXPORTS COMPLETE
```

10. Confirm the manifest status changes to:

```text
complete_blender_exports_generated
```

---

## 11. Expected Local Outputs

After a successful Blender run, verify:

```text
BlenderSource/floor_001/source/floor_001_north_gate_architecture.blend
```

And exactly 32 GLBs:

```text
16 files in architecture/north_gate/render/
16 files in architecture/north_gate/collision/
```

The manifest should report:

```text
blender.executed = true
blender.exports_generated = true
exports.actual_glb_count = 32
generation_status = complete_blender_exports_generated
```

---

## 12. How to Inspect the Blender Source

In the Outliner:

1. Hide `KitCollision` and inspect the render kit at the local origin.
2. Hide `KitRender` and inspect simplified collision modules.
3. Enable `ReferenceAssembly` to inspect the complete gate and short outgoing
   road at the accepted global position.
4. Confirm the west wall reaches `marker_CityWallWestConnection`.
5. Confirm the east wall reaches `marker_CityWallEastConnection`.
6. Confirm the gate centre overlaps `marker_CityGateCentre`.
7. Confirm the road centreline starts at `marker_MainRoadStart`.
8. Inspect the gate opening from the north and south.
9. Confirm the road exits in the northbound direction.

Do not move the stable marker empties to make the architecture appear aligned.
Fix generator dimensions or placement data instead.

---

## 13. How the Kit Will Later Enter Godot

Milestone 15A does not modify the permanent production scene.

A later Godot placement milestone should:

- Load the manifest.
- Place gate, towers, connectors, wall modules, battlements, and access pieces
  beneath:

```text
StaticContent/CityGateArchitecture
```

- Place road and edging modules beneath:

```text
StaticContent/Roads
```

- Use `CityGateCentre` as the assembly origin.
- Verify the wall endpoints against `CityWallWestConnection` and
  `CityWallEastConnection`.
- Align the outgoing road with `MainRoadStart` and the existing road-control
  markers.
- Build physics only from the collision GLBs.
- Preserve the player-independent production-region architecture.
- Keep normal F5 startup unchanged until a later integration milestone.

---

## 14. What Is Not Included

This milestone does not create:

- The full Starting City.
- Houses or interiors.
- Final wall or gate art.
- Gate doors or mechanisms.
- Vegetation, rocks, water, rivers, or grass.
- NPCs, enemies, quests, or interactions.
- Navigation meshes.
- Final textures, shaders, or copyrighted SAO materials.
- Terrain changes.
- Production-scene placement.
- Main-game integration.

---

## 15. Current Execution Status

Blender was not installed in the delivery environment.

Completed here:

- Python syntax validation.
- JSON and scene marker parsing.
- Cross-source stable marker validation.
- One-metre scale and axis validation.
- Gate/road alignment validation.
- Exact west/east wall endpoint calculation.
- Unique piece ID and export-path validation.
- Pending manifest generation.
- Preflight log generation.

Not created here:

- Real GLB files.
- The editable Blender `.blend` source.

No fake GLBs and no empty fake `.blend` file were created.

---

## 16. Local Blender Testing Checklist

- [ ] Blender 5.1.2 opens the generator without syntax errors.
- [ ] The script finds the preserved outer `aincrad/` folder.
- [ ] All three source files parse.
- [ ] The console reports 117 or more successful preflight checks.
- [ ] The gate and road alignment errors are zero.
- [ ] Both wall connection errors are zero.
- [ ] `Floor001NorthGateArchitecture` is created.
- [ ] `KitRender` contains 16 reusable piece roots.
- [ ] `KitCollision` contains 16 reusable piece roots.
- [ ] `ReferenceAssembly` aligns with all four marker empties.
- [ ] The gate passage remains visibly open.
- [ ] The collision gate passage remains open.
- [ ] Tower, wall, battlement, stair, platform, road, curve, intersection, and
      edging pieces are present.
- [ ] The road points north from the gate.
- [ ] Exactly 16 render GLBs are exported.
- [ ] Exactly 16 collision GLBs are exported.
- [ ] No unexpected GLBs exist in either export directory.
- [ ] `floor_001_north_gate_architecture.blend` is saved.
- [ ] The manifest reports complete Blender exports and 32 actual GLBs.
- [ ] The log reports Blender execution and exports as true.
- [ ] Rerunning the script replaces only generator-owned content.
- [ ] Unrelated Blender objects remain untouched.

---

## 17. Godot Import Sanity Checklist After Local Export

- [ ] Open Godot 4.7 and allow all 32 GLBs to import.
- [ ] Confirm no GLB imports at an incorrect scale.
- [ ] Confirm road forward points toward negative Godot Z.
- [ ] Confirm each module origin is stable and predictable.
- [ ] Confirm render and collision exports remain separate.
- [ ] Do not place the assets into the permanent scene during Milestone 15A.
- [ ] Run all existing terrain regression scenes unchanged.
- [ ] Press F5 and confirm normal gameplay remains unchanged.

---

## 18. Recommended Next Milestone

Proceed to:

**Milestone 15B — North-Gate Godot Import and Production Placement Preview**

That milestone should import the completed 32 GLBs, create a data-driven
placement scene or controller beneath the existing permanent content containers,
validate collision and open-passage traversal in an isolated F6 preview, and
keep normal F5 startup unchanged.
