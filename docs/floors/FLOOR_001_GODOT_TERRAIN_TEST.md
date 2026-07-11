# Floor 001 Godot Terrain-Chunk Import Test

**Milestone:** 13B — Godot Terrain-Chunk Import Test  
**Engine:** Godot 4.7  
**Test scene:** `res://AincradProject/scenes/world/terrain_chunk_test.tscn`  
**Loader:** `res://AincradProject/scripts/world/terrain_chunk_test_loader.gd`  
**Manifest:** `res://AincradProject/assets/environments/floor_001/terrain/test_chunks/terrain_test_manifest.json`

---

## 1. Purpose

This milestone proves that the nine chunks exported by the Blender terrain test
can be imported, positioned, rendered, and walked on inside Godot.

It is deliberately separate from the normal game. It does not change:

- `project.godot`
- `scenes/main.tscn`
- `scenes/world/test_world.tscn`
- `world/floors/floor_001/floor_001_outskirts.tscn`
- Player scripts or gameplay systems
- SaveManager

Run the new scene manually with **F6**.

---

## 2. Scene Hierarchy

```text
TerrainChunkTest
├── Environment
│   ├── WorldEnvironment
│   └── DirectionalLight3D
├── TerrainChunks
│   └── one runtime root per manifest chunk
│       ├── VisualLOD0
│       ├── VisualLOD1
│       └── Collision
│           └── StaticBody3D
│               └── CollisionShape3D
├── BoundarySafety
│   └── FallRecoveryArea
│       └── CollisionShape3D
├── Player
└── DebugUI
    ├── DebugPanel
    │   └── MarginContainer
    │       └── DebugLabel
    └── DebugUpdateTimer
```

The scene instances the existing player scene exactly once:

```text
res://AincradProject/scenes/player/player.tscn
```

The player already contains its own active third-person camera, so this test
scene does not add a second active camera.

---

## 3. How the Manifest Is Loaded

At startup, `TerrainChunkTestLoader` opens:

```text
res://AincradProject/assets/environments/floor_001/terrain/test_chunks/
terrain_test_manifest.json
```

The loader validates:

- JSON can be opened and parsed.
- The JSON root is a dictionary.
- `floor_id` is `floor_001`.
- One unit equals one metre.
- Chunk size is exactly 256 metres.
- There are exactly nine chunk records.
- The centre chunk is `floor_001_chunk_x+00_z+14`.
- Each chunk contains a stable ID, grid coordinates, bounds, global position,
  LOD0 path, LOD1 path, and collision path.
- Every manifest position equals the position calculated from its grid values.
- The combined bounds are approximately 768 by 768 metres.

A malformed required field stops loading safely and writes a useful error to
the Godot Output and Debugger panels.

A missing individual GLB produces a warning and the loader continues with the
remaining files.

---

## 4. How the GLBs Are Positioned

The Blender generator exported every GLB with a local origin at the chunk's
minimum-X/minimum-Z corner.

For example:

```text
Chunk ID:        floor_001_chunk_x+00_z+14
Local mesh area: X 0..256, Z 0..256
Manifest origin: X 0, Y 0, Z 3584
```

The Godot loader creates a chunk root and applies the manifest position:

```gdscript
chunk_root.position = manifest_global_position
```

It does not manually type nine unrelated positions into the scene.

The complete grid covers:

```text
X: -256 to 512
Z: 3328 to 4096
```

The centre chunk covers:

```text
X: 0 to 256
Z: 3584 to 3840
```

---

## 5. Blender-to-Godot Coordinate Conversion

The Blender generator stored logical Floor 1 coordinates this way:

```text
Blender local X  → Godot +X
Blender local -Y → Godot +Z
Blender local Z  → Godot +Y
```

Blender's glTF exporter and Godot's glTF importer perform the axis conversion
inside the GLB pipeline. The imported mesh already has local bounds similar to:

```text
X: 0..256
Y: terrain height
Z: 0..256
```

Therefore the loader must **not** swap axes or negate Z again. It reads the
manifest's Godot-space position directly as:

```text
Vector3(global_x, global_y, global_z)
```

Signs of an incorrect second conversion would include:

- Chunks standing vertically.
- The grid extending along Y instead of Z.
- Mirrored north/south placement.
- Neighboring chunk origins separated by the wrong axis.

---

## 6. Visual LOD Loading

Each runtime chunk root contains:

```text
VisualLOD0
VisualLOD1
```

Both GLBs are loaded when available.

Default state:

```text
LOD0: visible
LOD1: hidden
```

Press **F4** to switch every loaded visual chunk between LOD0 and LOD1.

The test handles F4 directly in `terrain_chunk_test_loader.gd`. No Input Map
action was added, which keeps `project.godot` unchanged.

This is only a visual debugging toggle. It is not the final distance-based LOD
system.

---

## 7. How Collision Is Created

The loader does not use LOD0 or LOD1 for physics.

For each manifest chunk it:

1. Loads the dedicated `_collision.glb` as a `PackedScene`.
2. Finds every `MeshInstance3D` inside the imported scene.
3. Calls `Mesh.create_trimesh_shape()` on the collision mesh.
4. Creates a `StaticBody3D` under that chunk's `Collision` container.
5. Creates a `CollisionShape3D` using the collision mesh's relative transform.
6. Frees the temporary imported collision-visual node.

The resulting hierarchy is:

```text
ChunkRoot
└── Collision
    └── StaticBody3D
        └── CollisionShape3D
```

The collision body uses collision layer 1, matching the existing player and
world collision setup.

The collision export has 17 by 17 vertices per chunk. It is intentionally much
simpler than LOD0 but has the same 256 by 256 metre footprint and matching
border heights.

---

## 8. Player Spawn and Fall Recovery

The player starts above the centre of:

```text
floor_001_chunk_x+00_z+14
```

The loader reads that chunk's bounds and places the player six metres above its
highest recorded terrain point. Gravity then settles the player onto the
collision terrain.

A temporary `Area3D` sits below the complete grid. If the player enters it:

- The player returns to the centre test chunk.
- Character velocity becomes `Vector3.ZERO`.
- Save data is not changed.
- Checkpoint data is not changed.
- Health, progression, inventory, quests, and gold are not changed.

This recovery volume belongs only to the import-test scene.

---

## 9. Debug Display

The upper-left test panel shows:

```text
LOD0 loaded count
LOD1 loaded count
Collision loaded count
Current visual LOD
Centre chunk ID
Manifest seam-validation result
Manifest status
Player world position
F4 instruction
```

The player position updates every 0.25 seconds through a Timer. It does not run
an unnecessary `_process()` loop.

Useful loading messages are also printed to Godot's Output panel, including the
position and collision-shape count for each loaded chunk.

---

## 10. How to Run the Scene

1. Open the outer `aincrad` folder as the Godot project.
2. Wait for Godot to finish importing all 27 GLB files.
3. In the FileSystem dock, open:

```text
AincradProject/scenes/world/terrain_chunk_test.tscn
```

4. Press **F6 — Run Current Scene**.
5. Do not press F5 for this test. F5 continues to start the normal game.
6. Confirm the debug panel reports:

```text
LOD0 loaded: 9 / 9
Collision loaded: 9 / 9
Centre chunk: floor_001_chunk_x+00_z+14
Manifest seams: PASSED
```

7. Let the player fall onto the terrain.
8. Walk across the test grid.
9. Press F4 to compare LOD0 and LOD1.

---

## 11. Inspecting Terrain Seams

Test every internal border, not only one edge.

The 3 by 3 grid contains:

- Six east/west neighbor borders.
- Six north/south neighbor borders.
- Four shared four-chunk interior corners.

Recommended checks:

1. Walk slowly along each visible border.
2. Walk directly across each border at several positions.
3. Jump while crossing the border.
4. Look for light leaks, cracks, overlapping strips, or sudden height changes.
5. Watch the player feet for collision steps or brief falling.
6. Switch to LOD1 and repeat the visual seam inspection.
7. Use the manifest's `PASSED` result as source-data validation, but still
   perform the in-engine visual and collision tests.

The Blender script guarantees matching sampled heights. This Godot test proves
that import transforms, placement, normals, and runtime collision preserve that
result.

---

## 12. Recognizing Correct Scale

Correct scale means:

- One terrain chunk is 256 metres wide.
- The full grid is approximately 768 metres across.
- The existing player capsule appears human-sized.
- Crossing one chunk at the existing 5 m/s walk speed takes about 51 seconds.
- Crossing one chunk at 8.5 m/s sprint speed takes about 30 seconds.

Likely scale problems:

| Symptom | Likely cause |
|---|---|
| One chunk crossed in a few seconds | Import scale is too small |
| Player appears microscopic | Import scale is too large |
| Chunks are 100 times too large or small | Unit or importer scale changed |
| Terrain is vertical | Axis conversion was applied twice or incorrectly |
| 256 m neighbor offset does not align | Manifest position was ignored |

Do not fix a scale problem by manually applying different per-chunk scales.
Correct the export or import rule consistently.

---

## 13. Troubleshooting Missing GLBs

### Debug panel shows fewer than nine LOD0 chunks

Check that all nine files ending in `_lod0.glb` exist under:

```text
AincradProject/assets/environments/floor_001/terrain/test_chunks/
```

Then check Godot's Import and Output panels.

### A GLB exists but `ResourceLoader` cannot load it

- Wait for Godot's import process to finish.
- Right-click the GLB and choose **Reimport**.
- Confirm its importer type is **Scene**.
- Confirm its `.import` file was not manually edited.
- Restart the editor if the import cache is stale.

### Collision count is below nine

- Confirm every `_collision.glb` exists.
- Open one collision GLB directly in Godot.
- Confirm it contains a `MeshInstance3D`.
- Check the Output panel for `create_trimesh_shape()` warnings.
- Do not use LOD0 as a silent collision replacement; correct the collision
  export instead.

### The player falls through one entire chunk

The matching collision GLB is probably missing or failed to import.

### The player falls only at a border

Compare:

- Neighbor manifest positions.
- Collision-mesh local bounds.
- Collision source transforms.
- Blender seam-validation output.

### The terrain appears but material is missing

The placeholder material is embedded in the LOD GLB. Reimport the GLB and check
that embedded materials are enabled. Do not create a new final terrain shader
for this milestone.

---

## 14. Complete Validation Checklist

### Files and isolation

- [ ] The normal game still starts unchanged with F5.
- [ ] `scenes/main.tscn` is unchanged.
- [ ] `scenes/world/test_world.tscn` is unchanged.
- [ ] `floor_001_outskirts.tscn` is unchanged.
- [ ] `project.godot` is unchanged.
- [ ] No gameplay or SaveManager file changed.

### Manifest and loading

- [ ] Manifest validation passes.
- [ ] Exactly nine chunk entries are read.
- [ ] Centre chunk is `floor_001_chunk_x+00_z+14`.
- [ ] Manifest seam result displays `PASSED`.
- [ ] Missing-file handling produces a warning instead of a crash.

### Visual terrain

- [ ] Nine LOD0 chunks load.
- [ ] Nine LOD1 chunks load.
- [ ] LOD0 is visible by default.
- [ ] F4 switches all chunks to LOD1.
- [ ] F4 switches all chunks back to LOD0.
- [ ] The total visible area is approximately 768 by 768 metres.
- [ ] Imported placeholder material remains visible.

### Placement and axes

- [ ] Chunk origins are separated by exactly 256 metres.
- [ ] East/west placement follows X.
- [ ] North/south placement follows Z.
- [ ] Terrain height follows Y.
- [ ] The centre chunk occupies X 0..256 and Z 3584..3840.
- [ ] No chunk has an extra rotation, mirror, or scale.

### Collision

- [ ] Nine collision chunks load.
- [ ] The player stands on the terrain.
- [ ] The player walks across all internal borders.
- [ ] The player can jump across borders.
- [ ] No large collision holes exist.
- [ ] Collision uses dedicated collision GLBs, not LOD0 or LOD1.

### Safety and debug

- [ ] Falling below the grid returns the player to the centre chunk.
- [ ] Fall recovery clears velocity.
- [ ] Fall recovery does not change saves or checkpoints.
- [ ] Debug player position updates periodically.
- [ ] Output messages identify every loaded chunk and problem file.

---

## 15. Completion Rule

Milestone 13B is locally complete only when Godot 4.7 demonstrates:

```text
9 LOD0 chunks loaded
9 collision chunks loaded
768 × 768 m placement
No visible transform seams
No major collision gaps
Player movement and jumping across every internal border
Normal game unchanged
```

Do not begin final Floor 1 terrain generation or runtime streaming until this
import test has been completed and documented locally.
