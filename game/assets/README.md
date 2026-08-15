# Assets

Bought and generated assets live here. Conventions, formats, and the timing
argument are in `docs/terra-asset-pipeline.md` — read that before importing a
pack, particularly the cinematics section: **Godot 4 plays Ogg Theora (.ogv)
only**, so an MP4 from a generation tool will not play without conversion.

```
audio/       short cues (.wav), music and ambience (.ogg)
models/      .glb per entity, one folder per faction as it grows
materials/   shared .tres materials
cinematics/  .ogv, or numbered stills per sequence
```

Everything currently in `audio/` is a synthesised placeholder. Replacing one is
dropping a file with the same name — `AudioDirector` holds them as exported
`AudioStream` slots, so no code changes.
