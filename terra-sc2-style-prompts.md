# Terra — SC2 Look & Feel: Prompt Spec for Summer Engine

Summer Engine builds from natural-language description and refines iteratively, so this is written as **paste-in blocks**, not an essay. Use Block 0 once at the start of the project. Use Blocks 1–6 when you're working on that specific system. Block 7 is the corrective you paste when the AI drifts.

One note before you start: describe the *style*, never the source. Prompt for "grounded military sci-fi RTS in the Blizzard house style" and the specific attributes below — not "make it look like StarCraft 2." Naming the IP gets you closer to copying protected assets, character designs, and trade dress, and it also makes the AI reach for generic space-marine clichés instead of the actual rendering rules that make SC2 read so well.

---

## BLOCK 0 — Master Style Prompt (paste once, at project start)

> Terra is a real-time strategy game for iOS and Android. The art direction is **stylized realism with exaggerated readability** — not photorealism, not cartoon. Think grounded military sci-fi rendered with heroic proportions: every unit and building is built around a bold, instantly recognizable silhouette that reads at a glance from a pulled-back camera on a phone screen.
>
> Core rules that govern every asset:
>
> 1. **Silhouette first.** Each unit type must be identifiable in pure black at 64 pixels tall. Vary overall shape, stance, and height between unit types before varying color or detail. No two units in the same army share a silhouette.
> 2. **Chunky, over-scaled forms.** Shoulders, weapon barrels, armor plates, and engine housings are 20–40% larger than realistic proportion. Legs and connective details are thinner. This is deliberate — mass reads on small screens, realism does not.
> 3. **Detail is baked into texture, not geometry.** Low-to-mid polygon meshes with hand-painted-feel textures carrying panel lines, wear, rivets, scratches, and directional grime. Ambient occlusion and light direction painted into the diffuse map so units read as solid even under flat lighting.
> 4. **Player color is a design feature, not an accent.** Every unit and structure reserves large, flat, unobstructed surfaces — 15–25% of visible area — for player color. Place it on shoulder pads, hull flanks, roof panels, banner surfaces. Never bury it in trim.
> 5. **Emissive tells.** Glowing elements (engine exhaust, weapon charge, cockpit glass, energy conduits) are the primary way state is communicated. Idle = dim steady glow. Charging = brightening pulse. Firing = sharp bright flash. Damaged = flicker plus sparks.
> 6. **Environment recedes, units advance.** Terrain is desaturated 20–30% relative to units, lower in contrast, and darker in value. Units are the brightest, most saturated things on screen at all times.

---

## BLOCK 1 — Camera, Lighting & Post-Processing

> **Camera:** fixed three-quarter top-down, tilted 50–60° from horizontal. Narrow field of view (30–40°) so the world reads as nearly isometric with just enough perspective to give buildings volume. Camera does not rotate — a fixed viewing angle is what makes silhouettes learnable. Pinch to zoom within a tight range only; never let the player zoom in far enough to see texture resolution fail, or out far enough that units drop below 40 pixels.
>
> **Lighting:** one strong directional key light from high and behind-left, warm. A cool ambient fill from the opposite side so shadowed surfaces stay readable rather than going black. A subtle rim/back light on all units to separate them from terrain — this is non-negotiable for readability. Bake environment lighting; keep real-time lights to the key light plus a small pool of dynamic lights reserved for explosions and abilities.
>
> **Post:** moderate bloom applied selectively to emissive materials and energy effects only, not to the whole frame. Gentle atmospheric haze that increases with distance to push background terrain back. Slight vignette. Warm-shadow, cool-highlight color grade for a metallic industrial feel. Keep overall contrast punchy but never crush blacks — dark units on dark terrain is the single most common readability failure.

---

## BLOCK 2 — Terrain & Environment

> Terrain is tile-based with **hard, high-contrast height changes**. Cliffs are sheer with a distinct lip and a dark shadow band at the base so elevation reads instantly. Ramps are visually obvious — wider than a unit, with directional markings or worn tread paths.
>
> Ground textures are layered: a base material, a secondary blend material, and scattered detail decals (cracks, scorch, oil stains, tire ruts). Doodads — rocks, wreckage, pipes, dead vegetation, crashed hulls — are placed to break up open space but never on walkable paths where they'd confuse pathing readability.
>
> Resource nodes are the most visually distinct objects on the map: strong color, gentle idle animation, and a subtle glow so a player scanning the minimap-to-world can find economy at a glance. Show depletion visually — nodes shrink and dim in stages.
>
> Environment palettes are per-biome and tightly controlled: a rust-and-ochre industrial waste, a cold blue-grey frozen installation, a green-black jungle outpost. Each biome gets at most three dominant hues plus neutrals. Never let a biome's palette collide with a player color.

---

## BLOCK 3 — Faction Visual Languages

Terra should carry a human/industrial faction as its identity anchor. If you build opposing factions, give each a *material and shape language*, not just a palette swap.

> **Human industrial (primary):** Riveted steel, olive drab, gunmetal, rust and oxidized orange. Boxy, welded, asymmetric construction that looks field-repaired. Exposed pistons, cables, vents, warning stripes, stenciled unit numbers. Amber and orange emissives. Buildings are prefab modules that visibly deploy and unfold from transport form. Weapon fire is ballistic — tracers, muzzle flash, shell casings, smoke.
>
> **Advanced/energetic (opposing option):** Polished gold, white ceramic, deep blue. Smooth curved surfaces, bilateral symmetry, floating or suspended components with no visible mechanical joints. Cyan and blue-white emissives. Buildings warp into existence rather than being constructed. Weapon fire is energy — beams, plasma bolts, shield ripple impacts.
>
> **Organic/swarm (opposing option):** Chitin, bone, sinew, dark purple and sickly green. Asymmetric, wet specular highlights, exposed muscle and vent-like orifices. Constant subtle idle motion — breathing, twitching. Buildings grow from a spreading biological ground layer that visibly expands and recedes with territory control. Weapon fire is projectile-organic — spines, acid, spray.

---

## BLOCK 4 — UI / HUD & Menus

> The HUD is a **framed console**, not a floating flat overlay. It occupies the bottom band of the screen as a solid, physically-modeled panel with beveled edges, diagonal corner cuts, brushed-metal texture, and subtle inset shadows — like a piece of military hardware bolted to the bottom of the screen. Faction-themed: the human console is riveted steel with amber holographic readouts; other factions reskin the same layout with their own material language.
>
> **Layout for phone (landscape):**
> - Bottom-left: minimap, square, with a viewport rectangle and colored blips. Player color for own units, red for enemy, yellow for resources, white for allies.
> - Bottom-center: selection panel showing the selected unit portrait, name, health, shields/energy bars, and a wireframe or icon grid when multiple units are selected.
> - Bottom-right: **command card** — a fixed 3×4 or 4×4 grid of square ability buttons. Fixed grid position per ability is critical; a given ability always lives in the same cell so muscle memory forms.
> - Top-right: resource counters with small icons, current/max supply.
> - Top-left: minimal — alerts, menu access.
>
> **Icons:** square, with a 2px colored border, a dark inset background, and a bold single-subject silhouette in the center. High contrast, no fine detail, no gradients that fail at small size. Hotkey/cost text in the corner.
>
> **Typography:** wide, squared-off techno sans for headers, unit names, and resource numbers — geometric, slightly extended, uppercase. Clean neutral humanist sans for body copy, tooltips, and descriptions. Two families only.
>
> **Color coding:** health green→yellow→red, shields cyan, energy blue, resources gold and green. Enemy always red, always. Never use these hues for decoration elsewhere in the UI.
>
> **Mobile-specific:** all touch targets minimum 48×48 dp with 8dp spacing. Command card buttons should be larger than that — 60dp+. Do not use hover states. Every ability that requires a target uses a tap-to-select-then-tap-to-place flow with a clear ground indicator, never a drag. Add a confirm step for irreversible or expensive actions.

---

## BLOCK 5 — Audio & Voice

> **Music:** live-feel orchestral core layered with industrial percussion and electric guitar for the human faction. Ethereal choir, metallic bells, and warm synth pads for an advanced faction. Tribal percussion, dissonant strings, and organic textures for a swarm faction. Music is **adaptive**: a low-intensity exploration/build layer that adds percussion and brass as combat starts, and drops back out within a few seconds of combat ending. Never let the same loop run long enough to be noticed as a loop.
>
> **Unit voice — this is the single biggest personality driver.** Every unit type gets:
> - 2–3 selection acknowledgments ("Ready.", "Standing by.")
> - 3–4 move confirmations ("Moving out.", "On my way.")
> - 2–3 attack confirmations, more aggressive in delivery
> - 4–6 idle/annoyed lines that only trigger after repeated tapping — this is where personality and humor live
> - A death sound
>
> Deliver human-faction lines through a **radio filter**: band-limited, slight compression, a short squelch tail. Distinct voice character per unit type — a gruff veteran, an eager rookie, a bored pilot. Lines are short, under two seconds, and never block a second line from playing.
>
> **SFX:** weapons need a sharp transient and a short tail — punch over realism. Layer each weapon from a mechanical element (bolt, servo), a discharge element, and a low-end thump. Impacts get a distinct material response: metal, flesh, shield. Building placement is a heavy mechanical thud. UI clicks are tactile and mechanical, not soft digital blips. Errors are a short low buzz.
>
> **Mixing:** voice sits on top of everything and ducks the music bed. Combat SFX are dense but individually short so they don't turn to mush. Add a distance falloff so off-screen action is present but quiet. Provide separate music/SFX/voice sliders — mobile players play muted more often than you'd think, so nothing critical is audio-only.

---

## BLOCK 6 — Animation & Game Feel

> **Response is instant.** When the player issues a command, feedback fires on the same frame: selection ring flashes, the ground target marker appears, the voice line starts, and the unit begins turning. Never gate feedback behind the unit's actual movement start. This perceived responsiveness is more important to the feel than any visual asset.
>
> **Selection:** a colored circle or bracket on the ground beneath each selected unit, in player color, with a brief scale-in animation. A ground click plays a small animated marker that expands and fades in about 0.3 seconds.
>
> **Movement:** units accelerate quickly, turn fast, and stop crisply — snappy, not floaty. Ground vehicles kick up dust; walkers have a weighted step with a slight camera-independent bounce; air units bank into turns and have a gentle idle drift. Units have a visible facing and must turn before firing.
>
> **Combat:** every shot needs a muzzle flash, a visible projectile or tracer, and an impact effect at the destination. Hits produce a small flinch or recoil on the target. Deaths are chunky and specific: infantry ragdoll and leave a decal, vehicles explode and leave a burning wreck that lingers before fading, buildings collapse in stages with dust and secondary explosions.
>
> **Buildings:** construction is visible and staged — a foundation, then a scaffold, then the finished structure — with a progress indicator. Production buildings show visible activity: rotating parts, glowing vents, opening bays. A unit physically exits the building on spawn rather than popping into existence.
>
> **Restraint on screen shake.** RTS cameras should stay stable — shake breaks unit tracking and makes small-screen play nauseating. Reserve a brief shake for a small number of dramatic super-abilities only. Use bright flashes and shockwave ring effects for impact instead.
>
> **Damage states:** structures and large units visibly degrade — scorch marks, smoke plumes, fire, exposed frame — at roughly 66% and 33% health, so threat reads without a health bar.

---

## BLOCK 7 — Mobile Budget & Anti-Drift Corrections

Paste this when the engine starts producing something that doesn't hold up on a phone, or drifts toward generic sci-fi.

> **Performance constraints:** target 60fps on a mid-range phone from three years ago; cap the frame rate and don't chase more. Bake all environment lighting. One real-time shadow-casting light maximum. Limit dynamic lights to a pool of about eight, reserved for explosions and abilities. Use texture atlases and share materials aggressively to keep draw calls low; GPU instancing for repeated units. Keep unit meshes in the 1,500–4,000 triangle range and rely on texture for detail. Cap simultaneous particle systems and use short-lived, low-count, larger-billboard effects rather than dense fine ones. Limit total on-screen units to roughly 60–80 per side. Simplify shaders — no expensive screen-space effects, no real-time reflections.
>
> **Do NOT:**
> - Make it photorealistic. Gritty realism at phone scale turns into brown mush.
> - Make it cute, chibi, or flat-cartoon. This is grounded and heavy, just exaggerated.
> - Use thin, spindly, or delicate unit designs. Everything reads as massive.
> - Let terrain compete with units for saturation, contrast, or brightness.
> - Use a floating flat-design HUD. The console frame is core to the identity.
> - Use small icons with fine internal detail, gradients, or thin strokes.
> - Add camera rotation, free camera, or an aggressive zoom range.
> - Apply full-screen bloom, heavy chromatic aberration, motion blur, or lens flare.
> - Use screen shake on ordinary attacks.
> - Let units pop into existence, or die by simply disappearing.
> - Use generic stock sci-fi shapes — smooth featureless white pods, chrome spheres, unmarked hulls. Everything is stenciled, worn, welded, and used.

---

## Suggested working order in Summer Engine

Because the engine is iterative, feed it in this sequence rather than all at once:

1. Block 0 + Block 1 — establish the render feel with placeholder shapes before any art exists. Verify silhouette readability at phone size first.
2. Block 4 — get the HUD frame and command card in early. It defines screen real estate and constrains everything else.
3. Block 6 — tune responsiveness with placeholder units. If it doesn't feel good grey-boxed, art won't save it.
4. Block 2 + Block 3 — build out terrain and faction art against a working game.
5. Block 5 — audio last, but budget real time for unit voice; it's what makes the game feel like a Blizzard game more than any single visual choice.
6. Block 7 — keep on hand throughout as a corrective.
