# Cinematics — shot list and file structure

*What to render, what to call it, and where it goes.*

---

## Six clips cover twenty worlds

One launch, shared. Five landings, keyed to **biome rather than world** — a
landing is mostly atmosphere and ground colour, which is what a biome already
defines. That is the same 75% saving section 5 of the design doc argues for on
terrain art.

| Clip | Worlds it covers | Count |
|---|---|:--:|
| `launch` | all twenty | — |
| `landing_ashfall` | Mars, Venus, Io, 55 Cancri e | 4 |
| `landing_drift` | Mercury, Psyche, Ceres | 3 |
| `landing_rime` | Enceladus, Titan, Ganymede, Europa, Callisto, Triton, Pluto | 7 |
| `landing_verdance` | Proxima b, Kepler-186f, Gliese 581c, TRAPPIST-1e, Kepler-22b | 5 |
| `landing_sol` | Earth | 1 |

---

## File structure

Same base name in both places, so source and build asset never have to be
matched up by hand.

```
video/                              masters, .mp4, gitignored
  launch.mp4
  landing_ashfall.mp4
  landing_drift.mp4
  landing_rime.mp4
  landing_verdance.mp4
  landing_sol.mp4

game/assets/cinematics/             build assets, .ogv, committed
  launch.ogv
  landing_ashfall.ogv
  landing_drift.ogv
  landing_rime.ogv
  landing_verdance.ogv
  landing_sol.ogv
```

A world distinctive enough to earn its own arrival overrides the biome with
`landing_world_<name>.ogv`. Use it sparingly — every override is another clip to
render and keep visually consistent with the rest.

---

## Shot briefs

**Every landing clip must hit the same beats in the same order.** They occupy
one interchangeable slot, so a Rime landing and an Ashfall landing have to be
swappable without the pacing changing:

1. Breach — the Spire comes through the cloud or haze layer, leg tips burning
2. Impact — it hits, shockwave outward
3. Settle — dust and debris fall back, ground scorched

Target **10 seconds** each. Launch plus landing makes the twenty-second opener
the in-engine sequence is timed against.

| Clip | Palette | What distinguishes it |
|---|---|---|
| **launch** | Void, hard white highlights | The Aegis and the Spire separating. **No planet in frame** — this clip plays over every world, so anything identifiable below breaks it everywhere but one. Starfield or empty void only. |
| **landing_ashfall** | Rust, ochre, ember glow | Volcanic. Ash haze rather than cloud; the impact throws embers and the ground glows through the cracks. |
| **landing_drift** | Void grey, white, hard edges | Airless. **No atmosphere means no cloud breach and no dust plume** — debris flies in straight lines and does not settle. The most distinctive of the five, and the one that will fight a generic prompt hardest. |
| **landing_rime** | Blue-grey, pale | Ice. The breach is through frozen haze; the impact shatters a crust and throws ice rather than dirt. |
| **landing_verdance** | Green-black | Overgrown. Dense canopy below; the impact flattens vegetation outward in a ring and leaves it burning at the edges. |
| **landing_sol** | Blue-green, then charred | Earth. Already rendered. The one that carries the weight, per `terra-sovereign-spire.md`. |

Drift is the one to watch. Every generation tool will want to give an airless
body a dust cloud and an atmospheric shockwave, because that is what the
training data is full of. Expect to fight for it or accept a compromise.

---

## Conversion

```bash
ffmpeg -i video/landing_rime.mp4 -vf scale=1280:-2 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 game/assets/cinematics/landing_rime.ogv
```

`-q:v` runs 0-10. Seven survives haze and gradients, which is Theora's worst
case. Expect 1.5-3 MB per ten-second clip — small enough to commit.

Masters stay in `video/`, which is gitignored. Only the `.ogv` is committed.

---

## Assignment

Clips are **world data, not scene wiring**. Set `launch_cinematic` and
`landing_cinematic` on that world's `MissionConfig` resource.

Either may be null: a world with only one plays only that one, and a world with
neither falls through to the grey-box landing sequence in
`scripts/landing_sequence.gd`. All four combinations are verified, so a
half-finished set never blocks playtesting.

---

## Outstanding

`launch.ogv` currently has Earth in frame and needs re-rendering without it.
Until it is replaced, it is only correct on Earth.
