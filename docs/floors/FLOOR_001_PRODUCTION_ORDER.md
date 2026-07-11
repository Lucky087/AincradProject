# Floor 001 Production Order

**Floor:** `floor_001`  
**Status:** Approved planning sequence; no geometry created in Milestone 12  
**Last updated:** 2026-07-11

---

## 1. Production Principle

Do not build the full 10 km floor as one scene. Lock data first, create a low-cost floor shell, then build one connected route at a time. Each phase must remain playable before the next expands the world.

---

## 2. Phase 0 — Scale and Data Lock

**Milestone 12**

- [x] Audit official, interpreted, and reconstructed information.
- [x] Lock 10 km diameter and floor-centred coordinates.
- [x] Lock 256 m outdoor chunks.
- [x] Define stable region, road, settlement, dungeon, landmark, spawn, and checkpoint IDs.
- [x] Place the current outskirts scene in the master coordinate plan without modifying it.
- [x] Create JSON and SVG planning sources.

**Exit condition:** No production geometry begins until the JSON validates and all major measurements have a recorded decision.

---

## 3. Phase 1 — Floor Shell and Streaming Prototype

Priority: **P0**

1. Create a data-driven empty Floor 1 root with the 5 km circle boundary.
2. Add a chunk-coordinate debug overlay and marker importer.
3. Implement a temporary chunk loader using empty or flat debug chunks.
4. Add floor ID, region ID, and chunk ID to future save schema through a planned migration.
5. Test collision and navigation seams with simple planes only.
6. Keep `floor_001_outskirts.tscn` as the regression scene.

**Do not** create final terrain during this phase.

**Exit condition:** A player can cross several 256 m debug chunks without duplicate actors, missing collision, or invalid save positions.

---

## 4. Phase 2 — Starting City North Gate and South Gate Outskirts

Priority: **P0**

Regions:

- `region_starting_city` north-gate district only.
- `region_city_gate_outskirts`.

Work:

1. Build the 1 km rampart reference shell and north gate.
2. Recreate the useful M11 gate-sector elements at master coordinates.
3. Move player/NPC/enemy placements to stable data markers.
4. Build 3–5 connected production chunks around the gate.
5. Preserve all current gameplay systems.
6. Replace the prototype “Labyrinth” blocker with a road closure or chunk boundary appropriate to the south gate.

**Exit condition:** The existing prototype loop works in production coordinates and can still be tested in the unchanged M11 scene.

---

## 5. Phase 3 — Rata Plains Core Route

Priority: **P0**

Region:

- `region_rata_plains`.

Work:

1. Build the central road for approximately 1.5–2 km.
2. Add encounter spacing, low hills, rocks, and one safe rest point.
3. Add road forks toward Horunka and the East Lake District.
4. Establish the first region-to-region transition tests.
5. Profile grass, rocks, enemies, navigation, and save persistence.

**Exit condition:** The gate-to-crossroads route is readable, performant, and supports 15–25 minutes of complete gameplay.

---

## 6. Phase 4 — Horunka Route

Priority: **P1**

Regions:

- `region_horunka_woodlands`.
- First part of `region_western_cave_hills`.

Work:

1. Build forest modular kit and path silhouettes.
2. Build Horunka as a compact safe village.
3. Reserve the western cave dungeon entrance.
4. Add forest-specific encounter families only after the region works with existing boars/wolves.
5. Test canopy visibility and navigation cost.

**Exit condition:** Horunka is a useful alternate route and safe service stop, not a disconnected side map.

---

## 7. Phase 5 — East Lake and Medai Route

Priority: **P1/P2**

Regions:

- `region_east_lake_district`.
- `region_medai_ruins_route`.

Work:

1. Build large-water performance prototype.
2. Establish shoreline, causeway, and wetland modular kits.
3. Build reconstructed Medai village.
4. Reserve the eastern ruins dungeon entrance.
5. Connect the route back into the central highlands.

**Exit condition:** East and west branches offer distinct navigation and visual identity while preserving common systems.

---

## 8. Phase 6 — Central Highlands and Route Convergence

Priority: **P1**

Region:

- `region_central_highlands`.

Work:

1. Build mountains, valleys, and ruins as long-range navigation landmarks.
2. Create central canyon and route reconnection points.
3. Reserve the optional catacomb dungeon and future miniboss arena.
4. Test vertical navigation and chunk-border navigation links.

**Exit condition:** All three southern routes reconnect coherently and reveal the northern progression.

---

## 9. Phase 7 — Northern Valleys and Tolbana

Priority: **P1/P2**

Regions:

- `region_northern_valleys`.
- `region_tolbana_vale`.

Work:

1. Build higher-danger passes and elite encounter spaces.
2. Establish Tolbana's 200 m scale.
3. Create windmill skyline, fountain square, inns, and raid-preparation services.
4. Maintain the Labyrinth as a visible distant landmark.

**Exit condition:** Tolbana feels like the earned northern staging town and the path to the Labyrinth is unambiguous.

---

## 10. Phase 8 — Rim Regions and Optional Content

Priority: **P3**

Regions:

- `region_western_rim_cliffs`.
- `region_eastern_wetlands`.

These regions add exploration breadth after the critical path is complete. They must not delay the main city-to-Labyrinth route.

---

## 11. Phase 9 — Labyrinth Foothills and Exterior

Priority: **P1**

Regions:

- `region_labyrinth_foothills`.
- Exterior of `region_floor_001_labyrinth`.

Work:

1. Build the 300 m-wide Labyrinth exterior scale reference.
2. Create the foothill road, gate, and locked transition.
3. Do not build the full dungeon or boss until the outdoor floor is stable.

**Exit condition:** The complete outdoor Floor 1 route has a strong visible destination and safe transition boundary.

---

## 12. Phase 10 — Dungeon and Boss Production

Future milestone only:

- Western cave.
- Eastern ruins dungeon.
- Optional central catacombs.
- First Floor Labyrinth interior.
- Boss room and Floor 2 transition.

This phase requires separate design documents and is outside Milestone 12.

---

## 13. Asset Production Order

1. Shared terrain/cliff and road kits.
2. Grassland foliage and rocks.
3. Starting City wall/gate kit.
4. Forest kit.
5. Shoreline/wetland kit.
6. Ruin and mountain kits.
7. Village house kit.
8. Tolbana windmill and town kit.
9. Labyrinth exterior kit.
10. Dungeon-specific kits.

Unique landmarks are built after their supporting modular kit is proven.

---

## 14. Review Gates

Every production phase must pass:

- Scale and coordinate check against `floor_001.json`.
- Chunk-border collision test.
- Navigation-border test.
- Save/load position test.
- Persistent-object ID audit.
- Multiplayer interest-management review, even before networking is implemented.
- Performance capture on the target development PC.
- Regression test in `test_world.tscn` and `floor_001_outskirts.tscn`.

---

## 15. Work Explicitly Deferred

- Final art and textures.
- Floors 2–100.
- Full Starting City interior districts.
- New enemy implementation.
- Dungeon interiors and boss mechanics.
- Multiplayer and server deployment.
- Procedural world generation.
- Seamless cross-floor coordinates.
