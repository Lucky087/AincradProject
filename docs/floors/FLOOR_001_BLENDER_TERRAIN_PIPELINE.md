# Floor 001 Blender Terrain-Chunk Pipeline

**Milestone:** 13A — Blender Terrain-Chunk Pipeline Test  
**Floor:** `floor_001`  
**Status:** Script prepared; Blender generation must be run locally  
**Last updated:** 2026-07-11

---

## 1. Purpose

This milestone proves the production pipeline for seamless Floor 1 terrain chunks before the complete ten-kilometre floor is generated.

It does **not** create the full Floor 1 terrain and does **not** add streaming to Godot.

The test generator creates only nine terrain chunks in a three-by-three grid near the planned Starting City gate sector. It validates scale, shared borders, mesh resolutions, GLB export, stable naming, collision meshes, and manifest output.

---

## 2. Folder Placement

The uploaded archive keeps an outer `aincrad/` folder and an inner `AincradProject/` content folder.

The Blender source folder belongs beside `AincradProject`, not inside it:

```text
aincrad/
├── project.godot
├── AincradProject/
│   ├── assets/
│   ├── data/
│   ├── docs/
│   └── ...
└── BlenderSource/
    └── floor_001/
        ├── scripts/
        │   └── generate_floor_001_terrain_test.py
        ├── source/
        └── logs/
```

Generated Godot-facing files appear here after the script runs:

```text
aincrad/
└── AincradProject/
    └── assets/
        └── environments/
            └── floor_001/
                └── terrain/
                    └── test_chunks/
```

### Why BlenderSource is outside AincradProject

Godot scans and imports files beneath the project resource tree.

Large `.blend` source files are working files, not runtime game assets. Keeping them outside `AincradProject` prevents Godot from repeatedly importing large Blender working scenes and keeps source-generation files separate from exported runtime assets.

Only the generated `.glb` files and `terrain_test_manifest.json` belong in the Godot asset folder.

---

## 3. Locked Scale and Coordinates

The generator reads:

```text
AincradProject/data/floors/floor_001.json
```

It validates these locked rules before generating anything:

```text
1 Blender unit = 1 metre
1 Godot unit = 1 metre
Outdoor chunk size = 256 × 256 metres

Floor centre = (0, 0, 0)

East  = +X
West  = -X
North = -Z
South = +Z
Up    = +Y in Godot
```

Blender uses Z as its vertical axis. The generator therefore uses this conversion:

```text
Blender +X  → Godot +X
Blender -Y  → Godot +Z
Blender +Z  → Godot +Y
```

The glTF exporter handles the final axis conversion.

---

## 4. Selected Nine Test Chunks

The planned reference point for the existing city-gate outskirts is:

```text
X = 0
Z = 3835
```

The locked chunk formula is:

```text
cx = floor(x / 256)
cz = floor(z / 256)
```

Calculation:

```text
cx = floor(0 / 256)    = 0
cz = floor(3835 / 256) = 14
```

The centre test chunk is therefore:

```text
floor_001_chunk_x+00_z+14
```

The three-by-three test group is:

```text
floor_001_chunk_x-01_z+13
floor_001_chunk_x+00_z+13
floor_001_chunk_x+01_z+13

floor_001_chunk_x-01_z+14
floor_001_chunk_x+00_z+14
floor_001_chunk_x+01_z+14

floor_001_chunk_x-01_z+15
floor_001_chunk_x+00_z+15
floor_001_chunk_x+01_z+15
```

Together, they cover:

```text
X = -256 to 512 metres
Z = 3328 to 4096 metres
```

The outskirts reference position lies five metres north of the border between Z chunks `+14` and `+15`.

This grid is a pipeline test. It is not final terrain design for the complete South Gate Outskirts region.

---

## 5. Generated Collections

The script creates one owned root collection:

```text
Floor001TerrainTest
├── RenderLOD0
├── RenderLOD1
├── Collision
└── Markers
```

The script adds an internal generator tag to the root collection and generated objects.

On rerun, it deletes only the previously generated tagged collection.

It does **not**:

- Select all objects.
- Clear the Blender scene.
- Delete unrelated collections.
- Delete an untagged collection that happens to use the same name.

If an unrelated collection named `Floor001TerrainTest` already exists, the script stops with an error instead of deleting it.

---

## 6. Terrain Shape

The terrain is deterministic and intentionally gentle near the city gate.

It uses:

- Broad low-frequency value noise.
- Small medium-scale variation.
- Very limited fine variation.
- A broad gate-area flattening influence.
- A mild regional grade.

It does not generate sharp random mountains.

### Why borders match

The height function receives **global Floor 1 coordinates**:

```text
height = terrain_height(world_x, world_z)
```

A border vertex on one chunk and the matching border vertex on its neighbour use the exact same `world_x` and `world_z`.

The function does not use a per-chunk random generator or per-chunk noise offset.

Therefore, shared border samples return the same height.

Example:

```text
East border of chunk X +00:
world_x = 256

West border of chunk X +01:
world_x = 256
```

Both sides call the same deterministic function with the same coordinates.

---

## 7. Mesh Resolutions

Each chunk covers exactly `256 × 256 metres` at every resolution.

| Mesh | Grid | Vertices | Triangles | Purpose |
|---|---:|---:|---:|---|
| LOD0 | 65 × 65 | 4,225 | 8,192 | Nearest visual terrain |
| LOD1 | 33 × 33 | 1,089 | 2,048 | Lower-detail visual terrain |
| Collision | 17 × 17 | 289 | 512 | Simplified future collision |

The resolutions divide 256 metres evenly:

```text
LOD0 spacing:      4 m
LOD1 spacing:      8 m
Collision spacing: 16 m
```

Each mesh uses the same global terrain-height function.

The collision mesh is exported separately. This milestone does not yet import it into a Godot collision system.

---

## 8. Local Origins and Manifest Placement

Every exported GLB uses the same local-origin rule:

```text
Local origin = the chunk's minimum X / minimum Z corner
```

A local chunk spans:

```text
Local X = 0 to 256
Local Z = 0 to 256 in Godot
```

The Blender scene displays chunks at their global preview positions. During export, the script temporarily moves only the selected object to the origin, exports it, then restores its Blender preview location.

Godot can later place each GLB using the manifest's `global_position`.

Example:

```json
{
  "chunk_id": "floor_001_chunk_x+00_z+14",
  "global_position": [0.0, 0.0, 3584.0]
}
```

---

## 9. Global UV Coordinates

UV values are calculated from global Floor 1 coordinates instead of restarting at zero for every chunk:

```text
U = world_x / 32
V = world_z / 32
```

This gives neighbouring chunks matching UV values along shared edges.

The current material is only a simple green-brown placeholder. The global UV layout prepares the chunks for later continuous terrain textures.

---

## 10. Export Names

Each of the nine chunks exports three files.

Example centre chunk:

```text
floor_001_chunk_x+00_z+14_lod0.glb
floor_001_chunk_x+00_z+14_lod1.glb
floor_001_chunk_x+00_z+14_collision.glb
```

After a successful run, the output directory contains:

```text
27 GLB files
1 terrain_test_manifest.json
```

The Blender working file is saved as:

```text
BlenderSource/floor_001/source/floor_001_terrain_test.blend
```

A text log is written to:

```text
BlenderSource/floor_001/logs/floor_001_terrain_test.log
```

---

## 11. Manifest Contents

The generated file is:

```text
AincradProject/assets/environments/floor_001/terrain/test_chunks/terrain_test_manifest.json
```

It includes:

- Floor ID.
- Generation version.
- Deterministic terrain seed.
- Chunk size.
- Axis rules.
- Centre test chunk.
- All nine chunk IDs.
- Grid coordinates.
- Global placement positions.
- Bounds.
- LOD0 path.
- LOD1 path.
- Collision path.
- Vertex counts.
- Triangle counts.
- Seam-validation result.

The script serializes the manifest with Python's JSON library and immediately parses the exact generated text again before writing it.

---

## 12. Before Running Blender

Install Blender 4.x.

Then confirm the extracted structure resembles:

```text
C:\YourFolder\aincrad\
├── project.godot
├── AincradProject\
└── BlenderSource\
```

Do not move `BlenderSource` into `AincradProject`.

---

## 13. Open the Script in Blender

1. Open Blender.
2. A new empty scene is acceptable. Existing unrelated objects are also safe.
3. Click the **Scripting** workspace at the top.
4. In the Text Editor, click **Open**.
5. Browse to:

```text
aincrad/BlenderSource/floor_001/scripts/
```

6. Open:

```text
generate_floor_001_terrain_test.py
```

---

## 14. Set or Confirm the Project Root

Near the top of the script, find:

```python
PROJECT_ROOT_OVERRIDE: str = r""
```

The script normally auto-detects the outer `aincrad` folder from its own location.

When auto-detection does not work, enter the full path to the outer folder:

```python
PROJECT_ROOT_OVERRIDE: str = r"C:\Users\Lucas\Documents\aincrad"
```

The selected folder must contain:

```text
project.godot
AincradProject/
BlenderSource/
```

Do not set it to the `AincradProject` assets folder.

The script can also recognize a direct `AincradProject` path, but the outer folder is recommended because the `.blend` source belongs beside it.

---

## 15. Run the Script

1. Save unrelated Blender work first.
2. Keep the script visible in the Text Editor.
3. Click **Run Script**.
4. Open **Window → Toggle System Console** on Windows to watch detailed output.
5. Wait for generation and GLB export to finish.

The final console section should include:

```text
TERRAIN TEST GENERATION COMPLETE
SEAM VALIDATION PASSED
```

The script prints:

- Located Floor 1 JSON path.
- Calculated centre chunk.
- All nine selected chunk IDs.
- Export paths.
- Manifest path.
- Blender source path.
- Log path.

---

## 16. Successful Seam Validation

The script validates:

- East/west borders.
- North/south borders.
- Shared corners.
- All three mesh resolutions.
- Exact 256 m X dimensions.
- Exact 256 m Z dimensions.
- Expected chunk preview placement.

Success prints:

```text
SEAM VALIDATION PASSED
```

Failure prints:

```text
SEAM VALIDATION FAILED
```

A failure includes the two chunk IDs, mesh type, border vertex index, and differing heights.

The script stops before GLB export when seam validation fails.

---

## 17. Inspect Chunk Measurements in Blender

After generation:

1. Expand `Floor001TerrainTest` in the Outliner.
2. Expand `RenderLOD0`.
3. Select one LOD0 chunk.
4. Press `N` in the 3D Viewport.
5. Open the **Item** tab.
6. Inspect **Dimensions**.

Expected horizontal dimensions:

```text
X = 256 m
Y = 256 m
```

Blender's Z dimension varies because it represents terrain height.

The selected object's rotation should be zero and its scale should be one.

---

## 18. Inspect Matching Neighbour Edges

The console seam validator is the authoritative test.

For a visual check:

1. Switch the viewport to **Wireframe**.
2. Select two neighbouring LOD0 chunks.
3. Enter top orthographic view with Numpad `7`.
4. Zoom to the shared border.
5. Orbit to a low angle.
6. Confirm no visible gap appears.
7. Repeat with `RenderLOD1`.
8. Repeat with `Collision`.

The global coordinate markers in the `Markers` collection identify each chunk.

Do not move individual generated chunks before checking them.

---

## 19. Rerun Safely

To generate again:

1. Adjust only the clearly marked configuration values when required.
2. Click **Run Script** again.

The script:

- Finds its own tagged `Floor001TerrainTest` collection.
- Removes only generated objects inside that collection.
- Regenerates all nine chunks.
- Overwrites the matching GLBs.
- Rewrites the manifest.
- Resaves the Blender source file.
- Rewrites the generation log.

Unrelated collections and objects remain untouched.

---

## 20. Troubleshooting

### Floor JSON not found

Error:

```text
Could not locate AincradProject/data/floors/floor_001.json
```

Fix:

1. Confirm the complete uploaded structure is preserved.
2. Set `PROJECT_ROOT_OVERRIDE` to the outer `aincrad` folder.
3. Confirm this file exists:

```text
aincrad/AincradProject/data/floors/floor_001.json
```

### Floor JSON validation error

The generator intentionally stops when locked fields are missing or changed.

Check that the JSON still contains:

```text
floor_id = floor_001
godot_units_per_metre = 1
chunk_size_m = 256
east = +X
north = -Z
south = +Z
up = +Y
```

Do not work around the error by silently changing the generator. Review the source-of-truth documents first.

### Collection-name conflict

Error:

```text
A collection named 'Floor001TerrainTest' exists but is not tagged as generator-owned
```

The script refuses to delete it.

Rename the unrelated collection in Blender, then rerun.

### GLB exporter error

Confirm:

- Blender 4.x is being used.
- The script is running inside Blender.
- The output folder is writable.
- The glTF exporter is available in the Blender installation.

### No System Console on macOS

Run Blender from Terminal or inspect the Scripting workspace's console/output.

### Export directory remains empty

The folder is intentionally empty before the first local Blender run.

No placeholder or fake GLB files are included in the project package.

---

## 21. Optional Background Run

After the interactive run works, the same script can be executed from a command prompt:

```text
blender --background --python "C:\Path\To\aincrad\BlenderSource\floor_001\scripts\generate_floor_001_terrain_test.py"
```

Use the full Blender executable path when `blender` is not available as a terminal command.

Run interactively first so path and output errors are easy to inspect.

---

## 22. Validation Completed Without Blender

The delivered script was checked for:

- Valid Python syntax.
- Successful import outside Blender without running generation.
- Valid parsing of `floor_001.json`.
- Correct centre chunk calculation: `(0, 14)`.
- Correct nine test chunk IDs.
- Exact logical chunk dimensions.
- Deterministic global-coordinate height samples.
- Passing simulated LOD0, LOD1, and collision seam checks.
- Valid manifest serialization and re-parsing.
- Safe collection-deletion design.
- Correct expected output paths.
- No existing-file or `.uid` modifications.

Blender was not installed in the execution environment.

Therefore:

- No `.blend` file was generated.
- No GLB files were generated.
- No terrain manifest was falsely placed in the output folder.
- Lucas must run the script locally in Blender 4.x to produce those files.

---

## 23. Local Completion Checklist

- [ ] Blender 4.x opens successfully.
- [ ] The script locates `floor_001.json`.
- [ ] The calculated centre is `floor_001_chunk_x+00_z+14`.
- [ ] Exactly nine chunk IDs are printed.
- [ ] The generated root collection is `Floor001TerrainTest`.
- [ ] LOD0 contains nine mesh objects.
- [ ] LOD1 contains nine mesh objects.
- [ ] Collision contains nine mesh objects.
- [ ] Markers contains nine marker objects.
- [ ] Every terrain mesh measures 256 × 256 m horizontally.
- [ ] The console prints `SEAM VALIDATION PASSED`.
- [ ] Twenty-seven GLB files exist.
- [ ] `terrain_test_manifest.json` exists and opens as valid JSON.
- [ ] `floor_001_terrain_test.blend` exists outside `AincradProject`.
- [ ] The generation log exists.
- [ ] Neighbouring edges show no visible gaps.
- [ ] Godot imports only the generated GLBs and manifest.
- [ ] No unrelated Blender object was deleted.
- [ ] No gameplay or Godot scene file changed.
