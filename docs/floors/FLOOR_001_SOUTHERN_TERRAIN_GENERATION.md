# Floor 001 Southern Terrain Generation

**Milestone:** 14A — Actual Southern Floor 1 Terrain Generation  
**Dataset ID:** `floor_001_southern_region_v1`  
**Generator version:** `14A.1`  
**Status:** Complete script and mathematical preflight delivered; local Blender 5.1.2 generation still required  
**Last updated:** 2026-07-11

---

## 1. What This Terrain Represents

This dataset is the first map-aware production terrain for the real southern
part of Floor 1. It covers the Starting City north-gate approach and the land
immediately north of the gate, including the initial beginner grasslands and
the earliest transitions toward the western woodland and eastern lowland
routes.

It is intentionally separate from:

- The existing nine-chunk terrain pipeline test.
- `terrain_chunk_test.tscn`.
- `terrain_streaming_test.tscn`.
- `floor_001_outskirts.tscn`.

Those files remain regression tests. This dataset does not replace them.

The 14A terrain contains landform only. It does not create the Starting City,
city wall, gate model, road mesh, bridge, tree, rock, grass, river, water,
enemy, NPC, navigation mesh, or final material.

---

## 2. Confirmed Anchors and Reconstruction Status

The generator follows the project's three-level reference policy.

### Confirmed official anchors

- Floor 1 uses the locked 10,000 metre diameter scale anchor.
- The Town of Beginnings belongs in the southern part of Floor 1.
- The wider progression travels north from the Starting City toward the rest of
  the floor.

### Reasonable interpretation

- The first route outside the city needs readable beginner terrain.
- The western side should begin preparing for later Horunka woodland routes.
- The eastern side should begin descending toward the later lake district.

### Project reconstruction

The exact elevations, hills, depressions, plateau radii, road curve, drainage
grades, transition masks, and height-control points are authored project
reconstruction. They are not presented as official Sword Art Online terrain
contours.

The complete policy is stored in:

```text
AincradProject/data/floors/floor_001_southern_terrain_profile.json
```

---

## 3. Locked Coordinate and Chunk Rules

```text
1 unit = 1 metre
East  = +X
West  = -X
North = -Z
South = +Z
Up    = +Y
Floor centre = (0, 0, 0)
Chunk size = 256 × 256 metres
```

The generator validates these values against both:

```text
AincradProject/data/floors/floor_001.json
AincradProject/data/floors/floor_001_southern_terrain_profile.json
```

It stops if the locked scale, axes, chunk formulas, or required 14A range no
longer agree.

---

## 4. The 7 × 7 Chunk Range

The dataset contains exactly 49 chunks.

```text
X chunk range: -3 through +3
Z chunk range: +11 through +17
Centre chunk:  floor_001_chunk_x+00_z+14
```

Global coverage is:

```text
X: -768 to +1024 metres
Z: +2816 to +4608 metres
Width:  1792 metres
Depth:  1792 metres
```

The centre chunk begins at:

```text
X = 0
Z = 3584
```

The planned city-gate terrain point `(0, 3835)` lies inside that chunk.

Stable names use the requested form:

```text
floor_001_chunk_x+00_z+14_lod0.glb
floor_001_chunk_x+00_z+14_lod1.glb
floor_001_chunk_x+00_z+14_collision.glb
```

---

## 5. Terrain Profile Data

The generator does not hide the important terrain decisions inside Python
constants. The profile JSON controls:

- Dataset and generation IDs.
- Terrain seed.
- Chunk range and coverage bounds.
- Height limits.
- Large-scale north/east regional grades.
- Beginner-field noise wavelengths and amplitudes.
- City-gate plateau centre, radii, elevation, and safe-zone limits.
- Main road corridor widths and control points.
- Western woodland transition masks and ridge strengths.
- Eastern lowland transition masks and drainage tendency.
- Broad drainage depressions.
- Authored height-control points.
- Maximum local slope limits.
- Region membership rules.
- Reconstruction confidence.

Important changes to the terrain shape should be made in the JSON first. The
Python generator then reads and validates those values.

---

## 6. Global Height System

Every terrain vertex is sampled from one deterministic function using global
Floor 1 X/Z coordinates. The function combines:

1. A broad Floor 1 landform layer.
2. Medium rolling beginner terrain.
3. Very restrained fine variation.
4. Western ridge and shelter influences.
5. Eastern lowland and drainage influences.
6. Authored height-control points.
7. A city-gate plateau override.
8. A final future-road grading override.

The terrain seed is stored in the profile. No chunk uses a separate random
state. A point at the same global X/Z coordinate therefore receives the same
height regardless of which chunk or LOD samples it.

This is the primary seam-protection rule and allows later neighbouring datasets
to continue the same function.

---

## 7. City-Gate Plateau

The planned plateau is centred at:

```text
X = 0
Z = 3835
Target elevation = 9 metres
Inner plateau radius = 210 metres
Safe-zone radius = 305 metres
Outer grading radius = 420 metres
```

Inside the plateau influence:

- Noise is reduced strongly.
- Random pits and sharp hills are overridden.
- The gate/checkpoint area remains broad and stable.
- The northern exit receives a gentle descending grade.
- The southern city-facing side remains nearly level.
- Space is reserved for the future wall, gate, checkpoint, NPCs, and road.

No wall, gate, checkpoint object, building, NPC, or road mesh is created by
14A.

---

## 8. Future Road-Corridor Grading

The main northbound route is stored as six authored control points beginning at
the gate and continuing to the northern edge of this dataset.

The corridor:

- Curves gently instead of forming a perfectly straight trench.
- Uses a 24 metre inner half-width.
- Grades outward through a 78 metre falloff half-width.
- Interpolates a controlled road-bed elevation between control points.
- Adds only a small placeholder crown.
- Overrides uncontrolled terrain layers after all other landform calculations.
- Creates terrain suitable for a later road mesh without creating that mesh.

The local preflight checks the sampled road corridor against the configured
slope limit.

---

## 9. Grasslands and Terrain Transitions

### Beginner grasslands

Terrain near the gate stays open and gentle. Rolling variation increases
gradually farther north. The profile avoids high-frequency surface noise and
mountain-sized random features so future combat spaces remain readable.

### Western transition

From approximately X `-250` toward X `-720`, the terrain gradually gains:

- More broad variation.
- Low north-northeast ridge forms.
- Sheltered depressions.
- A stronger silhouette suitable for later woodland routes.

No trees or forest props are generated.

### Eastern transition

From approximately X `+260` toward X `+900`, the terrain gradually:

- Lowers in elevation.
- Reduces noise amplitude.
- Follows a gentle east-southeast drainage tendency.
- Introduces broad depressions that suggest later drainage.

The major eastern lake, rivers, and water meshes are not generated in this
limited dataset.

---

## 10. Mesh Resolutions

Each of the 49 chunks produces three meshes:

```text
LOD0:      65 × 65 vertices; 4 metre spacing
LOD1:      33 × 33 vertices; 8 metre spacing
Collision: 17 × 17 vertices; 16 metre spacing
```

Each mesh covers exactly:

```text
256 × 256 metres
```

Expected completed Blender output:

```text
49 LOD0 GLBs
49 LOD1 GLBs
49 collision GLBs
147 GLBs total
1 manifest
1 Blender source file
1 generation log
```

---

## 11. Seam and Slope Protection

Before export, the generator validates:

- Every east/west shared edge.
- Every north/south shared edge.
- Shared four-chunk corners.
- LOD0 seams.
- LOD1 seams.
- Collision seams.
- Exact grid dimensions.
- Expected global placement.
- LOD1-to-LOD0 vertex alignment.
- Collision-to-LOD0 vertex alignment.
- Global, safe-zone, and road-corridor sampled slopes.

A failure stops generation before GLB export.

Success prints:

```text
SOUTHERN TERRAIN SEAM VALIDATION PASSED
```

The delivered non-Blender preflight sampled all 49 LOD0 grids and derived the
aligned lower resolutions. It passed:

```text
Border values compared:          9660
Shared-corner values compared:    324
Cross-resolution values compared: 67522
Placement checks:                 294
Dimension checks:                 294
Maximum sampled slope ratio:      0.098960
Maximum safe-zone slope ratio:    0.017429
Maximum road-corridor ratio:      0.033653
```

This is mathematical validation only. It is not a claim that Blender exported
the meshes in the delivery environment.

---

## 12. Blender Collections and Markers

The generator creates only this tagged hierarchy:

```text
Floor001SouthernTerrain
├── RenderLOD0
├── RenderLOD1
├── Collision
└── Markers
```

Every terrain object includes:

- `generator_id`.
- Stable `chunk_id`.
- Grid X/Z values.
- Mesh kind.
- Resolution.

Markers are added for:

- Planned city-gate centre.
- Every road control point.
- Safe-zone boundary.
- Centre test chunk.
- Northern continuation direction.

Markers are not selected for terrain GLB exports.

---

## 13. Placeholder Materials

Four simple generator-owned placeholder materials distinguish:

- Safe plateau.
- Beginner grasslands.
- Western transition.
- Eastern lowlands.

These are only inspection aids. They are not final shaders, textures, or
copyrighted Sword Art Online materials.

---

## 14. Safe Rerun Behaviour

On rerun, the script:

1. Looks for `Floor001SouthernTerrain`.
2. Stops if a collection with that name is not generator-tagged.
3. Stops if an untagged object is found inside the generator collection.
4. Removes only generator-owned objects and collections.
5. Recreates the terrain hierarchy.
6. Overwrites only the matching 14A GLB names, manifest, log, and source blend.

It does not clear the Blender scene and does not touch unrelated objects.

The existing `Floor001TerrainTest` collection and all nine-chunk regression
files are separate and are not removed.

---

## 15. Run in Blender 5.1.2

1. Preserve the complete extracted structure:

```text
aincrad/
├── project.godot
├── .godot/
├── AincradProject/
└── BlenderSource/
```

2. Open Blender 5.1.2.
3. Save unrelated work before running any generator.
4. Open the **Scripting** workspace.
5. In the Text Editor, open:

```text
aincrad/BlenderSource/floor_001/scripts/generate_floor_001_southern_terrain.py
```

6. Normally leave this unchanged:

```python
PROJECT_ROOT_OVERRIDE: str = r""
```

7. When auto-detection fails, set it to the outer `aincrad` folder, for example:

```python
PROJECT_ROOT_OVERRIDE: str = r"C:\Users\Lucas\Documents\aincrad"
```

8. Click **Run Script**.
9. On Windows, use **Window → Toggle System Console** to watch progress.
10. Do not close Blender while the 147 GLBs are exporting.

The final output must state that generation completed and seam validation
passed.

Optional command-line run after the interactive run succeeds:

```text
"C:\Program Files\Blender Foundation\Blender 5.1\blender.exe" --background --python "C:\Path\To\aincrad\BlenderSource\floor_001\scripts\generate_floor_001_southern_terrain.py"
```

---

## 16. Output Paths

```text
BlenderSource/floor_001/source/floor_001_southern_terrain.blend
BlenderSource/floor_001/logs/floor_001_southern_terrain.log
AincradProject/assets/environments/floor_001/terrain/southern_region/
AincradProject/assets/environments/floor_001/terrain/southern_region/floor_001_southern_manifest.json
```

The delivered manifest currently has status:

```text
preflight_validated_blender_export_pending
```

The local Blender run overwrites it with:

```text
complete_blender_exports_generated
```

only after the real exports exist.

---

## 17. Inspect the Terrain in Blender

After generation:

1. Expand `Floor001SouthernTerrain` in the Outliner.
2. Confirm 49 objects in each mesh collection.
3. Select one `RenderLOD0` object.
4. Press `N` and inspect **Item → Dimensions**.
5. Confirm horizontal dimensions are 256 m by 256 m.
6. Confirm rotation is zero and scale is one.
7. Switch to top view and wireframe.
8. Inspect several shared borders across the centre, western, and eastern areas.
9. Toggle `RenderLOD0`, `RenderLOD1`, and `Collision` to compare footprints.
10. Inspect the gate, road, safe-zone, centre-chunk, and north markers.
11. Confirm the plateau is broad and the road corridor is visible only as
    terrain grading, not as a separate road mesh.

The console validation is authoritative; the visual inspection is an
additional sanity check.

---

## 18. Connection to Future Neighbouring Regions

The generator uses global coordinates and a deterministic seed rather than
chunk-local noise. Future neighbouring chunks can call the same terrain
function and profile-compatible masks at the same border coordinates.

Later datasets should:

- Preserve the global height function or explicitly version any change.
- Share road control points at dataset boundaries.
- Continue western/eastern transition masks instead of restarting them.
- Validate both datasets together before replacing a boundary.
- Keep region identity separate from chunk identity.

The 14A manifest records primary and overlap region IDs so later Godot loading
can distinguish the city-gate outskirts from early Rata, Horunka, eastern-lake,
and Starting City overlaps.

---

## 19. Complete Local Testing Checklist

### Blender generation

- [ ] Blender 5.1.2 opens successfully.
- [ ] The script locates both JSON data files.
- [ ] The console reports X `-3…+3`, Z `+11…+17`.
- [ ] Exactly 49 stable chunk IDs are generated.
- [ ] `Floor001SouthernTerrain` is created.
- [ ] `RenderLOD0` contains 49 objects.
- [ ] `RenderLOD1` contains 49 objects.
- [ ] `Collision` contains 49 objects.
- [ ] Marker objects are present and remain outside exports.
- [ ] Every mesh measures exactly 256 × 256 m horizontally.
- [ ] The gate plateau is broad, stable, and free of pits.
- [ ] The northern exit descends gently.
- [ ] The road corridor curves and remains reasonably level.
- [ ] Beginner grasslands remain readable near the city.
- [ ] Terrain variation increases gradually northward.
- [ ] Western terrain develops low ridges without trees.
- [ ] Eastern terrain lowers without creating a lake or water.
- [ ] The console prints `SOUTHERN TERRAIN SEAM VALIDATION PASSED`.

### Files

- [ ] Exactly 147 matching GLB files exist.
- [ ] No unexpected GLBs exist in `southern_region/`.
- [ ] The manifest parses as valid JSON.
- [ ] Manifest status is `complete_blender_exports_generated`.
- [ ] Manifest reports 49 chunk records.
- [ ] Manifest actual GLB count is 147.
- [ ] Every manifest path points to an existing GLB.
- [ ] `floor_001_southern_terrain.blend` exists.
- [ ] The generation log reports Blender execution and exports as true.

### Regression safety

- [ ] Existing `terrain/test_chunks/` files are unchanged.
- [ ] Existing test manifest is unchanged.
- [ ] Existing test Blender generator is unchanged.
- [ ] Existing test Blender source is unchanged.
- [ ] No file in `.godot/` was edited or removed manually.
- [ ] No existing `.uid` file was edited or removed manually.
- [ ] No gameplay, player, UI, SaveManager, project setting, or existing scene changed.

### Godot import sanity check

- [ ] Open the project in Godot 4.7 after Blender generation.
- [ ] Allow Godot to import the new GLBs normally.
- [ ] Confirm there are no missing-resource import errors.
- [ ] Do not integrate the 49 chunks into normal F5 gameplay during 14A.
- [ ] Run the existing 13B and 13C terrain tests to confirm regression behavior.
- [ ] Run F5 and confirm normal gameplay remains unchanged.

---

## 20. Recommended Next Milestone

After the complete local checklist passes, proceed to:

```text
Milestone 14B — Southern Terrain Godot Import and 7 × 7 Streaming Validation
```

14B should consume the completed 49-chunk manifest in a separate F6 test scene,
verify Godot import scale and axes, stream the wider dataset with the existing
chunk-streamer architecture, and keep normal gameplay unchanged.
