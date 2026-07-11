# Floor 001 Master Plan

**Floor ID:** `floor_001`  
**Map status:** Development reconstruction, not an official canon map  
**Scale:** 10 km diameter; 1 Godot unit = 1 metre  
**Last updated:** 2026-07-11

---

## 1. Design Goal

Floor 1 should feel like one coherent circular landmass with a readable progression from safety in the south to danger in the north. The player should be able to understand the world from roads, mountain silhouettes, water, city walls, and the distant Labyrinth rather than from arbitrary invisible barriers.

The map is organized around three broad progression routes that reconnect before Tolbana:

1. **Central route:** Starting City → South Gate Outskirts → Rata Plains → Central Highland Ruins → Northern Valleys.
2. **Western route:** Starting City → Horunka Woodlands → Western Cave Hills → Central/Northern routes.
3. **Eastern route:** Starting City → East Lake District → Medai Ruins Route → Central/Northern routes.

All three lead to Tolbana, the Labyrinth foothills, and the First Floor Labyrinth.

---

## 2. Master Geography

### Southern edge

The Town of Beginnings occupies the southern tip. Its approximately 1 km semicircular rampart faces north. The safe north gate opens into a broad beginner belt with roads, checkpoints, low-risk encounters, and the project's current gate-sector prototype.

### Southern and central grasslands

The South Gate Outskirts and Rata Plains create the beginner progression zone. Main roads remain wide and visible. Side paths introduce boars, wolves, insects, gathering spaces, small bridges, low hills, and a reconstructed safe rest point.

### Northwest forest route

Horunka Woodlands form the deep northwest forest. Horunka serves as an early village and hunting base. The route becomes rockier toward a western cave passage and rim cliffs.

### Northeast lake route

The East Lake District contains the confirmed broad lake concept. Reconstructed causeways and wetlands lead toward Medai and the eastern ruins route.

### Central danger belt

The Central Highland Ruins combine the supported mountains, valleys, and ruins into a shared mid-floor escalation region. Western and eastern routes reconnect here or in the Northern Valleys. Vertical landmarks help players navigate without a minimap.

### Northern approach

The Northern Valleys narrow the routes, increase enemy danger, and reveal Tolbana and the Labyrinth tower. Tolbana is a safe preparation town with windmills and a meeting square.

### Far north

The Labyrinth Foothills create the final outdoor approach. The First Floor Labyrinth occupies the northern rim as a dominant structure. The floor boss area and stair to Floor 2 remain locked future content.

---

## 3. Natural Boundaries

The floor boundary should use visible geography:

- Southern city foundations and the floating rim.
- Western cliff faces and broken paths.
- Eastern lakes, wetlands, and waterfalls spilling toward the rim.
- Northern mountain walls around the Labyrinth base.
- Deep water, steep slopes, blocked ruins, and collapsed bridges where a route must remain unavailable.

Fallback safety volumes still exist below the floor, but ordinary players should read the visible boundary before reaching them.

---

## 4. Danger Progression

| Band | Approximate location | Levels | Purpose |
|---|---|---:|---|
| Safe start | Starting City | 1 | Services, onboarding, social space |
| Beginner belt | Gate Outskirts, Rata, near Horunka/lake roads | 1–4 | Boars, wolves, insects, first quests |
| Route specialisation | Horunka, lake, caves, Medai | 2–6 | Branch identity and optional dungeons |
| Mid-floor escalation | Central Highlands | 4–7 | Ruins, valleys, stronger ambushes |
| Northern danger | Rim routes and Northern Valleys | 5–9 | Route convergence and elite families |
| Raid preparation | Tolbana | 6–9 | Safe services and boss preparation |
| End route | Foothills and Labyrinth | 8–12 | Floor-clear content |

The numeric levels are project design, not official canon data.

---

## 5. Settlements

### Town of Beginnings

- Confirmed southern main settlement.
- Approximately 1 km rampart diameter.
- Production focus: northern wall, central plaza, Black Iron Palace silhouette, service districts, safe-zone boundary.

### Horunka

- Confirmed Floor 1 forest village.
- Reconstructed at approximately 120 m across.
- Production focus: compact hunting base, quest house, inn, tool and weapon services.

### Medai

- Confirmed Floor 1 village with reconstructed eastern-route placement.
- Production focus: small service settlement tied to farms, waterworks, and eastern ruins.

### Tolbana

- Confirmed northern town near the Labyrinth and approximately 200 m across.
- Production focus: windmill skyline, fountain/meeting square, inns, valley walls, Labyrinth view.

### Crossroads Rest

- Original project settlement.
- Small safe service point needed to pace the central route.
- Must remain clearly labelled as reconstruction.

---

## 6. Dungeons and Locked Locations

| ID | Location | Status | Confidence |
|---|---|---|---|
| `dungeon_horunka_forest_cave` | Western route | Planned | Reasonable interpretation |
| `dungeon_medai_ruins` | Eastern route | Planned | Reasonable interpretation |
| `dungeon_central_ruins_catacombs` | Central Highlands | Locked future | Original reconstruction |
| `dungeon_black_iron_palace_hidden` | Starting City | Locked future | Confirmed existence, placement reconstructed |
| `dungeon_floor_001_labyrinth` | Far north | Locked future | Confirmed official anchor |
| `boss_area_floor_001` | Labyrinth upper route | Locked future | Confirmed concept, geometry reconstructed |

No dungeon geometry is created in Milestone 12.

---

## 7. Current Outskirts Integration

The current scene represents a **small gate-sector prototype** inside `region_city_gate_outskirts`.

```text
Scene: res://AincradProject/world/floors/floor_001/floor_001_outskirts.tscn
Local size: 350 × 350 m
Intended global origin: (0, 0, 3835)
Intended global bounds: X -175..175, Z 3660..4010
```

### Suitable parts to keep or extract later

- Player and complete HUD integration.
- Checkpoint, quest NPC, shop NPC, chest, and sign behavior.
- Main-road width and visibility reference.
- Separated beginner boar encounter logic.
- Primitive material palette and daytime readability.
- Fall-safety concept.

### Parts that need production rebuilding or relocation

- The 350 m perimeter walls and water boundary.
- The miniature forest and ruins, which represent destinations thousands of metres apart in the master map.
- The sealed “Labyrinth entrance,” which is only a prototype blocker and is not the actual northern Labyrinth.
- The single 350 m ground slab and collision body.
- Local absolute actor positions, which should become marker/data-driven placements.
- The city wall, which must join the complete 1 km Starting City rampart.

### Decision

Keep the file unchanged as a regression and integration scene until production regions replace it. Do not scale the entire scene up to 10 km. Extract or rebuild its useful pieces into proper chunks.

---

## 8. Region and Chunk Relationship

Regions are authored world identities. Chunks are streaming cells.

- A region may contain dozens of chunks.
- A chunk has one primary `region_id` and optional overlap IDs.
- Roads and rivers cross chunk boundaries and require shared border control points.
- Region-level landmark proxies may stay loaded while detailed chunks unload.
- Enemy families belong to regions, while individual spawn placements belong to chunks.
- Persistent objects use floor, region, chunk, and placement IDs.

Streaming is only designed in this milestone; it is not implemented.

---

## 9. Map Reading Order

In `FLOOR_001_MASTER_MAP.svg`:

- Solid dark anchor markers indicate confirmed official locations or relations.
- Dashed boundaries indicate reasonable interpretations.
- Dotted or lightly filled areas indicate original reconstruction.
- The red outlined rectangle is the current 350 × 350 m outskirts scene at its intended global placement.
- Thick tan lines are main roads; thinner lines are branch routes.
- Purple symbols identify dungeon entrances; the northern tower is the Floor 1 Labyrinth.

---

## 10. Machine-Readable Source

`data/floors/floor_001.json` is the authoritative machine-readable planning file for:

- Scale and coordinate rules.
- Region IDs and approximate boundaries.
- Connections, settlements, roads, dungeons, and landmarks.
- Spawn/checkpoint planning.
- Streaming metadata.
- Reference confidence labels.

The SVG and Markdown documents should be updated whenever the JSON's locked planning values change.
