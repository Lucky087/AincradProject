# Project Bible

**Project:** Aincrad-Inspired RPG  
**Prototype:** Floor 1 Vertical Slice  
**Engine:** Godot 4.7  
**Language:** Typed GDScript  
**Document status:** Living document  
**Last updated:** 2026-07-10

---

## 1. Purpose of This Document

This file defines what the game is, what the first prototype must prove, and what is outside the current scope.

Every major design or technical decision should support this document. When the project changes direction, update this file and record the reason in `docs/DECISION_LOG.md`.

---

## 2. Project Vision

Create a third-person online-action-RPG foundation inspired by the feeling of exploring a giant floating world made of many separate floors.

The long-term game should support:

- A large connected world divided into floors and zones.
- Solo players and real multiplayer players.
- Towns, roads, fields, dungeons, enemies, NPCs, quests, and bosses.
- Persistent player progression.
- Expandable content without rewriting the core game.
- Up to 100 separate floors over the lifetime of the project.

The first goal is **not** to recreate the full world. The first goal is to build one small, polished Floor 1 prototype that proves the core structure works.

---

## 3. Original-World Rule

The game may be inspired by the structure and feeling of Aincrad, but production content should become its own original world.

Do not copy protected characters, dialogue, music, logos, interface graphics, maps, models, or story scenes. Temporary developer names may be used during prototyping, but public releases should use original names and assets.

This lets the project keep the floating-floor fantasy while developing its own identity.

---

## 4. Prototype Goal

The Floor 1 prototype must eventually let a player:

1. Start in a small city area.
2. Speak to one NPC.
3. Accept one simple quest.
4. Leave the city by following a road.
5. Enter a small field.
6. Fight one enemy type with a sword.
7. Take and deal damage.
8. Gain experience.
9. Level up.
10. Return to the NPC and complete the quest.
11. Save the game.
12. Close and reopen the game.
13. Load the saved progress.

The prototype is complete when this entire loop works reliably from beginning to end.

---

## 5. Current Phase

The current phase is **Project Foundation**.

During this phase, we are only creating:

- The project folder structure.
- Documentation.
- Naming rules.
- Technical boundaries.
- A task list.
- A decision history.

We are **not** implementing movement, combat, enemies, quests, saving, multiplayer, or world art yet.

---

## 6. Core Experience Pillars

### 6.1 Exploration

The player should feel that the world continues beyond the visible area. Roads, gates, distant landmarks, blocked paths, and floor transitions should suggest a much larger world.

### 6.2 Readable Action Combat

Combat should be easy to understand:

- Attacks must have clear timing.
- Damage must have clear feedback.
- Enemy attacks must be readable.
- The player must understand why an attack hit or missed.

### 6.3 Meaningful Progression

Experience, levels, equipment, quests, and unlocked areas should give the player visible progress.

### 6.4 Living World

NPCs, other players, enemy activity, town sounds, and changing quest states should make the world feel inhabited.

### 6.5 Expandable Content

A new floor should mainly require new content and configuration, not a rewrite of the player, combat, quest, save, or networking systems.

---

## 7. Prototype Scope

The first Floor 1 prototype will eventually contain:

- One controllable third-person player.
- One small section of the Starting City.
- One city gate.
- One road.
- One small field.
- One enemy type.
- One sword.
- One basic attack.
- Player health.
- Enemy health.
- Experience points.
- Basic levelling.
- One NPC.
- One simple quest.
- Saving and loading.
- Basic user interface.
- Temporary or simple prototype art where required.

---

## 8. Prototype Non-Goals

The following are deliberately excluded from the first prototype:

- All 100 floors.
- A full recreation of an existing anime world.
- Massive multiplayer servers.
- Guilds.
- Trading.
- Crafting.
- Complex skill trees.
- Large inventories.
- Multiple weapon classes.
- PvP.
- Raids.
- Advanced boss fights.
- Voice acting.
- Cinematic cutscenes.
- Procedural generation of the complete world.
- Final-quality art for every object.
- Seamless loading of an entire floor at once.

These can be considered only after the basic prototype loop is complete.

---

## 9. Intended Player Journey

The prototype should eventually follow this simple route:

```text
Game Start
    ↓
Starting City Section
    ↓
Quest NPC
    ↓
City Gate
    ↓
Road
    ↓
Floor 1 Field
    ↓
Enemy Encounter
    ↓
Quest Progress
    ↓
Return to NPC
    ↓
Quest Completion
    ↓
Save Progress
```

This route is the project's first complete vertical slice.

---

## 10. World Structure

The world must be treated as separate content packages.

```text
World
├── Floor 001
│   ├── Starting City Zone
│   ├── Road Zone
│   ├── Field Zone
│   └── Future Dungeon Zone
├── Floor 002
├── Floor 003
└── ...
```

A floor should not be one enormous scene.

Each floor will later have:

- A floor definition.
- Multiple zones or chunks.
- Spawn points.
- Transition points.
- Navigation data.
- Floor-specific environment settings.
- Floor-specific NPC and enemy placements.
- Floor-specific quests and encounters.

Only nearby or required zones should be loaded.

---

## 11. Floor 1 Prototype Map

The first map should remain intentionally small.

```text
[Starting City Section]
          |
      [City Gate]
          |
        [Road]
          |
       [Field]
          |
 [Future Locked Route]
```

Suggested prototype landmarks:

- Central fountain or plaza marker.
- Quest NPC near the gate.
- Gate arch.
- Road sign.
- Small bridge, ruin, or large tree in the field.
- Blocked path suggesting the rest of Floor 1.

The blocked route is useful because it makes the prototype feel connected to a larger world without requiring that world to exist yet.

---

## 12. Long-Term Floor Rules

Every floor should eventually follow these rules:

1. Use a three-digit floor ID such as `floor_001`.
2. Store floor content inside its own folder.
3. Divide large spaces into zones or chunks.
4. Keep reusable systems outside floor folders.
5. Use data resources for floor configuration.
6. Give persistent objects stable IDs.
7. Avoid direct dependencies between two separate floors.
8. Move between floors through a world-transition system.
9. Load only the content required by the current play area.
10. Allow a floor to be tested independently.

---

## 13. Core Gameplay Loop

The long-term core loop is:

```text
Explore
  → Find objective
  → Fight or interact
  → Earn rewards
  → Improve character
  → Unlock new area
  → Explore further
```

The Floor 1 prototype only needs to prove the smallest version of this loop.

---

## 14. Technical Principles

The project will follow these principles:

### 14.1 Small Scenes

Build characters, enemies, NPCs, interfaces, props, and zones as reusable scenes.

### 14.2 Composition Over Giant Scripts

A player should not eventually have one script containing movement, combat, health, inventory, quests, saving, networking, and animation.

Separate responsibilities into components.

### 14.3 Data Separate From Behaviour

Enemy statistics, quest definitions, item definitions, and floor definitions should later use custom `Resource` files where practical.

### 14.4 Minimal Global State

Autoloads are allowed only for true application-wide services. Do not make every system global.

### 14.5 Multiplayer-Aware, Not Multiplayer-First

The single-player prototype comes first, but code should avoid assumptions that make multiplayer impossible later.

### 14.6 Versioned Save Data

Save files must include a save-format version so old saves can later be upgraded.

### 14.7 Stable Content IDs

Persistent content must use stable string IDs. File paths and visible names are not reliable save identifiers.

---

## 15. Multiplayer Direction

Multiplayer is not part of the first implementation phase, but the architecture must leave room for it.

Future multiplayer assumptions:

- Each player has a unique network identity.
- The server or host owns important game-state decisions.
- Clients request actions instead of directly deciding permanent results.
- Damage, rewards, quest completion, and item ownership must later be validated by the authority.
- Local camera and local interface remain client-side.
- Saved player data is separate from temporary world state.
- Systems should work with actor references rather than assuming there is only one global player.

Do not add networking code before the local gameplay loop works.

---

## 16. Save-Game Direction

The future save system should store data such as:

- Save-format version.
- Player ID.
- Current floor ID.
- Current zone ID.
- Spawn-point ID.
- Player level.
- Current experience.
- Current and maximum health where appropriate.
- Quest states.
- Inventory state.
- Important world flags.

The save system should not attempt to serialize entire live scenes.

Instead, it should store clean data and rebuild the world from that data.

---

## 17. Target Platform

Initial target:

- Windows PC.
- Keyboard and mouse.
- Development resolution chosen later.
- Controller support considered after the keyboard-and-mouse prototype works.

Other platforms should not control early design decisions.

---

## 18. Quality Bar for the Prototype

The prototype does not need final art, but it should be:

- Easy to understand.
- Stable enough to replay.
- Free of major script errors.
- Organised enough for another developer to navigate.
- Built without duplicated systems.
- Small enough to finish.
- Structured so features can be replaced without rebuilding the entire project.

---

## 19. Definition of Prototype Complete

The Floor 1 prototype is complete when all of the following are true:

- The game launches into a playable scene.
- The player can move through the city, road, and field.
- The player can speak to the NPC.
- The quest can be accepted.
- The enemy can be fought and defeated.
- Health and damage work.
- Experience is awarded.
- Levelling works.
- The quest tracks and completes.
- Progress can be saved.
- Progress can be loaded after restarting.
- No critical errors appear during the full test route.
- The complete loop can be demonstrated from a clean project start.

---

## 20. Documentation Rules

The following files are part of the project source of truth:

- `docs/PROJECT_BIBLE.md` — vision and scope.
- `docs/TECHNICAL_ARCHITECTURE.md` — project structure and technical rules.
- `docs/NAMING_CONVENTIONS.md` — naming and code-style rules.
- `docs/CURRENT_TASKS.md` — active work and milestone checklist.
- `docs/DECISION_LOG.md` — important decisions and reasons.

When documents disagree:

1. The newest accepted decision in `DECISION_LOG.md` wins.
2. Update the other documents to match.
3. Do not silently ignore the conflict.

---

## 21. Glossary

**Actor:** A player, enemy, NPC, or other active world entity.

**Component:** A small reusable scene or script responsible for one behaviour, such as health.

**Floor:** A major world level containing multiple zones.

**Zone:** A playable area within a floor.

**Chunk:** A smaller loadable section of a large zone.

**Persistent ID:** A stable identifier saved between sessions.

**Prototype:** A small implementation used to prove that the main game loop and architecture work.

**Vertical slice:** A short but complete section of the game containing all major feature types at a basic level.

**Authority:** The machine responsible for deciding the official result of a multiplayer action.

---

## 22. Immediate Rule

Finish a small, complete Floor 1 experience before expanding the map or adding additional floors.
