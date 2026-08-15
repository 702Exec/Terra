# Terra — Project Context

## What this is

Terra is a **base-defense survival RTS** built in Godot 4 with GDScript. Single-player against AI. Desktop first (Windows/macOS/Linux), with a mobile port planned later — so mobile constraints apply to UI decisions from the start.

The player is an alien harvest fleet stripping resources from inhabited worlds to save its dying homeworld. Each mission: land, build a harvesting base, defend it against escalating waves of native defenders, extract a quota, jump to the next world. Twenty worlds, Earth last.

**Not** a competitive RTS. There is no matchmaking, no PvP, no opponent economy AI. Enemies are scripted waves.

## Repo layout

```
/                  repo root — run Claude Code from here
  CLAUDE.md        this file
  docs/            design docs (read these before big decisions)
  game/            the Godot project — project.godot lives here
```

Point Godot and the Godot MCP server at `game/`, not the repo root.

## Current phase

**Phase 0 — grey-box prototype.** Capsules and boxes only. No art, no menus, no meta layer. The goal is to answer one question: is holding the line fun?

Do not build art, story content, the star map, or the economy until Phase 0 plays well. If asked for something outside the current phase, say so before building it.

## Current state of the code

`game/main.tscn` and `game/scripts/` contain a working top-down command prototype generated earlier: an orthographic camera, a lit 40×40 ground plane, one selectable unit that takes move orders, and a ground marker. It's clean, typed code and the infrastructure is worth keeping — but it was built toward a traditional RTS command loop, which is not Terra's game.

Retarget rather than rebuild:

- **`rts_controller.gd`** — the camera raycast and ground-hit plumbing is the foundation for structure placement. Clicking the ground to place a turret is the same operation as clicking it to issue a move order. Keep the raycast; repurpose the order path.
- **`command_unit.gd`** — the "move toward a target across the XZ plane" driver is what enemy units need. Keep the movement, drop the selection concern.
- **`move_marker.gd`** — becomes the placement ghost / valid-position indicator.
- **`main.tscn`** — keep the environment, light, and ground. **Fix the camera:** it currently looks straight down. Terra uses a fixed three-quarter view tilted 50–60° from horizontal, per the art direction doc.

Player-controlled unit selection and micro are **not** a Phase 0 feature. The player builds and places; they do not micromanage individual units.

## Architecture rules

**1. All state changes go through a single command path.**
Building a unit, placing a structure, spending resources, spawning a wave, applying damage — every mutation of game state routes through one command/action function rather than being mutated directly across the codebase. Co-op multiplayer is a planned later feature, and this convention is most of what makes adding networking later a feature instead of a rewrite. Follow it from day one, even though nothing is networked yet.

**2. Pathfinding is one-to-one, not many-to-many.**
Enemies path from fixed spawn points toward the player's base. Compute one flow field (or navigation solution) per map and have all units read from it. Do not give each unit an independent pathfinding agent — this is the single biggest performance decision in the project, and it's what makes hundreds of simultaneous units viable.

**3. Explicit type annotations everywhere.**
`var health: int = 100`, not `var health = 100`. Function signatures and return types included. Non-negotiable.

**4. Data lives in resources, not in code.**
Unit stats, wave compositions, tier definitions, and world configs are `.tres` Resource files, not hardcoded constants. They need to be tunable without touching logic.

**5. Signals over polling.**
Use Godot's signal system for cross-node communication. Avoid `_process` loops that check state every frame when an event would do.

## Design rules that constrain code

- **Difficulty scales on approach lanes, resource placement, and wave frequency** — not on enemy stat inflation. Build these as separate configurable knobs, not one difficulty float.
- **Missions run 15–25 minutes.** Pace wave timing to that target.
- **Mobile UI constraints apply now.** Minimum 48dp touch targets, no hover-dependent information, no keyboard-only actions. Desktop-first doesn't mean desktop-only.
- **Fixed camera.** Three-quarter top-down, no rotation, tight zoom range.

## Conventions

- GDScript, standard Godot build (not .NET/C#)
- Scenes in `game/scenes/`, scripts in `game/scripts/`, resources in `game/resources/`, assets in `game/assets/`
- `snake_case` for files, functions, and variables; `PascalCase` for classes and node names
- One scene per prefab-style entity (unit, structure, projectile)
- World forward is `-Z`; the ground plane is XZ at `y=0`

## Explicitly out of scope

Do not build, and flag if asked: competitive PvP, procedural map generation, a map editor, mod support, destructible terrain, in-app purchases or ad integration, any 4X or fleet-management layer beyond the star map.

## Reference docs

In `docs/`:
- `terra-game-design-doc.md` — full design: star map, difficulty tables, world structure, badges, build order
- `terra-sc2-style-prompts.md` — visual, UI, audio, and animation style spec (later phases)
