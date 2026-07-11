# Floor 001 Region List

**Floor:** `floor_001`  
**Region count:** 14  
**Last updated:** 2026-07-11

This document is the human-readable companion to `data/floors/floor_001.json`. Boundaries and coordinates are approximate production planning values, not official canon coordinates.

---
## 1. Town of Beginnings

| Field | Value |
|---|---|
| Region ID | `region_starting_city` |
| Type | `safe_city` |
| Centre | `(0, 0, 4500)` |
| Approximate bounds | X `-520` to `520`, Z `4000` to `5000` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_starting_city.tscn` |
| Chunk size | `256 m` |
| Safe zone | `Yes` |
| Player level range | `1–1` |
| Development priority | `P1`; production order `3` |
| Reference confidence | Existence: `confirmed_official`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_city_gate_outskirts`

**Enemy families:** None in the safe area.

**Settlements:** `settlement_town_of_beginnings`

**Dungeons:** `dungeon_black_iron_palace_hidden`

**Landmarks:** `landmark_starting_city_north_gate`, `landmark_black_iron_palace`, `landmark_starting_city_central_plaza`

**Required unique assets:** `starting_city_semicircular_rampart`, `starting_city_north_gate`, `black_iron_palace_silhouette`, `central_teleport_plaza`

**Required modular assets:** `city_street_kit`, `city_house_kit`, `city_wall_kit`, `city_lamp_kit`

---
## 2. South Gate Outskirts

| Field | Value |
|---|---|
| Region ID | `region_city_gate_outskirts` |
| Type | `safe_transition_grassland` |
| Centre | `(0, 8, 3500)` |
| Approximate bounds | X `-900` to `900`, Z `2750` to `4050` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_city_gate_outskirts.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `1–3` |
| Development priority | `P0`; production order `2` |
| Reference confidence | Existence: `reasonable_interpretation`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_starting_city`, `region_rata_plains`, `region_horunka_woodlands`, `region_east_lake_district`

**Enemy families:** `wild_boar`, `dire_wolf`, `field_wasp`

**Settlements:** `settlement_crossroads_rest`

**Dungeons:** None.

**Landmarks:** `landmark_starting_city_north_gate`, `landmark_current_outskirts_prototype`, `landmark_south_road_crossroads`

**Required unique assets:** `starting_city_exterior_gate_approach`, `south_road_waystone`

**Required modular assets:** `grassland_foliage_kit`, `stone_road_kit`, `low_rock_kit`, `field_fence_kit`

---
## 3. Rata Plains

| Field | Value |
|---|---|
| Region ID | `region_rata_plains` |
| Type | `central_grassland` |
| Centre | `(0, 15, 1750)` |
| Approximate bounds | X `-1300` to `1300`, Z `600` to `2850` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_rata_plains.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `1–4` |
| Development priority | `P0`; production order `4` |
| Reference confidence | Existence: `reasonable_interpretation`; location: `reasonable_interpretation`; boundary: `original_reconstruction` |

**Connected regions:** `region_city_gate_outskirts`, `region_central_highlands`, `region_horunka_woodlands`, `region_east_lake_district`

**Enemy families:** `wild_boar`, `dire_wolf`, `field_wasp`, `beetle`, `worm`

**Settlements:** `settlement_crossroads_rest`

**Dungeons:** None.

**Landmarks:** `landmark_rata_central_road`, `landmark_south_road_crossroads`, `landmark_central_canyon_mouth`

**Required unique assets:** `rata_plains_canyon_view`, `central_crossroads_waystone`

**Required modular assets:** `grassland_foliage_kit`, `stone_road_kit`, `field_rock_kit`, `small_bridge_kit`

---
## 4. Horunka Woodlands

| Field | Value |
|---|---|
| Region ID | `region_horunka_woodlands` |
| Type | `deep_forest_and_village` |
| Centre | `(-2550, 35, 2250)` |
| Approximate bounds | X `-4500` to `-900`, Z `500` to `3900` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_horunka_woodlands.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `1–4` |
| Development priority | `P1`; production order `5` |
| Reference confidence | Existence: `confirmed_official`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_city_gate_outskirts`, `region_rata_plains`, `region_western_cave_hills`

**Enemy families:** `wild_boar`, `dire_wolf`, `little_nepent`, `forest_insect`

**Settlements:** `settlement_horunka`

**Dungeons:** `dungeon_horunka_forest_cave`

**Landmarks:** `landmark_horunka_village`, `landmark_horunka_old_growth`, `landmark_western_cave_mouth`

**Required unique assets:** `horunka_quest_house`, `horunka_village_gate`, `old_growth_tree_landmark`

**Required modular assets:** `forest_tree_kit`, `forest_ground_kit`, `village_house_kit`, `forest_path_kit`

---
## 5. East Lake District

| Field | Value |
|---|---|
| Region ID | `region_east_lake_district` |
| Type | `lake_shore_and_wet_grassland` |
| Centre | `(2700, 12, 2200)` |
| Approximate bounds | X `900` to `4500`, Z `400` to `3900` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_east_lake_district.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `2–5` |
| Development priority | `P1`; production order `6` |
| Reference confidence | Existence: `confirmed_official`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_city_gate_outskirts`, `region_rata_plains`, `region_medai_ruins_route`

**Enemy families:** `field_wasp`, `scavenger_toad`, `water_insect`, `dire_wolf`

**Settlements:** None.

**Dungeons:** None.

**Landmarks:** `landmark_east_great_lake`, `landmark_lake_causeway`, `landmark_east_watch_hill`

**Required unique assets:** `great_lake_shoreline`, `lake_causeway`, `waterfall_cliff`

**Required modular assets:** `shoreline_kit`, `reed_kit`, `wetland_rock_kit`, `bridge_kit`

---
## 6. Western Cave Hills

| Field | Value |
|---|---|
| Region ID | `region_western_cave_hills` |
| Type | `rocky_hills_and_caves` |
| Centre | `(-3050, 75, 0)` |
| Approximate bounds | X `-4850` to `-1200`, Z `-1800` to `1000` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_western_cave_hills.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `3–6` |
| Development priority | `P2`; production order `8` |
| Reference confidence | Existence: `reasonable_interpretation`; location: `reasonable_interpretation`; boundary: `original_reconstruction` |

**Connected regions:** `region_horunka_woodlands`, `region_central_highlands`, `region_western_rim_cliffs`

**Enemy families:** `dire_wolf`, `cave_bat`, `rock_beetle`, `large_nepent`

**Settlements:** None.

**Dungeons:** `dungeon_horunka_forest_cave`

**Landmarks:** `landmark_western_cave_mouth`, `landmark_split_peak`, `landmark_west_rim_overlook`

**Required unique assets:** `western_cave_entrance`, `split_peak_silhouette`

**Required modular assets:** `rock_cliff_kit`, `cave_entrance_kit`, `mountain_path_kit`

---
## 7. Medai Ruins Route

| Field | Value |
|---|---|
| Region ID | `region_medai_ruins_route` |
| Type | `farmland_ruins_and_eastern_pass` |
| Centre | `(2850, 55, 0)` |
| Approximate bounds | X `1200` to `4850`, Z `-1700` to `1000` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_medai_ruins_route.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `3–6` |
| Development priority | `P2`; production order `9` |
| Reference confidence | Existence: `confirmed_official`; location: `reasonable_interpretation`; boundary: `original_reconstruction` |

**Connected regions:** `region_east_lake_district`, `region_central_highlands`, `region_eastern_wetlands`

**Enemy families:** `dire_wolf`, `field_wasp`, `ruin_kobold`, `scavenger_toad`

**Settlements:** `settlement_medai`

**Dungeons:** `dungeon_medai_ruins`

**Landmarks:** `landmark_medai_village`, `landmark_eastern_ruins_gate`, `landmark_old_aqueduct`

**Required unique assets:** `medai_village_square`, `eastern_ruins_gateway`, `old_aqueduct`

**Required modular assets:** `farmstead_kit`, `ruin_wall_kit`, `aqueduct_kit`, `stone_road_kit`

---
## 8. Central Highland Ruins

| Field | Value |
|---|---|
| Region ID | `region_central_highlands` |
| Type | `mountains_valleys_and_ruins` |
| Centre | `(0, 110, -400)` |
| Approximate bounds | X `-1800` to `1800`, Z `-1700` to `700` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_central_highlands.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `4–7` |
| Development priority | `P1`; production order `7` |
| Reference confidence | Existence: `confirmed_official`; location: `reasonable_interpretation`; boundary: `original_reconstruction` |

**Connected regions:** `region_rata_plains`, `region_western_cave_hills`, `region_medai_ruins_route`, `region_northern_valleys`

**Enemy families:** `ruin_kobold`, `dire_wolf`, `rock_beetle`, `ambush_insect`

**Settlements:** None.

**Dungeons:** `dungeon_central_ruins_catacombs`

**Landmarks:** `landmark_central_canyon`, `landmark_ancient_ruins`, `landmark_highland_bridge`

**Required unique assets:** `central_canyon`, `ancient_ruins_complex`, `highland_bridge`

**Required modular assets:** `mountain_cliff_kit`, `ruin_column_kit`, `ruin_wall_kit`, `rope_bridge_kit`

---
## 9. Western Rim Cliffs

| Field | Value |
|---|---|
| Region ID | `region_western_rim_cliffs` |
| Type | `rim_cliffs_and_high_danger_wilds` |
| Centre | `(-3900, 125, -2450)` |
| Approximate bounds | X `-5000` to `-1600`, Z `-4100` to `-500` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_western_rim_cliffs.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `5–8` |
| Development priority | `P3`; production order `12` |
| Reference confidence | Existence: `original_reconstruction`; location: `original_reconstruction`; boundary: `original_reconstruction` |

**Connected regions:** `region_western_cave_hills`, `region_northern_valleys`

**Enemy families:** `dire_wolf`, `rock_beetle`, `cliff_wasp`, `elite_boar`

**Settlements:** None.

**Dungeons:** None.

**Landmarks:** `landmark_west_rim_overlook`, `landmark_broken_rim_bridge`

**Required unique assets:** `western_rim_cliff_face`, `broken_rim_bridge`

**Required modular assets:** `rim_cliff_kit`, `mountain_path_kit`, `wind_bent_tree_kit`

---
## 10. Eastern Wetlands

| Field | Value |
|---|---|
| Region ID | `region_eastern_wetlands` |
| Type | `wetlands_lakes_and_rim_marsh` |
| Centre | `(3950, 20, -2300)` |
| Approximate bounds | X `1600` to `5000`, Z `-4000` to `-300` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_eastern_wetlands.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `5–8` |
| Development priority | `P3`; production order `13` |
| Reference confidence | Existence: `reasonable_interpretation`; location: `reasonable_interpretation`; boundary: `original_reconstruction` |

**Connected regions:** `region_medai_ruins_route`, `region_northern_valleys`

**Enemy families:** `scavenger_toad`, `water_insect`, `field_wasp`, `marsh_wolf`

**Settlements:** None.

**Dungeons:** None.

**Landmarks:** `landmark_eastern_marsh_delta`, `landmark_mirror_lake`, `landmark_east_rim_falls`

**Required unique assets:** `marsh_delta`, `mirror_lake`, `east_rim_waterfall`

**Required modular assets:** `wetland_foliage_kit`, `shoreline_kit`, `wooden_walkway_kit`

---
## 11. Northern Valleys

| Field | Value |
|---|---|
| Region ID | `region_northern_valleys` |
| Type | `mountain_passes_and_danger_corridors` |
| Centre | `(0, 150, -2450)` |
| Approximate bounds | X `-1800` to `1800`, Z `-3500` to `-1500` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_northern_valleys.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `6–9` |
| Development priority | `P2`; production order `10` |
| Reference confidence | Existence: `confirmed_official`; location: `reasonable_interpretation`; boundary: `original_reconstruction` |

**Connected regions:** `region_central_highlands`, `region_western_rim_cliffs`, `region_eastern_wetlands`, `region_tolbana_vale`

**Enemy families:** `ruin_kobold`, `dire_wolf`, `large_nepent`, `elite_insect`

**Settlements:** None.

**Dungeons:** None.

**Landmarks:** `landmark_northern_pass`, `landmark_three_valleys`, `landmark_tolbana_south_view`

**Required unique assets:** `northern_pass_gate`, `three_valleys_landscape`

**Required modular assets:** `mountain_cliff_kit`, `valley_road_kit`, `ruin_watchtower_kit`

---
## 12. Tolbana Vale

| Field | Value |
|---|---|
| Region ID | `region_tolbana_vale` |
| Type | `safe_town_and_valley` |
| Centre | `(0, 55, -3800)` |
| Approximate bounds | X `-1100` to `1100`, Z `-4300` to `-3300` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_tolbana_vale.tscn` |
| Chunk size | `256 m` |
| Safe zone | `Yes` |
| Player level range | `6–9` |
| Development priority | `P1`; production order `11` |
| Reference confidence | Existence: `confirmed_official`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_northern_valleys`, `region_labyrinth_foothills`

**Enemy families:** None in the safe area.

**Settlements:** `settlement_tolbana`

**Dungeons:** None.

**Landmarks:** `landmark_tolbana_windmills`, `landmark_tolbana_fountain_square`, `landmark_labyrinth_valley_view`

**Required unique assets:** `tolbana_windmills`, `tolbana_fountain_square`, `tolbana_amphitheatre`

**Required modular assets:** `tolbana_house_kit`, `windmill_kit`, `valley_wall_kit`, `town_fountain_kit`

---
## 13. Labyrinth Foothills

| Field | Value |
|---|---|
| Region ID | `region_labyrinth_foothills` |
| Type | `high_danger_approach` |
| Centre | `(0, 190, -4475)` |
| Approximate bounds | X `-1300` to `1300`, Z `-4850` to `-4050` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_labyrinth_foothills.tscn` |
| Chunk size | `256 m` |
| Safe zone | `No` |
| Player level range | `8–10` |
| Development priority | `P1`; production order `14` |
| Reference confidence | Existence: `confirmed_official`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_tolbana_vale`, `region_floor_001_labyrinth`

**Enemy families:** `ruin_kobold`, `kobold_sentinel`, `elite_wolf`

**Settlements:** None.

**Dungeons:** `dungeon_floor_001_labyrinth`

**Landmarks:** `landmark_labyrinth_approach`, `landmark_first_floor_labyrinth_tower`

**Required unique assets:** `labyrinth_foothill_stairs`, `labyrinth_outer_gate`, `tower_base_silhouette`

**Required modular assets:** `kobold_ruin_kit`, `mountain_stair_kit`, `labyrinth_exterior_kit`

---
## 14. First Floor Labyrinth

| Field | Value |
|---|---|
| Region ID | `region_floor_001_labyrinth` |
| Type | `floor_labyrinth_and_boss_route` |
| Centre | `(0, 240, -4800)` |
| Approximate bounds | X `-300` to `300`, Z `-5000` to `-4500` |
| Recommended scene | `res://AincradProject/world/floors/floor_001/regions/region_floor_001_labyrinth.tscn` |
| Chunk size | `128 m` |
| Safe zone | `No` |
| Player level range | `9–12` |
| Development priority | `P1`; production order `15` |
| Reference confidence | Existence: `confirmed_official`; location: `confirmed_official`; boundary: `original_reconstruction` |

**Connected regions:** `region_labyrinth_foothills`

**Enemy families:** `ruin_kobold`, `kobold_sentinel`, `floor_boss_minion`

**Settlements:** None.

**Dungeons:** `dungeon_floor_001_labyrinth`, `boss_area_floor_001`

**Landmarks:** `landmark_first_floor_labyrinth_tower`, `landmark_floor_001_boss_gate`, `landmark_stair_to_floor_002`

**Required unique assets:** `floor_001_labyrinth_tower`, `floor_001_boss_gate`, `floor_002_stair_portal`

**Required modular assets:** `labyrinth_wall_kit`, `labyrinth_stair_kit`, `boss_room_kit`

---
