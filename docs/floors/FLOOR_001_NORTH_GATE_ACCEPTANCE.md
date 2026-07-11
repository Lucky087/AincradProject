# Floor 1 North-Gate Provisional Production Acceptance

**Milestone:** 15C — North-Gate Production Acceptance and Provisional Region Integration  
**Date:** 2026-07-11  
**Acceptance level:** Provisional greybox production asset  
**Normal F5 world changed:** No

---

## 1. Asset-Set ID

```text
floor_001_starting_city_north_gate_architecture_v1
```

The asset set remains identified by the stable ID stored in the Blender/Godot
architecture manifest and the southern-region configuration.

## 2. Blender-Generation Status

The architecture manifest reports:

```text
generation_status = complete_blender_exports_generated
render GLBs = 16
collision GLBs = 16
actual GLB count = 32
units = 1 metre per unit
```

The editable Blender source and generator remain outside `AincradProject/` under
`BlenderSource/floor_001/`.

## 3. Godot Import Status

Milestone 15B validated all 16 render resources and all 16 dedicated simplified
collision resources. The reusable runtime assembly is:

```text
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
```

Milestone 15C does not copy individual GLBs into the production region. It
instances this assembly scene once.

## 4. Gate Alignment Results

The accepted target anchors are:

```text
CityGateCentre:            (0, 9, 3835)
CityWallWestConnection: (-210, 9, 3835)
CityWallEastConnection:  (210, 9, 3835)
MainRoadStart:             (0, 9, 3835)
```

The user confirmed locally that the gate renders correctly and the wall endpoints
align. The assembly and production-region controller retain a 0.05-metre target
tolerance for gate centre, west endpoint, east endpoint, and road start.

## 5. Open-Passage Result

The gate passage remains:

```text
width:  14 metres
height: 12 metres
forward direction: negative Godot Z
```

The user confirmed that the player can walk through the open gate passage.

## 6. Wall and Tower Collision Result

The user confirmed that walls and towers block the player. Dedicated simplified
collision GLBs remain active for raised and blocking architecture, including the
gate piers, towers, connectors, walls, stairs, and access platform.

## 7. Road-Collision Bug

The original Milestone 15B preview created concave collision bodies for flat
road slabs and edging directly over the terrain. Nearly coplanar and intersecting
contacts allowed the player capsule to become wedged when standing or landing on
the road.

The player controller, player shape, terrain meshes, and terrain streamer were
not the cause.

## 8. Confirmed Bugfix

Milestone 15B.1 made streamed terrain collision authoritative beneath flat
road render pieces:

- Flat straight, curved, and intersection road physics is disabled.
- Road-edging physics is disabled.
- Render pieces remain visible.
- Dedicated raised-architecture collision remains enabled.
- Collision-source debug visualization remains available.

The user confirmed that the player can now walk, sprint, jump, land on the road,
and cross road-piece joins without becoming stuck.

## 9. User-Confirmed Local Runtime Results

Only these results are recorded as user-confirmed:

1. Gate renders correctly.
2. Wall endpoints align.
3. Player can walk through the open gate passage.
4. Walls and towers block the player.
5. Road collision bug was fixed.
6. Player can walk, sprint, jump, and land on the road.
7. Player can cross road-piece joins without becoming stuck.
8. Terrain streaming remains functional.

No additional local test result is claimed.

## 10. Greybox Limitations

The current architecture remains an original project reconstruction and a
technical greybox. It does not yet include:

- Anime-quality modelling.
- Final stone materials or texture work.
- Ornamentation or sculptural detail.
- Weathering.
- Banners.
- City-side buildings or streets.
- Interiors.
- Navigation meshes.
- NPCs, enemies, shops, quests, or gameplay placement.

Small terrain/foundation presentation differences may still be refined later
without changing the locked production markers.

## 11. Why Acceptance Is Provisional

The assembly has passed the user-confirmed functional checks needed to become a
production base, but it is not final art. Its shape, materials, supports, access
layout, and decorative language may be regenerated or replaced as long as the
stable gate, wall, and road anchors remain compatible.

## 12. Production Assembly Path

```text
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
```

## 13. Production Region Integration Path

```text
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
└── StaticContent/CityGateArchitecture/NorthGateAssembly
```

The region contains one reusable assembly instance and no individual copied
architecture GLB nodes.

## 14. Replacement and Regeneration Rules

- Keep the stable asset-set ID or provide an explicit migration.
- Preserve `CityGateCentre`, both wall endpoints, and `MainRoadStart` alignment.
- Preserve negative-Z gate orientation.
- Preserve a physically open 14-by-12-metre passage unless an approved design
  decision changes it.
- Preserve terrain-authoritative collision for flat ground-level road pieces.
- Use authored simple collision for any future elevated road.
- Replace or regenerate the assembly as one scene, not by editing copied GLB
  instances throughout the production region.
- Keep test previews as regression tools.

## 15. Recommended Next Milestone

**Milestone 16A — Starting City North-Gate District Layout and City-Side Plaza
Greybox**

That milestone should establish the city-side ground plan and production markers
around the accepted gate without creating the full Starting City, final art,
interiors, actors, quests, navigation, or normal-game integration.
