# Terra — Project Context

## What this is

Terra is a **base-defense survival RTS** built in Godot 4 with GDScript. Single-player against AI. Desktop first (Windows/macOS/Linux), with a mobile port planned later — so mobile constraints apply to UI decisions from the start.

The player is an alien harvest fleet stripping resources from inhabited worlds to save its dying homeworld. Each mission: deploy, harvest, defend against escalating waves of native defenders, extract a quota, jump to the next world. Twenty worlds, Earth last.

The mission-level "base" is a **four-legged world engine**, dropped to the surface from the fleet's mothership. It extracts planetary material and beams it back up to orbit. The mothership is overhead and diegetic — which is what makes orbital support abilities fit the fiction rather than being bolted on. *(Its in-game name is still under review; the docs currently call it the Sovereign Spire.)*

**Not** a competitive RTS. There is no matchmaking, no PvP, no opponent economy AI. Enemies are scripted waves.

## Repo layout

```
/                  repo root — run Claude Code from here
  CLAUDE.md        this file
  docs/            design docs (read these before big decisions)
  game/            the Godot project — project.godot lives here
```

Point Godot at `game/`, not the repo root. The repo root has no `project.godot` by design, so `docs/` stays out of `res://`.

## Current phase

**Phase 0 is answered — holding the line is fun.** The prototype is now reaching into Phase 1 (economy, a build/upgrade sink) ahead of the written build order, deliberately and with the owner's agreement.

Not yet built, and each is a real phase boundary — flag before starting one:

- Player-controlled units, selection, and orders (Phase 2). CLAUDE.md previously ruled this out entirely; the owner has since chosen to head toward a commander/macro model, so it is a matter of *when*, not *whether*.
- Production buildings, unit queues, terrain height and high ground (Phase 2).
- Star map, cycle budget, quota, allocation screen, cutscenes and story (Phase 3+).

## Current state of the code

Everything below is built and verified running.

**The command bus** — `scripts/game_command_bus.gd`, autoloaded as `GameCommands`. Every mutation goes through `submit(Command, payload)`. Credits, wave number, base health, enemy health, structure health, and upgrade levels all live here and nowhere else. Signals out, queries for read-only access.

**The battlefield** — 144×144, base at centre, four lane spawns at the edges. Map size is one number: `MissionConfig.map_half_extent`. `scripts/battlefield.gd` resizes the ground mesh and collider, positions the lanes, and places the extractors from it; the camera's pan limits and the minimap scale read the same value.

**Pathfinding** — `scripts/nav_path_service.gd` bakes the NavigationRegion3D once and solves **one path per lane**, shared by every enemy walking it. Four solves, not four hundred. Enemies divert to attack player structures within `structure_aggro_range` of their lane, then rejoin — a straight-line diversion, never a per-unit path query.

**Waves** — `scripts/wave_director.gd` plus `WaveConfig`. Size grows geometrically (6, doubling, capped at 400). Which directions a wave comes from is a property of the wave number, held as lane stages. Countdown, an advance warning naming the directions, and a spawn interval that tightens so no wave takes over 12 seconds to land.

**Economy** — forward extractors are the income (base trickle + per-extractor rate). They can be destroyed, and losing one cuts income for the rest of the mission.

**Upgrades** — tap the world engine to open the Spire panel. Four global tracks in `UpgradeTrack` resources. Turrets read *effective* stats (base + purchased effect) and never write back into the shared `TurretStats`.

**Camera** — fixed three-quarter angle, no rotation, with pan and zoom. Pan limits derive from zoom, so at full zoom-out the whole map fits and the camera locks. Drag pans, tap places, distinguished by travel distance so the same gesture works under touch.

**HUD** — wave countdown, base health, credits and income, minimap (bottom right, tap to jump), off-screen threat markers, upgrade panel, turret sell prompt.

**Audio** — `scripts/audio_director.gd`, driven off bus signals. Placeholder synthesised tones in `assets/audio/`. Phase 5 replaces the files, not the wiring.

## Architecture rules

**1. All state changes go through the command bus.** Every mutation routes through `GameCommands.submit()`. Co-op is a planned later feature, and this convention is most of what makes adding networking a feature rather than a rewrite. Follow it even though nothing is networked yet.

**2. Pathfinding is one-to-one, not many-to-many.** One solve per lane, shared. This is the single biggest performance decision in the project. Player units, when they exist, are a separate population — a few dozen, so individual agents are fine. Hundreds of enemies are not.

**3. Explicit type annotations everywhere.** `var health: int = 100`, function signatures and return types included. Non-negotiable.

**4. Data lives in resources, not in code.** Unit stats, turret stats, wave composition, upgrade tracks, and mission config are `.tres` files.

**5. Signals over polling.** Prefer timers and signals to `_process` loops that check state every frame.

## Design rules that constrain code

- **Difficulty scales on approach lanes, resource placement, and wave frequency** — not on enemy stat inflation. Separate knobs, not one difficulty float. Enemy stats stay flat across worlds: you out-compose a world, you do not out-level it.
- **Missions run 15–25 minutes.**
- **Mobile UI constraints apply now.** Minimum 48dp touch targets, no hover-dependent information, no keyboard-only actions. Anything requiring drag-select or click-drag micro is a mobile risk — flag it.
- **Fixed camera angle.** Three-quarter, no rotation. Pan and zoom are allowed; tilt is not.

## Conventions

- GDScript, standard Godot build (not .NET/C#)
- Scenes in `game/scenes/`, scripts in `game/scripts/`, resource scripts in `game/scripts/data/`, resources in `game/resources/`, assets in `game/assets/`
- `snake_case` for files, functions, and variables; `PascalCase` for classes and node names
- One scene per prefab-style entity
- World forward is `-Z`; the ground plane is XZ at `y=0`

## Gotchas worth not rediscovering

- **Hand-written `.tscn` node exports need `node_paths=PackedStringArray("prop", ...)` on the node header**, or Godot never resolves the NodePath into a Node and the property is silently null.
- **`Transform3D` in a `.tscn` stores its nine basis values as rows, not columns.** Getting this backwards transposes the basis and points the camera somewhere unintended.
- **Headless runs cannot catch rendering bugs.** A clean headless run says nothing about what the camera sees. Capture a rendered frame before claiming anything is visible.
- **Quitting headless mid-audio-cue reports leaked `AudioStreamWAV` instances.** That is the dummy audio driver, not a real leak — it does not occur under a real driver.

## Explicitly out of scope

Do not build, and flag if asked: competitive PvP, procedural map generation, a map editor, mod support, in-app purchases or ad integration, any 4X or fleet-management layer beyond the star map.

## Reference docs

In `docs/`:
- `terra-game-design-doc.md` — star map, difficulty tables, world structure, badges, build order
- `terra-ancients-roster.md` — the player's unit and structure roster
- `terra-ancients-progression.md` — the 20 worlds, biome sets, and the tier-keyed unlock model
- `terra-enemy-roster.md` — enemy archetypes, apex defenders, tier composition, counter matrix
- `terra-sc2-style-prompts.md` — visual, UI, audio, and animation style spec (later phases)
