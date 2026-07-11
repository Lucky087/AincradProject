# Floor 001 Scale Guide

**Floor:** `floor_001`  
**Status:** Scale locked for production planning  
**Last updated:** 2026-07-11

---

## 1. Locked Measurements

| Measurement | Decision | Basis |
|---|---:|---|
| Godot scale | 1 unit = 1 metre | Existing project rule and predictable physics |
| Floor diameter | 10,000 m | Published Floor 1 measurement |
| Floor radius | 5,000 m | Derived from diameter |
| Playable radius | 4,850 m | Leaves a 150 m authored rim/boundary belt |
| Approximate area | 78.54 km² | Area of a 5 km-radius circle |
| Terrain height range | -80 m to +320 m | Supports water, valleys, hills, cliffs, and readable silhouettes without extreme slopes |
| Major structure ceiling | +450 m | Allows the Labyrinth and landmark silhouettes above ordinary terrain |
| Future outdoor chunk | 256 × 256 m | Gives useful streaming lead time at current player speeds and manageable scene scope |
| Labyrinth/interior chunk | 128 × 128 m recommended | Denser occlusion and navigation needs |

The 150 m rim belt is part of the floor footprint but is not normal traversal space. It can contain cliff faces, water, wall foundations, decorative underside transitions, and safety collision.

---

## 2. Coordinate Rules

The floor uses floor-local coordinates:

```text
Floor centre: (0, 0, 0)
East:        +X
West:        -X
North:       -Z
South:       +Z
Up:          +Y
```

This orientation matches Godot's common forward direction (`-Z`) and matches the current outskirts scene, where the city gate is at positive Z and the prototype route travels toward negative Z.

### Coordinate ownership

- All Floor 1 world positions are local to `floor_001`.
- Floors 2–100 must not be placed tens or hundreds of kilometres above Floor 1 in one permanent coordinate space.
- A future floor router should unload the current floor and load the destination floor near its own origin.
- Saved positions should eventually include `floor_id`, `region_id`, and `chunk_id` in addition to the transform.

---

## 3. Floating-Point Precision Strategy

Standard Godot 3D builds use single-precision world coordinates. At approximately 5,000 m from the origin, precision remains far below one centimetre and is suitable for character movement, collision, and ordinary environment placement.

### Decision

World-origin shifting is **not required for Floor 1**.

### Review origin shifting only when

- A single loaded space exceeds roughly 20–50 km from its origin.
- Several floors are incorrectly kept in one enormous continuous coordinate space.
- Network reconciliation or physics testing shows measurable instability.

The preferred solution for Aincrad is separate floor-local worlds, not continuous coordinates for all 100 floors.

---

## 4. Current Player Speeds and Travel Times

The existing player controller uses:

```text
Walk:   5.0 m/s
Sprint: 8.5 m/s
```

Uninterrupted mechanical travel estimates:

| Distance | Walk | Sprint |
|---:|---:|---:|
| 256 m chunk | 51 sec | 30 sec |
| 500 m | 1 min 40 sec | 59 sec |
| 1 km | 3 min 20 sec | 1 min 58 sec |
| 5 km radius | 16 min 40 sec | 9 min 48 sec |
| 10 km diameter | 33 min 20 sec | 19 min 36 sec |

These are straight-line times without combat, terrain, dialogue, gathering, or navigation.

### Authored travel targets

| Route type | Physical length | First-time play target |
|---|---:|---:|
| Safe hub to first encounter | 150–350 m | 2–5 min including onboarding |
| Encounter cluster to safe rest | 600–1,200 m | 8–18 min including combat |
| Settlement-to-settlement route | 1,000–2,500 m | 15–35 min including discovery |
| Starting City gate to Tolbana | approximately 7–8 km along routes | 35–60 min on first progression |
| Starting City gate to Labyrinth | approximately 8–9 km along routes | 45–75 min on first progression |
| Tolbana to Labyrinth approach | 1.5–2.2 km authored route | 15–30 min when approached cautiously |

The project should not slow the player merely to imitate narrative travel time. Encounters, terrain, forks, and points of interest should create the longer first-time journey.

---

## 5. Settlement Scale Targets

| Settlement | Target diameter | Confidence |
|---|---:|---|
| Town of Beginnings | 1,000 m rampart semicircle | Confirmed scale anchor |
| Tolbana | 200 m | Confirmed scale anchor |
| Horunka | 100–140 m | Reconstruction based on a small village |
| Medai | 140–180 m | Reconstruction |
| Crossroads Rest | 70–100 m | Original project settlement |

Settlement bounds include public streets and immediate service space, not every surrounding farm field.

---

## 6. Region Scale Targets

Production regions are larger authored areas and are not identical to streaming chunks.

| Region class | Typical width | Typical chunk count |
|---|---:|---:|
| City district | 500–1,200 m | 6–25 chunks |
| Grassland route | 1,200–2,500 m | 20–80 chunks |
| Forest/lake district | 2,000–3,500 m | 40–140 chunks |
| Mountain/highland region | 1,500–3,000 m | 30–100 chunks |
| Safe town vale | 700–1,500 m | 10–40 chunks |
| Labyrinth exterior | 500–1,300 m | 8–30 chunks |

A region owns art direction, encounters, weather, roads, and landmark identity. A chunk is only a streaming and persistence cell.

---

## 7. Chunk Grid

### Outdoor grid

```text
Chunk size: 256 × 256 m
cx = floor(world_x / 256)
cz = floor(world_z / 256)
```

Stable naming:

```text
floor_001_cx_+000_cz_+015
floor_001_cx_-004_cz_+010
floor_001_cx_+003_cz_-007
```

Zero belongs to the chunk beginning at coordinate zero. Negative coordinates use mathematical floor, not truncation toward zero.

### Recommended loading rings

| Ring | Chebyshev radius | Contents |
|---|---:|---|
| Active | 1 chunk | Collision, navigation, interactables, enemies, pickups |
| Visual preload | 2 chunks | Terrain visuals, large props, audio preparation |
| Far landmarks | Region controlled | Low-detail towers, city walls, mountains, Labyrinth silhouette |

At 5 m/s, a 256 m chunk takes about 51 seconds to cross, leaving enough time for asynchronous preparation before a player reaches the next boundary.

---

## 8. Current Outskirts Scale Placement

The existing scene remains exactly 350 × 350 m:

```text
res://AincradProject/world/floors/floor_001/floor_001_outskirts.tscn
```

Its intended production reference placement is:

```text
Scene origin:       (0, 0, 3835)
Global X bounds:    -175 to +175
Global Z bounds:    +3660 to +4010
Represented region: region_city_gate_outskirts
```

The current gate at local Z ≈ +165 aligns with the planned Starting City northern rampart at global Z ≈ +4000. This lets the current scene serve as a gate-sector prototype.

It is only 0.1225 km², approximately 0.16% of the complete Floor 1 area. It is suitable for regression and local design tests, but not as the full outskirts region.

---

## 9. Scale Change Control

After Milestone 12, do not change the following silently:

- 10,000 m floor diameter.
- 1 unit = 1 metre.
- Floor-centred origin.
- `+X` east and `-Z` north.
- 256 m outdoor chunk grid.
- Starting City rampart reference at approximately global Z = +4000.
- Labyrinth reference at the far northern edge.

A scale change requires:

1. A new `DECISION_LOG.md` entry.
2. Updated JSON and SVG.
3. A migration impact review for scenes, navigation, saves, and multiplayer interest ranges.
