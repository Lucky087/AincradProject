# Handoff — Milestone 15C

**Milestone:** North-Gate Production Acceptance and Provisional Region Integration  
**Date:** 2026-07-11  
**Implementation status:** Complete  
**Runtime status:** Milestone 15B.1 accepted by user; post-integration F6 regression still required

---

## Current Project State

The project contains:

- The accepted 49-chunk southern Floor 1 terrain dataset.
- The permanent player-independent southern production region.
- The Blender-generated 16-piece north-gate render/collision kit.
- The reusable manifest-driven Godot north-gate assembly.
- The accepted terrain-authoritative flat-road collision fix.
- One provisional north-gate assembly instance inside the permanent region.
- A north-gate preview that reuses the production-owned assembly.
- A southern-region preview that now inherits the integrated gate.
- Unchanged normal F5 startup and technical terrain regression scenes.

## Local Acceptance Results

The user explicitly confirmed:

- Gate renders correctly.
- Wall endpoints align.
- Player can walk through the open gate passage.
- Walls and towers block the player.
- Road collision bug was fixed.
- Player can walk, sprint, jump, and land on the road.
- Player can cross road-piece joins without becoming stuck.
- Terrain streaming remains functional.

No additional runtime result is recorded as confirmed.

## Road-Collision Bug and Fix

The original flat-road and edging concave trimesh bodies overlapped or closely
tracked terrain collision. Competing bottom, side, and join contacts could wedge
the player capsule.

Milestone 15B.1 fixed this without changing the player or terrain:

- Flat road surfaces create no physics bodies.
- Road edging creates no physics bodies.
- Terrain is authoritative beneath ground-level road renders.
- Gate, wall, tower, connector, stair, platform, and other raised architecture
  collision remains enabled.
- Collision-source debugging remains available with C in the north-gate preview.

## Files Created

```text
AincradProject/docs/floors/FLOOR_001_NORTH_GATE_ACCEPTANCE.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_15C.md
```

## Files Modified

```text
AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
AincradProject/scripts/world/floor_001_southern_region.gd
AincradProject/data/floors/floor_001_southern_region.json
AincradProject/scenes/world/floor_001_north_gate_preview.tscn
AincradProject/scripts/world/floor_001_north_gate_preview.gd
AincradProject/docs/CURRENT_TASKS.md
AincradProject/docs/DECISION_LOG.md
AincradProject/docs/TECHNICAL_ARCHITECTURE.md
AincradProject/docs/floors/FLOOR_001_NORTH_GATE_GODOT_PREVIEW.md
AincradProject/docs/handoffs/HANDOFF_MILESTONE_15B.md
```

## Production Integration

The permanent region now contains exactly one scene instance:

```text
Floor001SouthernRegion
└── StaticContent
    └── CityGateArchitecture
        └── NorthGateAssembly
```

The production region does not contain a player. It does not duplicate the
assembly loader or copy individual GLBs.

The region controller validates:

- One assembly exists at the expected path.
- Architecture set ID and scene/manifest paths match configuration.
- Assembly manifest status passes.
- 16 render and 16 collision resources load with zero failures.
- Gate centre, west endpoint, east endpoint, and road start remain within
  0.05 metres.
- Flat road and edging physics remain disabled.

Invalid or missing architecture produces warnings rather than crashing terrain
or regional inspection.

## Duplicate Prevention

`floor_001_north_gate_preview.tscn` no longer instances a separate gate assembly.
Its existing script resolves:

```text
SouthernRegion/StaticContent/CityGateArchitecture/NorthGateAssembly
```

The southern-region preview requires no separate gate node; it automatically
shows the assembly through its production-region instance.

## Important Paths

```text
res://AincradProject/world/floors/floor_001/floor_001_southern_region.tscn
res://AincradProject/world/floors/floor_001/architecture/floor_001_north_gate_assembly.tscn
res://AincradProject/scenes/world/floor_001_north_gate_preview.tscn
res://AincradProject/scenes/world/floor_001_southern_region_preview.tscn
res://AincradProject/data/floors/floor_001_southern_region.json
res://AincradProject/docs/floors/FLOOR_001_NORTH_GATE_ACCEPTANCE.md
```

## Validation Completed

- Region JSON parses successfully.
- Architecture manifest parses and reports completed Blender exports.
- All 32 architecture GLB paths remain present.
- Production region scene contains one assembly instance declaration.
- North-gate preview contains no separate assembly instance declaration.
- Production region contains no player node.
- Region controller performs non-crashing integration validation.
- Road-collision policy remains terrain-authoritative.
- Existing protected assets, tests, F5 configuration, `.uid`, and `.godot/`
  contents remain unchanged.
- GDScript parser/lint/format and scene-reference validation were run in the
  delivery environment.

Godot 4.7 runtime execution was not available in the delivery environment.

## Local Tests Still Required

- [ ] Run the north-gate preview with F6 and confirm one visible gate.
- [ ] Confirm its debug UI still controls markers, collision visualization,
      teleports, passage state, and chunk boundaries.
- [ ] Reconfirm accepted road and passage traversal after production nesting.
- [ ] Run the southern-region preview with F6 and confirm the integrated gate is
      visible there.
- [ ] Confirm walls/towers retain collision and terrain streaming remains active.
- [ ] Run all three existing technical terrain test scenes unchanged.
- [ ] Press F5 and confirm the existing normal game remains unchanged.

## Known Greybox Limitations

- The gate is provisional original-project reconstruction, not final anime art.
- Materials, ornamentation, weathering, banners, foundations, and city detailing
  remain unfinished.
- The road is a short render strip using terrain collision.
- Curved and intersection kit pieces are not part of the reference placement.
- The wall is not yet connected to a complete Starting City district.
- No navigation, actors, quests, shops, interiors, or final gameplay integration
  exists.
- Replacement and regeneration remain explicitly allowed.

## Exact Recommended Next Milestone

**Milestone 16A — Starting City North-Gate District Layout and City-Side Plaza
Greybox**

Begin it only after the post-integration F6 and F5 regression checklist passes.
Keep the accepted gate assembly replaceable and do not begin final art, full city
construction, interiors, NPCs, enemies, quests, or navigation yet.
