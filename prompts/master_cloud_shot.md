# Sovereign Spire — Fire Ring + Impact (combined)

**Seedance prompt — as written**

```
Style & Mood: Gritty documentary-meets-science-fiction war film realism, the camera held by someone standing on open ground who is about to run and has not run yet, everything grounded in physical weight and atmospheric pressure. Dynamic Description: Extreme low angle from ground level aimed straight up into the sky, the camera handheld and shaking with constant operator jitter and the occasional reactive jolt; a dense ceiling of dark storm cloud 20,000 feet above ground churns overhead and begins to rotate, the whole cloud mass slowly spiraling inward around a single point directly above the lens and compressing into a tight circular eye, the edges of the rotating ring shearing and feathering as they turn; the compressed center darkens almost to black, then a dull orange glow blooms deep inside it and spreads outward through the cloud until the entire ring is burning, fire rolling through the vapor in slow heavy tongues and lighting the underside of the cloud deck in violent orange and red; the burning ring widens, pressure pushing the cloud outward in a visible expanding shock disc; four enormous white-hot conical drill points punch down through the fire in unison, trailing long ribbons of flame and superheated vapor, their armored leg segments glowing from white at the tips through cherry-red up to dull orange further up, the electric-blue light strips along each leg fighting through the incandescence; the legs drive downward toward the lens with terrible speed, growing until the four glowing points and the dark spire-shaped mass of the machine behind them fill the entire frame, the camera tilting and jolting hard as the operator staggers back, ash and burning embers falling past the lens and one striking the front element, the frame going hot and overexposed at the edges. the sky is a heavy overcast deck of dark grey-violet storm cloud lit from within by fire. the frame intercutting a brief high-speed slow-motion beat at the instant of contact as the ground compresses and cracks radially outward from each foot; the camera is hammered by the impact and jolts hard, losing and regaining the horizon; a shockwave detonates outward from the base of the machine as a visible expanding white pressure ring low to the ground, and behind it a churning black-brown wall of dirt, smoke and pulverized rock races toward camera; the ring lifts and hurls everything it passes, pickup trucks and a military transport tumbling end over end through the air, a wooden utility pole snapping and cartwheeling, mature trees torn out root-first and thrown flat, roofing panels and corrugated sheet metal and concrete slabs from outbuildings spinning up into the debris cloud, a wall of glass shards catching the light, torn scrub and topsoil peeling off the ground in a continuous sheet; the front reaches the camera and the whole frame is struck, the camera knocked violently sideways and downward, a spinning slab of debris cracking across the lens, dirt and gravel hammering the front element, the image lurching as the camera tumbles; a thick opaque cloud of dust and smoke closes completely over the lens, the last light bleeding out through the particulate, and the frame settles into total black.
Static Description: The descending machine is a colossal spire-shaped mining engine roughly a hundred and thirty meters tall with a tapering conical hull of brushed gunmetal and pale steel armor plating divided by recessed panel seams, vertical electric-blue light channels running the height of the hull, a dark faceted teardrop core filled with deep indigo starfield sheen centered on a single glowing red circular aperture ringed by concentric iris plates, clusters of small articulated clawed manipulator arms flanking the core, four immense segmented insectoid legs with thick armored upper segments, ring-bearing knee housings wrapped in bundled hydraulic cabling, and tapering lower shins ending in narrow conical drill points, and a ribbed segmented drill column descending from its belly to a fine point. The ground at the base of frame is dry cracked dirt and broken asphalt with scattered gravel and dead scrub, a chain-link fence line and a leaning utility pole at the extreme frame edge;  Shot on ARRI Alexa 35 in ProRes 4444 LogC4, Panavision Ultra Vintage 2x anamorphic 40mm at T2.3 with Tiffen Black Pro-Mist 1/4 filter, all camera work is handheld and shaky throughout with constant operator micro-jitter, reactive movement and chaotic shake, no stabilized or locked-off or dolly-smooth shots anywhere, gritty documentary-meets-sci-fi war film aesthetic with no stylization and everything grounded in physical realism, Kodak Vision3 250D film emulation with 800 ASA grain structure, stormy desaturated palette violently underlit by orange and red firelight with dusty atmospheric haze, heavy halation blooming on the incandescent metal, blue anamorphic streak flares off the leg light strips, 24fps base shutter 180 degrees, total runtime roughly five seconds. Audio: diegetic only, wind rising hard across open ground, deep rolling atmospheric thunder building underneath, a heavy concussive pressure boom as the cloud ring ignites, sustained low fire roar tearing through vapor, superheated metal hissing and ticking, air screaming past the descending drill points and rising in pitch, distant car alarms triggering in sequence far off frame, faint human shouting a long way away, embers crackling past the lens, no music, no dialogue.
```

---

## Settings

| | |
|---|---|
| Model | Seedance 2.5 |
| Mode | omni_reference |
| Duration | 5s as written — **see note 1** |
| Aspect ratio | 21:9 |
| Resolution | 1080p |
| Audio | on |
| Bitrate | high |
| Reference | Sovereign Spire render, role `image_references` |

---

## Notes

This merges the fire-ring beat and the impact beat into a single shot. Saved verbatim as
you wrote it. Four things to be aware of before spending credits on it:

**1 — Runtime vs. beat count.** This is roughly ten distinct beats: cloud rotation,
spiral compression, ignition, ring widening, legs punching through, legs filling frame,
impact, shockwave, debris strike, dust-to-black. At five seconds that's half a second per
beat. The model will almost certainly compress or drop several — most likely the slow
cloud formation, which is exactly the part the earlier pass was slowed down to protect.
**10–15s is the honest runtime for this much action.** Change "roughly five seconds" in
the spec block to match whatever `duration` you pass; the two disagreeing is what makes
the model guess.

**2 — Missing environment for the debris.** The action calls out pickup trucks, a
military transport, outbuildings, roofing panels, concrete slabs and mature trees, but
the Static Description only establishes dirt, asphalt, gravel, scrub, a fence line and
one utility pole. There is nothing in the locked frame for the shockwave to pick up. Add
to the Static Description: *"low industrial outbuildings and warehouses mid-ground,
scattered parked civilian vehicles and a few military transport trucks, a line of mature
trees, chain-link fencing and utility poles, and a hazy grey high-rise skyline along the
far horizon."*

**3 — Audio stops halfway.** The audio line covers wind, thunder, ignition, fire roar and
the descent scream, but the shot now ends with a landing. Nothing describes the impact.
Append: *"a colossal ground impact detonation with deep sub-bass weight, earth splitting
and tearing, the whip-crack of the pressure front passing, vehicle bodywork crumpling,
sheet glass shattering in waves, tree trunks snapping, dirt and gravel hammering the
camera housing, a low continuous roar of moving dust swallowing every other sound."*

**4 — Camera position contradiction.** The opening is an extreme low angle aimed straight
up; the impact half needs a wide view from several hundred meters back to see the
shockwave ring travel. Those are different setups. The model will pick one. If you want
both, the phrase *"hard cut to a wide low-angle ground-level view from roughly four
hundred meters back"* at the impact transition tells it that's a deliberate edit rather
than a continuity error.

**Also:** legs are open here. Same as the other single-shot file — this conflicts with the
legs-closed-until-landing rule in the 20s cut, so treat it as a standalone variant.
