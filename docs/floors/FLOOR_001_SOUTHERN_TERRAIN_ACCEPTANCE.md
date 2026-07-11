# Floor 001 Southern Terrain Acceptance

**Milestone:** 14C — Southern Terrain Acceptance and Empty Floor 1 Production Shell  
**Date:** 2026-07-11  
**Terrain dataset:** `floor_001_southern_region_v1`  
**Acceptance status:** Accepted as an iterative production base

---

## 1. Evidence and Local Milestone 14B Result

The Milestone 14C instruction supplied with the uploaded project states that the
49-chunk southern terrain dataset was generated and validated locally. The
uploaded project also contains:

- 49 LOD0 GLBs.
- 49 LOD1 GLBs.
- 49 dedicated collision GLBs.
- A completed southern manifest reporting 147 generated GLBs.
- Passed seam-validation metadata.
- The isolated Milestone 14B streaming test and its documentation.

The user-provided local-validation statement is accepted as the milestone gate
for creating the production shell. A step-by-step runtime log, screenshots,
frame timings, and a completed copy of every 14B checklist item were not stored
in the uploaded project. Therefore this document does not invent individual
runtime measurements or observations that were not recorded.

---

## 2. Acceptance Decision

The dataset is **accepted as the permanent terrain base for production
iteration** in the southern Floor 1 region.

Acceptance means:

- Its coordinate system, chunk range, manifest, and stable dataset ID may now be
  referenced by permanent production scenes.
- The existing technical tests remain regression tools.
- Buildings, walls, roads, vegetation, encounters, navigation, and final art may
  be authored against this terrain.

Acceptance does not mean:

- The terrain is final art.
- Every contour is immutable.
- Final materials, foliage, water, roads, or architecture are approved.
- The region is ready for normal F5 integration.
- The terrain contours are official Sword Art Online canon.

---

## 3. Accepted Chunk Range

```text
Grid X:       -3 through +3
Grid Z:       +11 through +17
Chunk count:  49
Chunk size:   256 × 256 metres
Coverage X:   -768 through +1024 metres
Coverage Z:   +2816 through +4608 metres
Centre chunk: floor_001_chunk_x+00_z+14
```

Floor 1 remains locked to:

```text
1 Godot unit = 1 metre
East  = +X
West  = -X
North = -Z
South = +Z
Up    = +Y
```

---

## 4. Seam Status

The uploaded southern manifest reports passed seam validation for:

- East/west shared borders.
- North/south shared borders.
- Shared corners.
- LOD0.
- LOD1.
- Dedicated collision meshes.
- Cross-resolution footprint alignment.
- Exact 256-metre dimensions and global placement.

The dataset is therefore accepted for continued chunk-streaming work. Any
future terrain regeneration must repeat the same seam checks before replacing
production data.

---

## 5. Collision Status

The production shell references the 49 dedicated exported collision GLBs. LOD0
and LOD1 are not used as hidden collision substitutes.

The user-provided milestone note confirms local validation was completed. The
uploaded files do not contain a detailed per-border collision test log, so
individual border crossings are not reconstructed here. The F6 production
preview remains the local regression surface for confirming collision after
future changes.

---

## 6. LOD Status

The accepted production values are:

```text
LOD0 radius:       1 chunk
LOD1 visual radius: 2 chunks
Collision radius:  1 chunk
Unload radius:     3 chunks
Update interval:   0.20 seconds
```

LOD0 and LOD1 remain mutually exclusive per active chunk root. Collision is
selected independently from visual LOD.

---

## 7. Streaming Status

The permanent region reuses:

```text
res://AincradProject/scripts/world/floor_chunk_streamer.gd
```

The streamer remains manifest-driven, threaded, queue-controlled, and shared by
the existing technical tests. The production shell does not duplicate its
implementation.

The permanent scene starts with a stable marker as its neutral streaming target.
The preview replaces that target with the existing player instance through the
streamer's public `set_streaming_target()` method.

The production scene does not retain every visited terrain resource in memory.
The isolated 14B test may keep its special validation cache, while production
uses the streamer's default release behaviour until a measured cache budget is
approved.

---

## 8. Known Visual Limitations

The accepted terrain still uses placeholder generation and materials.
Limitations include:

- Reconstructed rather than canon-exact contours.
- No final terrain shader or texture blending.
- No grass, trees, rocks, water, rivers, roads, bridges, walls, or buildings.
- No erosion-detail pass.
- No final skyline, distant landmarks, or regional atmosphere.
- No authored navigation mesh.
- No encounter, NPC, loot, or quest placement.

These omissions are intentional and do not block using the terrain as a stable
production base.

---

## 9. What May Still Be Regenerated

Future terrain regeneration is allowed when it preserves or deliberately
migrates:

- Stable dataset and region references.
- The 256-metre grid.
- Global coordinate alignment.
- Shared-edge identity.
- Stable gate, road, safe-zone, and neighboring-region anchors.
- Production marker IDs or documented replacements.

Reasonable future changes include smoothing local silhouettes, improving
landform readability, correcting collision defects, adding authored drainage,
and refining transitions near future region boundaries.

Do not silently regenerate terrain after production content has been placed.
Any regeneration must include a placement-impact review.

---

## 10. Permanent Production Paths

```text
Production region:
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn

Production controller:
res://AincradProject/scripts/world/floor_001_southern_region.gd

Region configuration:
res://AincradProject/data/floors/floor_001_southern_region.json

F6 preview:
res://AincradProject/scenes/world/floor_001_southern_region_preview.tscn

Preview controller:
res://AincradProject/scripts/world/floor_001_southern_region_preview.gd
```

The technical scenes remain unchanged regression tools:

```text
terrain_chunk_test.tscn
terrain_streaming_test.tscn
floor_001_southern_streaming_test.tscn
```

---

## 11. Stable Marker List

| Node name | Stable ID | Position `(X, Y, Z)` | Source |
|---|---|---:|---|
| `PlayerSpawnCityGate` | `spawn_player_city_gate` | `(0, 11, 3835)` | Gate plateau centre, raised for safe placement |
| `CheckpointCityGate` | `floor_001_starting_city_gate` | `(0, 9, 3890)` | Gate checkpoint-clear radius |
| `CityGateCentre` | `landmark_city_gate_centre` | `(0, 9, 3835)` | Gate plateau centre |
| `CityWallWestConnection` | `landmark_city_wall_west_connection` | `(-210, 9, 3835)` | Plateau inner radius |
| `CityWallEastConnection` | `landmark_city_wall_east_connection` | `(210, 9, 3835)` | Plateau inner radius |
| `MainRoadStart` | `road_gate` | `(0, 9, 3835)` | Terrain-profile road point |
| `MainRoadControl01` | `road_01` | `(12, 8.3, 3665)` | Terrain-profile road point |
| `MainRoadControl02` | `road_02` | `(-28, 8.8, 3480)` | Terrain-profile road point |
| `MainRoadControl03` | `road_03` | `(34, 10.2, 3280)` | Terrain-profile road point |
| `MainRoadNorthernExit` | `road_north_continuation` | `(20, 14, 2816)` | Terrain-profile road point |
| `BeginnerFieldWest` | `marker_beginner_field_west` | `(-250, 12, 3480)` | Western-transition start |
| `BeginnerFieldCentre` | `marker_beginner_field_centre` | `(0, 10, 3480)` | Central beginner-field corridor |
| `BeginnerFieldEast` | `marker_beginner_field_east` | `(260, 7, 3480)` | Eastern-transition start |
| `FutureWesternWoodlandEntrance` | `connection_region_horunka_woodlands` | `(-650, 24, 3330)` | West low-ridge control point |
| `FutureEasternLowlandEntrance` | `connection_region_east_lake_district` | `(760, 3, 3370)` | East-lowland control point |
| `FutureNorthernRegionConnection` | `connection_region_rata_plains` | `(20, 14, 2816)` | Northern continuation edge |

`DefaultStreamingAnchor` is an additional production-only marker with stable ID
`stream_anchor_southern_default`. It allows the world scene to initialise terrain
at the gate without owning a player.

---

## 12. Safe-Zone Definition

```text
Stable ID: safe_zone_starting_city_gate_plateau
Centre:    (0, 9, 3835)
Radius:    305 metres
Shape:     Cylinder
Height:    120 metres
```

The radius comes directly from:

```text
floor_001_southern_terrain_profile.json
city_gate_plateau.safe_zone_radius_m
```

The production scene contains an `Area3D` and exposes enter/exit signals. It does
not suppress enemies, disable combat, change checkpoints, or modify save data.
The production scene has no visible safe-zone mesh. The preview draws a
lightweight circle for inspection.

---

## 13. Production/Preview Ownership Boundary

The production region owns world structure and data. It does not contain the
player scene.

The preview owns only temporary local-testing concerns:

- Existing player instance.
- Safe terrain placement.
- Fall recovery.
- Debug UI.
- Chunk-boundary lines.
- Safe-zone and stable-marker guides.

This keeps future main-world logic free to instantiate and restore the player
separately from the region.

---

## 14. Recommended Next Asset Milestone

Proceed to:

**Milestone 15A — Starting City North-Gate Architecture Greybox**

Use `CityGateCentre`, both city-wall connection markers, `MainRoadStart`, the
safe-zone boundary, and the accepted terrain elevation as the locked placement
anchors. Keep the architecture modular and separate from terrain generation.
