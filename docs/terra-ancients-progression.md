# The Ancients — 20-World Campaign Progression

*Revision of the original `ancients_progression.md`. Unlock order rebuilt, worlds grouped into five biome sets, science claims corrected.*

---

## What changed and why

1. **Unlock order was inverted.** The first draft put static defense at level 7 and the first combat unit at level 5 — in a base-defense game. Levels 1–4 had nothing to fight with and nothing to fight from. The prototype running today already has a base, a turret, credits, and waves, which means levels 1–6 as originally specified would have been *less* game than what already exists. Level 1 now ships the base and the turret together, matching the current build.
2. **Twenty unique worlds was twenty biomes.** The design doc §5 caps this at five biome sets, deriving four worlds each, to cut art cost by roughly 75%. The good news: this planet list already clusters into the doc's five canonical biomes almost untouched.
3. **Some science needed walking back.** Details in the notes column.

4. **Unlocks are keyed to world tier, not to a named world.** See [Unlock model](#unlock-model). The branching star map means a run visits a subset of these twenty, so binding an unlock to a specific world would make it unreachable on most routes.

The narrative spine is unchanged: real bodies, real materials, Earth last.

---

## World table

These are nodes on the star map, not a running order. Tier sets both the yield and which unlock pool a clear draws from.

| World | Tier | Biome | Resource | Yield |
|:--|:--|:--|:--|:--|
| Mars | 1 | Ashfall | Iron | 5 |
| Mercury | 1 | Drift | Sodium, Iron | 5 |
| Enceladus | 1 | Rime | Water | 5 |
| Ceres | 1 | Drift | Water, Iron | 5 |
| Venus | 2 | Ashfall | Sulfur | 9 |
| Psyche | 2 | Drift | Iron, Nickel | 9 |
| Titan | 2 | Rime | Methane, Nitrogen | 9 |
| Ganymede | 2 | Rime | Water, Silicates | 9 |
| Io | 2 | Ashfall | Sulfur | 9 |
| Europa | 3 | Rime | Water | 14 |
| Callisto | 3 | Rime | Carbon, Iron | 14 |
| Triton | 3 | Rime | Nitrogen Ice | 14 |
| Pluto | 3 | Rime | Methane Ice | 14 |
| Proxima Centauri b | 3 | Verdance | *Unsurveyed* | 14 |
| Kepler-186f | 4 | Verdance | Carbon, Silicon | 20 |
| Gliese 581c | 4 | Verdance | Iron, Water | 20 |
| 55 Cancri e | 4 | Ashfall | Carbon, Graphite | 20 |
| TRAPPIST-1e | 4 | Verdance | Water, Magnesium | 20 |
| Kepler-22b | 4 | Verdance | Water, Sea Minerals | 20 |
| **Earth** | Final | Sol | **All elements** | — |

Five Tier 4 worlds at 20 each is exactly the 100-unit quota in five cycles, which is the expert run the design doc describes. Nine cycles spare, and a starter roster to do it with.

---

## Unlock model

**You start with a base, a turret, and a worker** — the Sovereign Spire, Monolith Turret I, and the Glimmer Drone. That is the prototype already running, and it means world one is playable without unlocking anything first.

**Clearing a world draws the next unlock from that world's tier pool.** Not from a list bound to the world itself.

| Pool | Unlocks, in draw order |
|:--|:--|
| **Tier 1** | Aether Conduit → Vanguard → Refraction Forge → Lattice Node |
| **Tier 2** | Monolith Turret II → Riftwalker → Resonance Core → Aegis Warden → Automaton Foundry |
| **Tier 3** | Bulwark → Monolith Turret III → Bastion Vault → Apex Strider → Astral Shipyard |
| **Tier 4** | Eclipse → Grand Sanctuary → Acolyte → *(two upgrade tiers, unassigned)* |
| **Earth** | Avatar |

### Why this works

**No run collects everything.** Twenty unlocks against a fourteen-cycle budget means the roster you finish with is a consequence of the route you carved. That is replay value falling out of a constraint that already existed rather than a system added on top.

**It sharpens the doc's central tension.** The safe route was already mathematically insufficient — all Tier 1 yields 70 against a quota of 100. Now it is *also* a roster failure: grinding low tiers fills the Tier 1 pool, which empties after four draws, and every clear after that gives you nothing. The cautious player arrives at the late game under-equipped as well as short. The punishment for playing safe becomes something the player feels every mission, not just arithmetic on the quota screen.

**Hard worlds pay twice** — more yield and a better unlock — which is the right shape for a risk decision.

### What still needs deciding

- **Empty pools.** When a tier's pool is exhausted, a clear could convert to bonus yield, or to fleet-reserve credit. Something should happen; nothing is the wrong answer.
- **Player choice within a pool.** Fixed draw order is simplest to build and to balance. Letting the player pick from two offered unlocks is more interesting and roughly doubles the balance surface. Worth prototyping only after the loop is proven.
- **Tier assignment.** The table above is a first pass. Which specific world sits at which tier is pure tuning and does not affect the model.
- **Allocation-screen purchases.** The design doc already spends fleet reserve on upgrades. Whether reserve can also buy unlocks outright is a separate lever, and stacking both may be one system too many.

---

## Biome sets

Five art sets, twenty worlds, using the design doc's existing biome names.

| Biome | Worlds | Palette |
|---|---|---|
| **Ashfall** | Mars, Venus, Io, 55 Cancri e | Volcanic, rust and ochre |
| **Drift** | Mercury, Psyche, Ceres | Airless rock and exposed metal, void and white |
| **Rime** | Enceladus, Titan, Ganymede, Europa, Callisto, Triton, Pluto | Ice, blue-grey |
| **Verdance** | Proxima b, Kepler-186f, Gliese 581c, TRAPPIST-1e, Kepler-22b | Overgrown, green-black |
| **Sol** | Earth | Blue-green, human industrial |

Rime carries seven worlds and does the heaviest lifting. Titan is the odd one — hydrocarbon seas rather than water ice — and can be a palette shift within Rime (amber lakes, orange haze) rather than a sixth set.

---

## World notes

Each world's hook is its terrain and its lane geometry — the things that make it play differently. None of them name an unlock, because which unlock a clear grants depends on the tier pool, not the world.

**Mars** *(Tier 1 · Ashfall · Iron)*
The rust-red deserts. Establish the beachhead against dust storms and scavengers. This is the current prototype: base, turret, credits, one approach lane.

**Mercury** *(Tier 1 · Drift · Sodium & Iron)*
Sodium is the honest resource — Mercury has a well-documented sodium exosphere that trails behind the planet like a tail. Iron from the oversized core. Day-night terminator sweeps the map on a timer.

**Enceladus** *(Tier 1 · Rime · Water)*
Siphon the south-polar cryovolcanic plumes. Collection zones freeze over on a cycle, so extraction points move during the mission.

**Ceres** *(Tier 1 · Drift · Water & Iron)*
Low gravity, dark clay crust, water-ice mantle. Wide-open terrain with almost no natural chokepoints — the tutorial in building your own.

**Venus** *(Tier 2 · Ashfall · Sulfur)*
Crushing pressure and sulfuric cloud decks. The atmosphere degrades unpowered hulls, so power coverage becomes a defensive decision rather than an economic one.

**Psyche** *(Tier 2 · Drift · Iron & Nickel)*
Exposed iron-nickel asteroid. Density measurements have been revised down since the early "solid metal core" description, so treat it as metal-rich rather than a pure metal body. Silver dropped — no basis for it. Deposits sit outside any defensible perimeter.

**Titan** *(Tier 2 · Rime · Methane & Nitrogen)*
Pump the hydrocarbon seas — Kraken Mare, Ligeia Mare. A pure holdout: fixed siphons on a map with more approach lanes than you can cover.

**Ganymede** *(Tier 2 · Rime · Water & Silicates)*
Largest moon in the solar system and the only one with its own magnetic field. Ice labyrinths make the lanes long and winding, which rewards forward turrets.

**Io** *(Tier 2 · Ashfall · Sulfur)*
The most volcanically active body known. Lava resurfacing opens and closes lanes mid-mission — the map itself changes under you.

**Europa** *(Tier 3 · Rime · Water)*
Drill the subsurface ocean. Cracked ice sheets divide the surface into natural corridors, the most chokepoint-friendly map in the set.

**Callisto** *(Tier 3 · Rime · Carbon & Iron)*
Ancient, saturated with craters, geologically dead. Crater rims give elevation, which is where the Apex Strider's terrain stride earns its cost.

**Triton** *(Tier 3 · Rime · Nitrogen Ice)*
Retrograde orbit, nitrogen geysers, cantaloupe terrain. Erupting vents damage anything parked on them, so static defense placement has an expiry.

**Pluto** *(Tier 3 · Rime · Methane Ice)*
Nitrogen glaciers and the dark Cthulhu Macula. Sensor-scrambling storms cut the incoming-wave warning time, sometimes to nothing.

**Proxima Centauri b** *(Tier 3 · Verdance · unsurveyed)*
Only a minimum mass is measured; surface composition is unknown, and it orbits an active flare star. Lean into that — the harvest yield is hidden until you commit, which is the one node on the map that gambles rather than prices.

**Kepler-186f** *(Tier 4 · Verdance · Carbon & Silicon)*
First Earth-sized planet confirmed in a habitable zone. Dense red-tinted forest breaks line of sight, shortening every turret's effective range.

**Gliese 581c** *(Tier 4 · Verdance · Iron & Water)*
A confirmed planet, though its early billing as habitable was reassessed — the current reading is a runaway greenhouse, closer to Venus than Earth. Tidally locked, so you harvest the narrow terminator strip with your back to two hostile hemispheres.

**55 Cancri e** *(Tier 4 · Ashfall · Carbon & Graphite)*
The "diamond planet" framing came from a 2012 estimate of the host star's carbon-to-oxygen ratio that was revised downward soon after, so the diamond interior is no longer current thinking. What survives is better: a lava world whose dayside is molten rock, carbon-rich and tidally locked. Harvest graphite from the terminator crust.

**TRAPPIST-1e** *(Tier 4 · Verdance · Water & Magnesium)*
Rocky world in a compact seven-planet system, the most Earth-like of the set by density. Attacked from three directions from the opening wave.

**Kepler-22b** *(Tier 4 · Verdance · Water & Sea Minerals)*
Radius suggests a small Neptune rather than a rocky world, so treat the global ocean as an artistic choice rather than a finding. Buildable land is scarce; the base sits on platforms with water lanes between them.

**Earth** *(Final · Sol · all elements)*
The precise cocktail needed to reignite the homeworld, defended by a unified human coalition — orbital railguns, tactical air, kinetic options. All four lanes from the opening wave. Per the design doc, Earth is optional: if the quota fills before you arrive, the fleet can turn for home, and that choice is the ending branch.
