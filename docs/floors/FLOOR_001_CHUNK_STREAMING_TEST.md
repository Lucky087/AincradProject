# Floor 001 Runtime Chunk Streaming Test

**Milestone:** 13C  
**Engine:** Godot 4.7  
**Status:** Isolated test prepared; local runtime validation required  
**Last updated:** 2026-07-11

---

## 1. Purpose

This milestone proves a reusable runtime terrain-chunk lifecycle using the real
3 × 3 Blender export batch.

It tests:

- Manifest-driven chunk registration.
- Signed floor-based grid coordinates.
- Player-centred visual LOD selection.
- Collision activation independent from visual LOD.
- Background `PackedScene` requests.
- Stable chunk roots with no duplicate instances.
- Safe visual, collision, and root removal.
- Movement across 256-metre chunk boundaries.
- Safe behaviour outside the nine generated chunks.

It does **not** change the normal game or the non-streaming import test.

Run this scene manually:

```text
res://AincradProject/scenes/world/terrain_streaming_test.tscn
```

The existing regression scene remains unchanged:

```text
res://AincradProject/scenes/world/terrain_chunk_test.tscn
```

---

## 2. Scene Hierarchy

```text
TerrainStreamingTest
├── Environment
│   ├── WorldEnvironment
│   └── DirectionalLight3D
├── TerrainStreamer
│   ├── LoadedChunks
│   │   └── floor_001_chunk_...
│   │       ├── Visual
│   │       └── Collision
│   └── StreamingUpdateTimer
├── Player
├── BoundarySafety
│   └── FallRecoveryArea
├── DebugVisualization
│   └── CurrentChunkBoundary
└── DebugUI
    ├── DebugPanel
    │   └── DebugLabel
    └── DebugUpdateTimer
```

The existing player scene is instanced once. Its existing camera remains the
only active gameplay camera.

Reusable streaming logic belongs in:

```text
res://AincradProject/scripts/world/floor_chunk_streamer.gd
```

Test-only controls, debug display, boundary visualization, and fall recovery
belong in:

```text
res://AincradProject/scripts/world/terrain_streaming_test.gd
```

---

## 3. Manifest Registry

The streamer reads:

```text
res://AincradProject/assets/environments/floor_001/terrain/test_chunks/
terrain_test_manifest.json
```

It validates:

- Floor ID.
- Unit scale.
- Positive chunk size.
- Stable chunk IDs.
- Unique grid coordinates.
- Unique chunk IDs.
- Global positions.
- Exact 256 × 256 metre bounds.
- LOD0, LOD1, and collision paths.
- Centre-chunk metadata when available.
- Manifest seam-validation status.

Every valid entry becomes an internal registry record containing:

```text
chunk_id
grid_x
grid_z
global_position
bounds
lod0_path
lod1_path
collision_path
```

Only coordinates present in this registry may create terrain roots.

The nine positions are never manually entered into the test scene.

---

## 4. Player Position to Chunk Coordinate

The locked Floor 1 chunk size is:

```text
256 metres
```

The streamer calculates:

```text
grid_x = floor(player_world_x / 256)
grid_z = floor(player_world_z / 256)
```

Godot stores this pair as a `Vector2i`:

```text
Vector2i(grid_x, grid_z)
```

Floor-based calculation is required because integer truncation is incorrect for
negative coordinates.

Examples:

```text
World X =  10   → grid X =  0
World X = 255   → grid X =  0
World X = 256   → grid X =  1
World X =  -1   → grid X = -1
World X = -256  → grid X = -1
World X = -257  → grid X = -2
```

This matches the Floor 1 Blender and planning grid.

---

## 5. Desired Chunk Selection

The streamer uses Chebyshev grid distance:

```text
distance = max(abs(chunk_x - player_x), abs(chunk_z - player_z))
```

This creates square loading rings that match a square chunk grid.

The scene defaults are:

| Setting | Default |
|---|---:|
| LOD0 radius | `0` chunks |
| LOD1 visual radius | `1` chunk |
| Collision radius | `1` chunk |
| Unload radius | `2` chunks |
| Update interval | `0.20` seconds |
| New threaded requests per update | `6` |

At the centre of the generated grid:

- The current chunk requests LOD0.
- The eight immediate neighbours request LOD1.
- The current chunk and all immediate neighbours request collision.
- Previously active roots may be retained empty inside the unload radius to
  reduce boundary thrashing.
- Roots farther than the unload radius are removed.

The full registry is not scanned every rendered frame. Target selection runs
only when:

- The player enters a different grid coordinate.
- The test explicitly forces an update after teleport or recovery.

A Timer polls background resource requests at the configured interval.

---

## 6. Streaming Lifecycle

`FloorChunkStreamer` defines these lifecycle states:

```text
Unloaded
Requested
Loading
Active
Unloading
Failed
```

Visual LOD and collision are stored independently because one chunk may be:

```text
LOD1 visible + collision active
LOD0 visible + collision active
LOD1 visible + collision inactive
No visual + no collision but temporarily retained
```

A typical lifecycle is:

```text
Unloaded
→ Requested
→ Loading
→ Active LOD1 and/or collision
→ Active LOD0 after entering the chunk
→ Active LOD1 after leaving the chunk
→ Visual and collision removed
→ Unloading
→ Unloaded
```

A failed individual path is recorded and shown in the debug display. Other
chunks continue loading.

---

## 7. Background Resource Loading

The streamer uses Godot's threaded resource API:

```text
ResourceLoader.load_threaded_request()
ResourceLoader.load_threaded_get_status()
ResourceLoader.load_threaded_get()
```

The process is:

1. Queue a unique path and intended purpose.
2. Start a limited number of new requests per Timer update.
3. Poll only already-requested paths.
4. Retrieve a resource only after Godot reports that loading is complete.
5. Validate that the result is a `PackedScene`.
6. Recheck whether the player still needs that LOD or collision.
7. Instantiate only when the request is still relevant.

A path cannot be added to the queue again while it is queued or loading.

If the player leaves before a request finishes, the completed resource is not
allowed to recreate a stale chunk.

Current limitation:

- This test releases its own PackedScene references when content is removed.
- Godot may still satisfy a later request from its internal resource cache.
- Final full-floor memory profiling and cache policy remain future work.

---

## 8. Stable Chunk Roots and Duplicate Prevention

Each active coordinate has at most one root:

```text
LoadedChunks/floor_001_chunk_x+00_z+14
```

That root is stored in a dictionary keyed by `Vector2i`.

The root contains exactly two stable containers:

```text
Visual
Collision
```

Rules:

- The active-chunk dictionary is checked before creating a root.
- The request queue is checked before requesting a path.
- The threaded-request dictionary is checked before requesting a path.
- The current visual node is removed before a replacement is added.
- The current `StaticBody3D` is removed before new collision is added.
- Unloading removes the root from the active dictionary before later reuse.

No coordinate can accumulate duplicate chunk roots, visual scenes, or
`StaticBody3D` nodes.

---

## 9. LOD Selection

### LOD0

LOD0 is selected when:

```text
Chebyshev distance <= LOD0 radius
```

With the default radius of zero, only the player's current chunk uses:

```text
*_lod0.glb
```

### LOD1

LOD1 is selected when:

```text
LOD0 radius < distance <= LOD1 visual radius
```

Immediate neighbouring chunks use:

```text
*_lod1.glb
```

### Switching

When a target LOD changes:

1. The new resource is requested.
2. The previous visual may remain temporarily while loading finishes.
3. The old visual node is removed.
4. Exactly one new visual scene is instantiated as `Visual/LOD0` or
   `Visual/LOD1`.

LOD0 and LOD1 are never intentionally left visible together.

---

## 10. Collision Activation

Collision selection is independent from visual selection.

With the default collision radius of one, the current chunk and eight immediate
neighbours receive collision even when a neighbour is displaying LOD1.

For each required collision chunk:

1. Load the dedicated `*_collision.glb`.
2. Instantiate it temporarily beneath the chunk's `Collision` container.
3. Find imported `MeshInstance3D` nodes.
4. Create trimesh `Shape3D` resources from their meshes.
5. Add those shapes beneath one `StaticBody3D`.
6. Preserve the imported mesh transform.
7. Remove the temporary visual collision source.

Collision is removed when the chunk leaves the collision radius.

The streamer never substitutes LOD0 or LOD1 as physics geometry.

---

## 11. Safe Unloading

When a chunk is outside all active visual and collision radii:

- Its visual node is removed.
- Its collision body is removed.
- Queued requests that have not started are cancelled.
- Its own PackedScene cache references are released.

When it also moves beyond the unload radius:

- Its stable root is removed from `LoadedChunks`.
- Its active dictionary entry is erased.

Godot does not provide cancellation for a background request already in
progress. Such a request is allowed to complete, but its result is discarded
when no longer relevant.

---

## 12. Current Chunk Boundary Display

The test contains one transparent 256 × 256 metre plane.

It moves to the current manifest chunk and sits slightly above that chunk's
maximum recorded terrain height.

The plane:

- Shows which grid cell is currently selecting LOD0.
- Uses only one debug node.
- Hides when the player coordinate is outside the manifest.
- Does not affect collision.

---

## 13. Test Teleports

The debug teleports are handled locally by
`terrain_streaming_test.gd`. `project.godot` is unchanged.

Use:

| Input | Direction |
|---|---|
| `Ctrl + Up Arrow` | One chunk north (`-Z`) |
| `Ctrl + Down Arrow` | One chunk south (`+Z`) |
| `Ctrl + Left Arrow` | One chunk west (`-X`) |
| `Ctrl + Right Arrow` | One chunk east (`+X`) |

A successful teleport:

- Uses the target manifest chunk centre.
- Places the player above the target chunk's recorded maximum height.
- Clears velocity.
- Forces an immediate streaming update.

A teleport outside the generated 3 × 3 registry is cancelled and prints a
useful message.

These controls avoid F6 and other editor run/stop shortcuts.

---

## 14. Fall Recovery

A temporary `Area3D` exists below the complete 3 × 3 test area.

When the existing player enters it:

- The same player returns above the centre chunk.
- Velocity is cleared.
- Streaming updates immediately.
- Save data is not changed.
- Checkpoint data is not changed.
- Health, XP, quests, inventory, equipment, and gold are not reset.

This recovery belongs only to the streaming test scene.

---

## 15. Debug Display

The upper-left panel updates every 0.25 seconds and shows:

- Player world position.
- Current signed grid coordinate.
- Current chunk ID.
- Whether the coordinate exists in the manifest.
- Loaded root count.
- Active LOD0 count.
- Active LOD1 count.
- Active collision count.
- Queued and loading request count.
- Failed-load count.
- Manifest status.
- Manifest seam result.
- Sorted loaded chunk IDs.
- Teleport controls.
- Most recent test or warning message.

No debug `_process()` loop is used.

---

## 16. Running the Scene

1. Open the outer `aincrad/` project in Godot 4.7.
2. Wait until all 27 terrain GLBs finish importing.
3. Open:

```text
AincradProject/scenes/world/terrain_streaming_test.tscn
```

4. Press **F6 — Run Current Scene**.
5. Keep the game window focused while testing movement or teleports.
6. Do not change the project's main scene.
7. Press F5 separately afterward to confirm normal gameplay is unchanged.

Initial loading is intentionally progressive. The debug counts should rise as
threaded requests complete.

---

## 17. Expected Centre-Grid Result

At the centre coordinate `(0, 14)`, after loading finishes:

```text
Current chunk:       floor_001_chunk_x+00_z+14
LOD0 active:         1
LOD1 active:         8
Collision active:    9
Coordinate exists:   YES
Failed loads:        0
```

The loaded-root count may temporarily include retained empty roots after
crossing boundaries. Roots beyond the configured unload radius must disappear.

---

## 18. Testing Boundary Crossing

### Walking test

1. Start near the centre of chunk `(0, 14)`.
2. Walk east until X crosses `256`.
3. Confirm the current coordinate changes to `(1, 14)`.
4. Confirm chunk `(1, 14)` becomes LOD0.
5. Confirm chunk `(0, 14)` changes toward LOD1.
6. Confirm collision remains available across the border.
7. Walk back west across X `256`.
8. Repeat across the north/south Z boundaries.

### Teleport test

1. Use `Ctrl + Arrow` to move between generated chunk centres.
2. Observe current chunk, LOD counts, and loaded IDs.
3. Move to an outer edge chunk.
4. Attempt another teleport outward.
5. Confirm the missing coordinate is reported without a crash.

---

## 19. Complete Validation Checklist

### Isolation

- [ ] F5 still starts the normal game.
- [ ] `terrain_chunk_test.tscn` remains unchanged and works with F6.
- [ ] `test_world.tscn` remains unchanged.
- [ ] `floor_001_outskirts.tscn` remains unchanged.
- [ ] No gameplay, player, SaveManager, project setting, `.uid`, or `.godot`
      file changed.

### Initial streaming

- [ ] The manifest registry contains exactly nine valid chunks.
- [ ] The current coordinate begins at `(0, 14)`.
- [ ] The centre chunk becomes LOD0.
- [ ] Immediate neighbours become LOD1.
- [ ] Current and neighbouring chunks receive collision.
- [ ] No duplicate root names appear beneath `LoadedChunks`.
- [ ] Loading requests eventually return to zero.
- [ ] Failed loads remain zero with all GLBs present.

### Coordinate calculation

- [ ] Crossing X `256` changes grid X from `0` to `1`.
- [ ] Crossing X `0` westward changes grid X from `0` to `-1`.
- [ ] Crossing Z `3584` or `3840` changes grid Z correctly.
- [ ] Negative X uses floor behaviour rather than truncation.

### LOD

- [ ] Only the current chunk uses LOD0 with default settings.
- [ ] Immediate visible neighbours use LOD1.
- [ ] LOD changes do not leave duplicate visual children.
- [ ] Visual roots remain at manifest global positions.
- [ ] LOD seams remain aligned.

### Collision

- [ ] Collision is active independently from visual LOD.
- [ ] Collision uses only `_collision.glb` files.
- [ ] The player can walk and jump across every active border.
- [ ] No duplicate `StaticBody3D` nodes accumulate.
- [ ] Collision is removed outside the collision radius.
- [ ] Visual and collision seams remain aligned.

### Unloading

- [ ] Old visuals disappear outside visual range.
- [ ] Old collision disappears outside collision range.
- [ ] Roots beyond the unload radius are removed.
- [ ] Returning to a removed chunk recreates only one root.
- [ ] A late completed request does not recreate an unwanted chunk.

### Safety and debug

- [ ] The transparent current-cell boundary follows the player grid.
- [ ] The boundary hides outside the manifest.
- [ ] Debug counts match the scene tree.
- [ ] Loaded IDs are stable manifest IDs.
- [ ] Teleports clear player velocity.
- [ ] Out-of-grid teleports fail safely.
- [ ] Falling below the grid returns the player to the centre.
- [ ] Fall recovery does not modify persistent data.

---

## 20. Current Nine-Chunk Limitations

This dataset can prove lifecycle behavior but cannot prove full Floor 1 memory,
I/O, or traversal performance.

Current limitations:

- Only nine registry entries exist.
- The maximum visible set is also nine chunks.
- The test has no roads, props, navigation, NPCs, enemies, or persistent world
  objects.
- Resource cache behavior has not been profiled at full-floor scale.
- No loading priorities based on movement direction exist.
- No far-distance region proxies exist.
- No server-authoritative interest management exists.
- No editor chunk-authoring tools exist.

---

## 21. Scaling to the Full Floor 1 Manifest

The reusable streamer is intentionally manifest-driven. A later full Floor 1
manifest can add more entries without changing coordinate calculation or stable
root naming.

Before production use, future milestones must add:

- Full manifest generation and validation.
- Memory and I/O profiling with many chunks.
- Explicit resource-cache and eviction policy.
- Directional preload priority.
- Region-level distant proxies.
- Navigation chunk activation.
- Enemy and interactable spawn definitions.
- Persistent-object restore by stable placement ID.
- Save data containing floor, region, and chunk identity.
- Multiplayer interest ownership and authority rules.
- Loading-screen and failure-recovery presentation.

Do not generate the complete Floor 1 terrain until this nine-chunk runtime test
passes locally in Godot 4.7.
