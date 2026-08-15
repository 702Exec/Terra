# Cinematics

Build-ready clips live here, **inside `res://`**. Godot cannot load anything
from the repo root, so the masters in `/video/` are storage only — they are
invisible to the game.

**Format: Ogg Theora (`.ogv`). Godot 4 plays nothing else out of the box.**

## Naming

Launch is shared across every world. Landing varies **by biome, not by world** —
five sets cover all twenty, which is the same argument section 5 of the design
doc makes for terrain art.

```
launch.ogv              the Spire leaving the Aegis, every world
landing_ashfall.ogv     Mars, Venus, Io, 55 Cancri e
landing_drift.ogv       Mercury, Psyche, Ceres
landing_rime.ogv        Enceladus, Titan, Ganymede, Europa, Callisto, Triton, Pluto
landing_verdance.ogv    Proxima b, Kepler-186f, Gliese 581c, TRAPPIST-1e, Kepler-22b
landing_sol.ogv         Earth
```

Masters in `/video/` use the same base names with `.mp4`, so the mapping between
source and build asset never has to be worked out.

A world distinctive enough to deserve its own arrival gets
`landing_world_<name>.ogv` and overrides the biome default. Use it sparingly —
every override is another clip to render and keep consistent.

## Conversion

```bash
ffmpeg -i video/landing_rime.mp4 -vf scale=1280:-2 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 game/assets/cinematics/landing_rime.ogv
```

`-q:v` runs 0-10. Seven holds up on haze and gradients, which is the hardest
case for Theora. Expect 1.5-3 MB per ten-second clip.

## Assignment

Clips are **mission data, not scene wiring**: set `launch_cinematic` and
`landing_cinematic` on the world's `MissionConfig` resource. Either may be
null — a world with no footage yet still plays whichever it has, and a world
with neither falls through to the grey-box landing sequence. All four
combinations are verified.

The `clips` array on the `CinematicPlayer` node is a fallback for running that
scene on its own; in a mission the config wins.
