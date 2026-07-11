# Floor 001 Reference Audit

**Floor:** `floor_001`  
**Status:** Reference and confidence audit  
**Last updated:** 2026-07-11

---

## 1. Purpose

This document separates what is supported by published Sword Art Online material from what is inferred and what is authored specifically for this Godot project.

The project is **Aincrad-inspired**, not an attempt to claim that a complete official Floor 1 map exists. The master map created for Milestone 12 is a development reconstruction. Canonical names are temporary research anchors and should be renamed or replaced before any original commercial release, as required by `PROJECT_BIBLE.md`.

---

## 2. Confidence Labels

### Confirmed official information

A fact directly supported by primary published material, or clearly restated by an official licensed source. This label can confirm that a place exists, its broad relation to another place, or an explicit measurement. It does **not** automatically confirm the exact coordinates drawn on the project map.

### Reasonable interpretation

A conservative connection derived from several supported facts. Example: if the Starting City is at the southern edge and the Labyrinth is at the far north, a northbound progression corridor is a reasonable interpretation. Its precise turns remain unconfirmed.

### Original reconstruction

A project-authored solution required to create a complete, coherent, playable landmass. Region borders, exact coordinates, most rivers, secondary roads, encounter spaces, and chunk assignments belong here unless a source explicitly fixes them.

---

## 3. Primary and Official Reference Set

| Ref | Source | Use in this audit | Authority note |
|---|---|---|---|
| P1 | Reki Kawahara, *Sword Art Online, Vol. 1: Aincrad*, prologue | Base-floor diameter; cities, villages, forests, plains, lakes; single stair route through a Labyrinth | Primary published fiction |
| P2 | Reki Kawahara, *Sword Art Online Progressive, Vol. 1*, “Aria of a Starless Night” | Floor 1 shape and area; Starting City scale and southern placement; grasslands; northwest forest; northeast lake; mountains, valleys, ruins; northern Labyrinth; Tolbana scale and relationship | Primary published fiction |
| P3 | Reki Kawahara, *Sword Art Online, Vol. 8: Early and Late*, “The First Day” | Horunka and the forest quest context | Primary published fiction |
| P4 | “The Seventh Day” side-story route description | Possible central, western, and eastern progression routes involving Rata, Horunka, Medai, caves, and ruins | Supplementary material; used only for interpretation because accessible editions vary |
| L1 | Bandai Namco Entertainment, *Echoes of Aincrad* official location material | Licensed visual/game reference for Town of Beginnings, Tolbana, the Maze/Labyrinth, and Floor 1 plains enemy families | Official licensed adaptation, not treated as a replacement for primary canon |

Secondary encyclopaedias and fan-maintained wikis were used only to locate source claims and terminology. Fan maps, game maps from unrelated adaptations, role-play maps, Minecraft recreations, and community sketches are **not** treated as official geography.

---

## 4. Confirmed Official Information

| Topic | Confirmed information | What remains unconfirmed |
|---|---|---|
| Floor scale | Floor 1 is approximately circular, about 10 km across, and about 80 km² | Survey-grade circumference, rim irregularities, and exact coastline |
| Floor hierarchy | Aincrad contains 100 stacked floors; Floor 1 is the widest base floor | Exact vertical separation and underside geometry for this project |
| Starting City | The main starting settlement is on the southern edge; its northern rampart is approximately a 1 km semicircle | Exact street plan, exact centre coordinate, detailed outer suburbs |
| Southern fields | Grasslands outside the Starting City contain boar-, wolf-, and insect-type monsters | Exact spawn territories and road positions |
| Northwest | A large/deep forest lies northwest of the southern grasslands | Exact forest border, rivers, paths, and elevations |
| Northeast | A lake region lies northeast of the southern grasslands | Number of lakes, shore geometry, villages, and watercourses |
| Northern progression | Beyond the early forest/lake areas are mountains, valleys, and ruins with stronger monsters | Exact order and boundaries of every biome |
| Labyrinth | The First Floor Labyrinth stands at the far northern edge; its visible tower is described at roughly 300 m wide and 100 m tall | Exact footprint shape, exterior route, internal plan, and boss-room coordinate |
| Tolbana | Tolbana exists near the Labyrinth, is roughly 200 m across, and is associated with windmills and the first boss meeting | Exact valley outline, road length, and map coordinate |
| Horunka | Horunka is a Floor 1 village associated with the forest and an early quest | Exact dimensions and exact coordinate |
| Medai | Medai exists as a Floor 1 village | Exact appearance, size, and coordinate |
| Floor transition | The next-floor stair lies beyond the floor boss route in the Labyrinth system | Exact transition implementation for this project |

---

## 5. Reasonable Interpretations Used by the Master Plan

| Interpretation | Reasoning | Confidence limit |
|---|---|---|
| Main south-to-north progression spine | Starting City is southern, Labyrinth is far northern, and Tolbana is the closest major town to the Labyrinth | The road shape is reconstructed |
| Three broad northbound route families | Supplementary route material describes a central plains/canyon route, a western forest/cave route, and an eastern village/ruins route | Exact junctions and route lengths are not locked by primary map data |
| Horunka in the west-northwest corridor | Horunka is linked to a forest northwest of the Starting City | Exact coordinate is reconstructed |
| Medai on the eastern progression corridor | Side material associates Medai with an eastern ruins approach | Exact coordinate and biome are reconstructed |
| Tolbana in a northern valley | Tolbana is the nearest town to the northern Labyrinth and is described as a valley town | Exact valley width and orientation are reconstructed |
| Higher danger increases toward northern mountains and the Labyrinth | Published descriptions place more dangerous monsters beyond the early regions | Numeric level ranges are original game design |

---

## 6. Original Reconstruction in This Project

The following are not claimed as official:

- Every coordinate in `data/floors/floor_001.json`.
- All region polygons and stable region IDs.
- The exact placement of Horunka, Medai, Tolbana, roads, rivers, caves, ruins, checkpoints, and spawn markers.
- The Crossroads Rest settlement.
- The Western Rim Cliffs, Eastern Wetlands, Three Valleys, and most named landmarks.
- The 4,850 m playable radius and 150 m boundary belt.
- The 256 m streaming grid.
- Enemy level ranges and development priorities.
- The global placement of the current 350 × 350 m outskirts scene.

These choices are intentionally documented so they can be changed without rewriting history as canon.

---

## 7. Fan-Made and Adaptation Map Policy

Fan maps may be useful for visual brainstorming, but they cannot establish official scale or coordinates. Maps from games such as *Integral Factor* or other adaptations are also separate interpretations unless the project explicitly decides to adapt that version.

For production decisions:

1. Prefer primary published text.
2. Use licensed adaptation material only as a clearly labelled visual reference.
3. Use secondary wikis to find source citations, not as final authority.
4. Mark unsupported geometry as reconstruction.
5. Never describe this project SVG as an official Floor 1 map.

---

## 8. Audit Conclusion

A 10 km circular Floor 1 and its broad south-to-north geography are well supported. A complete 1:1 coordinate reconstruction is not supported. Milestone 12 therefore locks the **scale** and the **development coordinate system**, while treating the detailed master map as an original production plan guided by a small number of confirmed anchors.
