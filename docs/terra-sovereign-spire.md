# The Sovereign Spire

*The mission structure the player defends, and the landing sequence that opens Earth.*

---

## What it is

A four-legged extraction engine, dropped from **the Aegis** — the harvest fleet's mothership — and driven into the surface like an ordnance strike. It anchors, opens, and begins stripping planetary material, beaming it back to orbit for the rest of the mission.

| | |
|---|---|
| **Legs** | Four |
| **Height** | ~130 m |
| **Mass** | Thousands of tons |
| **Emissions** | Planetary-scale gravitational and mass-increasing beams, used to fracture and lift material |
| **Mobility** | **None.** It lands once and holds position for the whole mission. |

It does not move. That is a design decision, not an omission — the entire mission is built on having one fixed thing that must be held, and a relocatable base would replace "defend this" with "retreat from this," which is a different game.

**The mothership is the Aegis.** The Aegis Warden takes its name from the ship, which is the right direction for the borrowing — a support unit named for the vessel that projects the fleet's protection. Worth watching only if a second Aegis-prefixed unit appears; two is a lineage, three is a muddle.

**The engine's own name is still open.** "Sovereign Spire" was chosen when it was a spire; it no longer fits a squat four-legged engine. "World Engine" is not available — it is the term from *Man of Steel*, which is also where the silhouette comes from. Rename before it reaches class names, scene files, and asset paths.

**What keeps this homage rather than lift:** the film's engine terraforms, remaking a world into somewhere else. This one extracts and ships the proceeds home. That difference in purpose is the thing to keep visible in every description of it.

---

## Scale is fictional, not literal

At the prototype's working scale an enemy stands about 1.4 units. If that is a human-sized defender, one unit is roughly 1.4 metres — which puts a literal 130 m Spire at around 90 units tall on a 144-unit map. It would occupy most of the battlefield and make the game unplayable.

Handle it the way every RTS does: **non-literal in gameplay, true scale in cutscene.** In-mission the Spire should be the largest object on the field by a wide margin — monumental against a turret, unmistakable on the minimap — without being measured. The landing sequence is where the real 130 m lands emotionally, because there it can be framed against a kitchen window and a baseball diamond.

Current in-game footprint is 5×5×3 units, which reads as a shed. It should grow substantially. Note that widening it also pushes out `turret_min_base_distance` and shortens every lane, so it is a balance change as well as an art one.

---

## The landing — Earth opening cinematic

The one cutscene worth building properly.

### Beats

1. **Ordinary life, unhurried.** A mother at the kitchen window, cooking. A city street thick with traffic and pedestrians. Kids playing baseball on a suburban diamond in front of a small-town crowd. No music sting, no dread — the scene must not know what is coming.
2. **The clouds gather.** The only tell. Held long enough that the audience notices before anyone on screen does.
3. **Breach.** The Spire comes through the cloud deck, leg tips burning from atmospheric entry.
4. **Impact.** It lands with the force of an air-burst weapon. Shockwave, debris, dirt and smoke thrown outward in every direction.
5. **Silence.** Dust settles. Screams cut short. The land is charred.
6. **It wakes.** The engine comes to life. The mission begins.

### Why this belongs at Earth, not at world one

The sequence is not about the Spire. It is about who the player has become.

Nineteen worlds of the harvest have made landing routine — a thing the player does, competently, for resources. Running this beat at Mars would spend it on an audience with no investment. Running it at Earth spends it on an audience that has been *good at this* for fifteen hours, against the only world they recognise.

That is the payoff the design doc's invader POV has been earning the whole game. It should not flinch.

It also matters that Earth is optional. A player whose quota fills early can turn for home and never see this. Which means the cutscene is the consequence of a deliberate choice to take Earth anyway — and that makes it land harder than any mandatory opening could.

### Built timing

The grey-box sequence runs **20 seconds**, skippable by any input:

| Beat | Duration | Ends at |
|---|---|---|
| Descent | 7.0s | 7.0 |
| Settle | 3.0s | 10.0 |
| Silence | 4.5s | 14.5 |
| Wake | 5.5s | 20.0 |

Two ten-second clips fit this exactly. `CinematicPlayer` plays a queue of video
clips full-screen in place of the grey box when any are assigned; with none, the
grey box stands in. Both paths end at the same gate, so the mission does not
care which ran.

Skip is not optional. This plays at the start of a mission the player may retry
a dozen times.

### Producing it without an art team

The beats above are carried by **sound and cutting**, not animation. The most expensive-feeling moment in the sequence — screams cut short, then nothing — is an audio edit. Budget accordingly:

- **Stills over animation.** Composed frames with slow pushes and hard cuts. The disaster is legible in one frame of charred ground; it does not need to be simulated.
- **Silence is the effect.** The gap between impact and the engine waking does more than any particle system.
- **The one live element** worth animating is the breach through the cloud deck. Everything else can hold.

A greybox version is possible in-engine now, using the existing primitives: descent, impact, camera shake, dust, then hand off to gameplay. That would test the *timing* of the beats — which is the part that either works or does not — long before any art exists.

---

## Decided vs open

**Decided:** four legs; does not move; extraction rather than terraforming; the landing cinematic belongs to Earth.

**Open:** its name; in-game footprint and the balance changes that follow; whether the landing plays as a shortened version at every world with the full sequence reserved for Earth; whether the gravitational beams have any mechanical presence or stay pure fiction.
