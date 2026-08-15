# The Ancients — Player Roster

*Revision of the original `ancients_units.md`. Trimmed for wave defense, renamed off StarCraft II, and sized for solo development.*

---

## What changed and why

The first draft listed seventeen units mapped one-to-one onto the StarCraft II Protoss roster. Three problems drove this revision:

1. **Half the roster had no function.** Transports, cloak detectors, infiltrators, fog-of-war scouts, and siege ships that out-range static defenses are tools for attacking an enemy base with an economy. Terra has scripted waves that spawn at fixed points and walk at you. There is nothing to scout, nothing to harass, nowhere to drop.
2. **The names and abilities were direct lifts.** "Warp Prism," "Cybernetics Core," "Twilight Council," and "Templar Archives" are Blizzard's own names. Everything else duplicated a Protoss unit's role, tier position, and signature ability.
3. **Seventeen units plus ten structures is not a solo content budget.** The design doc's §9 names scope as the project's single greatest risk.

**No unit below carries a StarCraft equivalent column.** That column is what produced the clone. Units here are defined by the enemy archetype they answer.

---

## Design rule

Every combat unit exists to counter something. The enemy roster is three archetype families — **swarm**, **ranged**, **armored** — plus **air** from Tier 3 worlds onward, and one apex defender per act. If a proposed unit does not answer one of those, it does not ship.

---

## Economy

### Glimmer Drone
- **Role:** Resource harvester and structure anchor
- **Description:** The automated workforce. Hovers over planetary deposits, strips raw elements, and opens micro-rifts to anchor structures without a build time of its own.
- **Ability — *Rift Anchor*:** Places a structure instantly by opening a portal, so the drone returns to harvesting immediately rather than channeling.

---

## Ground Forces — *Aether Conduit*

### Vanguard
- **Role:** Frontline melee blocker
- **Counters:** Swarm
- **Description:** Heavy shielded infantry carrying twin focalized starlight blades. Built to stand in a lane and hold it while everything behind keeps firing.
- **Ability — *Kinetic Rush*:** Absorbs incoming kinetic energy to accelerate, closing the last stretch to a target at high speed.

### Riftwalker
- **Role:** Ranged anti-air skirmisher
- **Counters:** Air, armored
- **Description:** Quadrupedal constructs piloted by preserved minds, firing high-impact phase particle streams. The primary answer to airborne waves before the shipyard exists.
- **Ability — *Quantum Shift*:** Dematerializes and reappears a short distance away, used to reposition between lanes rather than to kite. 10s cooldown.

### Aegis Warden
- **Role:** Lane control and damage mitigation
- **Counters:** Swarm, ranged
- **Description:** A levitating support drone that reshapes the approach itself. The most valuable unit in the roster for a defense game, because it turns the map's lane geometry into something the player can edit mid-wave.
- **Abilities:**
  - *Force Barrier* — Projects a hard-light wall for 15 seconds, sealing a lane or splitting an incoming wave.
  - *Aether Shield* — A dome reducing incoming ranged damage to friendlies inside by 20%.

### Bulwark
- **Role:** Heavy anti-armor frontline
- **Counters:** Armored, apex defenders
- **Description:** Twin-cannon assault walkers deployed when armored waves stop dying to massed light fire. Absorbs the heavy single hits that delete ordinary infantry.
- **Ability — *Hard-Light Barrier*:** On taking damage, triggers a barrier absorbing a large threshold for 10 seconds before cracking. 30s cooldown.

---

## Heavy Machines — *Automaton Foundry*

### Apex Strider
- **Role:** Area-of-effect anti-swarm siege
- **Counters:** Swarm, massed ranged
- **Description:** A towering multi-legged walker whose paired thermal lances sweep horizontally across a lane. The answer to wave sizes that outgrow single-target fire.
- **Abilities:**
  - *Terrain Stride* — Steps over elevation changes without ramps.
  - *Thermal Sweep* — Twin beams trace a horizontal line, dealing heavy area damage to all ground units in the path.

---

## Air — *Astral Shipyard*

### Eclipse
- **Role:** Anti-armor air destroyer
- **Counters:** Armored, apex defenders
- **Description:** Built around a floating focusing crystal that channels a continuous prismatic stream, destabilizing heavy molecular bonds. Damage compounds the longer it holds a single target, which makes it the designated apex-killer.
- **Ability — *Prismatic Overload*:** +50% damage against armored targets for 20 seconds at the cost of movement speed.

---

## Ascended — *Grand Sanctuary*

### Acolyte
- **Role:** Area-of-effect caster
- **Counters:** Swarm, massed anything
- **Description:** Physically frail masters of cosmic force. The panic button for a wave that has already broken the line.
- **Ability — *Astral Storm*:** Conjures a psionic storm over an area for 3 seconds, dealing heavy damage to everything caught inside.

### Avatar
- **Role:** Apex powerhouse
- **Counters:** Everything, briefly
- **Description:** Manifested directly from the Sovereign Spire at severe resource cost — not merged from other units. A glowing entity of pure starlight held together by will, with enormous shielding and almost no physical health beneath it. Unlocked for the Earth assault.
- **Abilities:**
  - *Psionic Shockwave* — Attacks splash to all air and ground around the target.
  - *Fragile Colossus* — Massive shield pool, negligible health once shields collapse.

---

## Structures

| Structure | Function |
|---|---|
| **Sovereign Spire** | Command hub. Resource dropoff, Avatar manifestation, base upgrades. |
| **Monolith Turret** | Static defense. Three tiers, unlocked across the campaign. |
| **Lattice Node** | Power grid. Extends the buildable and manifestable radius. |
| **Aether Conduit** | Ground unit production. |
| **Refraction Forge** | Weapon and shield upgrades for ground forces. |
| **Resonance Core** | Tier 2 tech gate. |
| **Automaton Foundry** | Heavy machine production. |
| **Bastion Vault** | Heavy machine upgrades. |
| **Astral Shipyard** | Air production. |
| **Grand Sanctuary** | Ascended tier tech and production. |

---

## Cut from the first draft

| Cut | Reason |
|---|---|
| Warp Prism | Blizzard's own unit name. Troop transport and drop play — no enemy base to drop on. |
| Spectre | Blizzard unit name (Terran). Infiltrator that raids enemy economy; enemies have no economy. |
| Seer-Drone | Cloak detector and fog scout. No cloaked enemies, no fog worth scouting. |
| Nebula | Fog-of-war vision, traps, raiding. Same reason. |
| Supernova | Exists to out-range enemy static defenses. Enemies build nothing. |
| Interceptor | Air superiority against an enemy air force. Enemy air arrives on a timer; the Riftwalker and turrets cover it. |
| Justiciar | Mirage feint for scouting and harassment. No scouting phase exists. |
| Arkship | Fleet-battle carrier, and the most recognizable silhouette in the source roster. |

Cut units are not lost — several are natural fits if Terra ever grows an assault mission type where the player attacks a fixed installation. They are wrong for wave defense specifically.

---

## Honest scope note

Eight units and ten structures is still substantial for one developer: each unit needs a model, animation set, ability implementation, VFX, SFX, and balance passes across twenty worlds. It is roughly a quarter of the first draft and it is finishable. Build the Vanguard, one turret tier, and the three enemy archetypes first, and confirm the counter loop is fun before committing to the other seven.
