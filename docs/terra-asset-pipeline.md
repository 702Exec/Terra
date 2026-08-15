# Asset Pipeline

*Where bought and generated assets go, what format they need to be in, and where the code seams are for swapping grey boxes for art.*

---

## The short answer on timing

**Buy whenever it is cheap. Integrate at Phase 4.**

Owning a pack costs nothing but disk. Wiring one in costs a refactor every time the roster changes — and the roster is still moving. The design doc's "do not touch art until Phase 4" is about integration, not procurement.

What you cannot know yet, and should know before spending real money:

- **How many units you actually need.** The player roster went from seventeen to eight in one revision. The enemy set is three archetypes and the doc calls for a fourth plus five apex defenders.
- **What silhouettes have to read at gameplay zoom.** The camera sits at a 55° tilt with an orthographic size of 26–124. At the far end a unit is a handful of pixels. Detailed models are wasted; silhouette and colour are everything. Buy for readable shapes, not polygon counts.
- **Whether you need rigged and animated models or static meshes.** This is the single biggest price and effort difference in any pack, and the answer depends on whether player units ever get built.

---

## Format requirements

### Models

**glTF 2.0 (`.glb` preferred, `.gltf` accepted).** Godot imports these natively and best. FBX works but needs a converter configured, and OBJ loses materials and rigging.

Check before buying: packs sold primarily for Unity or Unreal often ship `.fbx` plus engine-specific material setups that do not survive the trip. A pack that lists glTF export is worth more than a cheaper one that does not.

### Audio

**`.ogg` for anything long** (music, ambience) — it streams and compresses well. **`.wav` for short cues** — it decodes instantly, which matters for anything that must land on a frame. The existing placeholder cues in `assets/audio/` are `.wav` at 44.1 kHz mono, and replacing one is dropping a file with the same name.

### Cinematics — read this before rendering twenty of them

**Godot 4 plays Ogg Theora (`.ogv`) and nothing else out of the box.** There is no built-in MP4 or H.264 support; that is a licensing decision on the engine's part, not an oversight. A `.mp4` from Higgsfield will not play without a third-party GDExtension.

So the pipeline is: render at whatever quality the tool gives you, keep that master outside the game, and convert to `.ogv` for the build.

```bash
ffmpeg -i cinematic_master.mp4 -c:v libtheora -q:v 8 -c:a libvorbis -q:a 5 earth_landing.ogv
```

Theora is an old codec and looks worse than H.264 at the same bitrate, so budget quality headroom in the master. For the Earth landing specifically — mostly held frames, one moving element, hard cuts — Theora will hold up better than it would on a busy action sequence.

**The alternative worth considering:** if the cutscenes are stills with slow pushes and cuts, do not encode video at all. Ship the frames as images and drive the pushes and cuts in-engine. It looks sharper, the files are far smaller, timing becomes tunable without re-rendering, and it sidesteps the codec problem entirely. Given the beats in `terra-sovereign-spire.md`, this is probably the better route.

---

## Folder layout

```
game/assets/
  audio/        short cues (.wav), music and ambience (.ogg)
  models/       .glb per entity, one folder per faction when it grows
  materials/    shared .tres materials
  cinematics/   .ogv, or numbered stills per sequence
```

### Repository size

Asset packs and video will outgrow what a plain git repo handles gracefully. Before the first large import, pick one:

- **Git LFS** for binaries — keeps one repo, needs LFS support on the remote.
- **Keep heavy source out of the repo** — masters in cloud storage, only build-ready compressed assets committed.

Deciding after a 2 GB pack is already in the history is much worse than deciding before. Git does not forget.

---

## Swap seams

The grey box is built so art replaces it by assigning a resource, not by editing code.

### Already in place

**Audio.** Every cue is an `@export var … : AudioStream` on `AudioDirector`, fired from command-bus signals. Replacing a sound is dropping a file into `assets/audio/`. No code changes, ever.

**Enemy visuals.** `EnemyStats.visual_scene` — assign a `PackedScene` and the unit instances it instead of building a grey capsule from `body_color` / `body_radius` / `body_height`. Leave it null and you get the grey box. This is per archetype, so a pack can be introduced one unit at a time.

### Not built yet, and deliberately so

**Turrets and structures.** These need a convention rather than just a mesh slot, because parts move: a turret's head rotates to aim. When it is time, the convention should be that an art scene exposes its aiming node in a group (`aim_pivot`), and the turret uses it if present and falls back to its grey-box `Head` if not.

Building that now would be guessing at a roster that has one turret and may have three tiers. The seam is cheap to add once the shape is known — and adding it early against the wrong shape is how you end up with two abstractions instead of one.

**Materials and shaders.** Grey-box materials are unshaded overlays and lit solids chosen for readability. An art pass replaces the whole approach; there is nothing worth abstracting in advance.

---

## What to check before buying a pack

1. **Licence permits commercial use in a shipped game.** Many "free" packs permit prototyping only. Check redistribution terms too — a compiled game embeds the assets.
2. **glTF export is available.**
3. **Consistent scale across the pack**, and ideally metric. Mixing packs is where scale problems come from, and they are tedious to fix across dozens of assets.
4. **Silhouettes read at small size.** Squint at the promo render. If two units are indistinguishable at thumbnail size, they will be indistinguishable in play.
5. **The pack covers a faction, not a grab bag.** Terra needs three visual languages — the harvest fleet, native defenders across four biomes, and human industrial for Earth. One coherent pack per language beats three mixed ones.
