# Cinematics

Build-ready clips, **inside `res://`**. Godot cannot load from the repo root, so
the masters in `/video/` are storage only — invisible to the game.

**Format: Ogg Theora (`.ogv`). Godot 4 plays nothing else out of the box.**

Shot list, naming, per-biome briefs, and the conversion command are in
`docs/terra-cinematics.md`. The short version:

```
launch.ogv              shared by every world, no planet in frame
landing_ashfall.ogv     Mars, Venus, Io, 55 Cancri e
landing_drift.ogv       Mercury, Psyche, Ceres
landing_rime.ogv        Enceladus, Titan, Ganymede, Europa, Callisto, Triton, Pluto
landing_verdance.ogv    Proxima b, Kepler-186f, Gliese 581c, TRAPPIST-1e, Kepler-22b
landing_sol.ogv         Earth
```

Assign per world on `MissionConfig.launch_cinematic` and `.landing_cinematic`,
not on the scene. Null on both falls back to the grey-box landing.
