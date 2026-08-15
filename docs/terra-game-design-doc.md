# TERRA — Game Design Document v0.1

*Base-defense survival RTS. Solo development, Godot, desktop-first with mobile port planned.*

---

## 1. Concept

You are the invader.

Your homeworld is dying. A harvest fleet has been sent outward to strip resources from inhabited worlds and ship them back before the collapse. You command that fleet. Each assault is a landing: establish a foothold, build a harvesting base, and hold it against the native defenders long enough to extract your quota. Then jump to the next world.

Twenty worlds stand between the fleet and its quota. The last one is Earth.

**Pitch line:** *They Are Billions, played from the invaders' side.*

**Genre:** Base-defense survival RTS (also: horde survival strategy, wave-defense RTS). Single-player against AI, with optional two-player PvE co-op on high-tier worlds. No competitive multiplayer, no matchmaking.

**The hook:** every resource you spend making yourself stronger is a resource that doesn't go home to save your world.

---

## 2. Core loop (per mission)

1. **Landing** — deploy on a fixed map with a starting structure and a small force.
2. **Establish** — build harvesters, claim resource nodes, raise defenses on the approach lanes.
3. **Hold** — survive escalating waves of native defenders on a timer.
4. **Extract** — the mission ends when the extraction quota is filled, or when your base falls.
5. **Allocate** — split what you harvested between the homeworld shipment and fleet upgrades.
6. **Jump** — choose the next node on the star map.

A mission should run 15–25 minutes. Long enough for a real escalation arc, short enough to play one on a lunch break.

---

## 3. The star map — route as the strategic layer

This is the spine of the game, and it's what makes difficulty a player choice instead of a designer's setting.

### Structure

A branching node graph from the fleet's entry point to Earth, in the mold of *FTL* or *Slay the Spire*. Paths diverge and reconverge. You cannot play every node in a single run — choosing one path means giving up another.

Each node displays before you commit:

| Field | Example |
|---|---|
| Tier | ▮▮▮▯ (3 of 4) |
| Yield | 14 units |
| Lanes | 3 approach vectors |
| Modifier | *Ionized atmosphere — air units unavailable* |
| Biome | Ashfall |

### The cost that makes it a real choice

Without a cost, everyone takes the long safe route and the choice is fake. The cost is **time**.

Your homeworld has a finite number of **cycles** left. Every jump consumes one cycle regardless of how hard the world was. So a low-tier world costs exactly as much time as a brutal one, and yields far less.

**Starting numbers to tune:**

- Homeworld quota: **100 units**
- Cycles available: **14**
- Tier 1 yield: **5** · Tier 2: **9** · Tier 3: **14** · Tier 4: **20**

Which produces:

- **All Tier 1** = 70 units across 14 cycles. *You cannot win this way.* The safe route is not a route.
- **All Tier 2** = 126 units. Achievable, grindy, requires nearly the full cycle budget.
- **Mixed 2/3** = comfortable, the intended path for a first playthrough.
- **Five Tier 4 worlds** = 100 units in 5 cycles, with 9 cycles to spare. The expert run.

Tune the exact figures once it's playable, but preserve the shape: **the easiest path must be mathematically insufficient.** That single constraint is what converts "pick a difficulty" into "plan a campaign."

### Secondary pressure: readiness

The longer the fleet operates, the more the galaxy prepares. Every cycle elapsed adds a small defensive bonus to all remaining worlds — tighter wave frequency or a stat bump. This is flavor-forward and mechanically light, but it means a slow route gets harder *as* it drags, which discourages pure attrition-farming.

### The allocation decision

After each mission, you split your harvest:

- **Ship home** — counts toward quota. Gone forever.
- **Fleet reserve** — buys unit unlocks, structure upgrades, and starting-loadout improvements that persist across missions.

This is the best decision in the game because it has no correct answer. Ship everything and you'll arrive at Tier 4 worlds with a starter army. Upgrade everything and you'll be unstoppable and still lose your world. Every player will find a different balance, and the ratio they chose is a badge.

### Earth

Earth is **not required to win.** If your quota fills before you reach it, the fleet can turn for home.

That creates the ending branch:

- **Withdrawal** — quota met, Earth spared. The homeworld survives. Humanity never learns how close it came.
- **The Last Harvest** — you take Earth anyway. Highest yield in the game, hardest fight in the game, and a different ending.

For an invader-POV story, this is the payoff — the game asks whether you stop when you have enough. Make the Withdrawal ending genuinely good, not a consolation prize, or the choice collapses.

---

## 4. Difficulty design

### Scale on knobs, not on one number

Ranked by how much interesting decision-making each one creates:

1. **Approach lanes** — the strongest knob. One lane is a chokepoint puzzle; four lanes force you to split forces and consciously leave something thin. Costs nothing to implement beyond map layout.
2. **Resource scarcity and placement** — put nodes outside the natural perimeter and the player must choose between economy and safety every single mission.
3. **Wave frequency** — the gap between waves is your real pressure valve. Shrinking rebuild time hurts more than adding enemies.
4. **Wave composition** — one air wave that ignores ground defenses is worth more than doubling enemy health.
5. **Enemy stats** — use last, use sparingly. Stat inflation reads as cheap and players always notice.

### Tier definitions

| | Lanes | Wave gap | Composition | Nodes in perimeter | Yield |
|---|---|---|---|---|---|
| **Tier 1** | 1 | Generous | Ground only, 2 types | All | 5 |
| **Tier 2** | 2 | Standard | + 1 ranged or armored type | Most | 9 |
| **Tier 3** | 3 | Tight | + air, + a mid-mission apex unit | Half | 14 |
| **Tier 4** | 4 | Punishing | Full roster, apex units, timed hazard event | Few | 20 |

### Curve shape: sawtooth, not ramp

Group worlds into acts. Difficulty climbs within an act, then the first mission of the next act drops *below* the previous peak but *above* where the last act began. The player has just unlocked new tech and gets one mission to feel powerful before the squeeze returns.

A straight linear ramp across twenty missions goes flat in the middle every time. The sawtooth is what keeps the back half alive.

---

## 5. World and content structure

### Twenty worlds, five biomes

Twenty is the right *story* count and a ruinous *art* count for a solo developer. Build **five biome sets** and derive four worlds from each through layout, lane count, enemy mix, and modifiers.

| Act | Biome | Worlds | Tiers available |
|---|---|---|---|
| I | Ashfall — volcanic, rust and ochre | 4 | 1–2 |
| II | Verdance — overgrown, green-black | 4 | 2–3 |
| III | Rime — frozen installation, blue-grey | 4 | 2–4 |
| IV | Drift — asteroid/low-gravity, void and white | 4 | 3–4 |
| V | Sol — Earth and approach | 4 | 4 only |

Reusing biomes cuts art cost by roughly 75% with almost no felt repetition, because players remember *layouts and fights*, not ground textures.

### Enemy design economy

Do not build twenty unique defender factions. Build:

- **3 core archetype families** — swarm, ranged, armored — reskinned per biome with palette and silhouette variation.
- **1 apex defender per act** — a genuinely unique unit that defines that act's threat.
- **Earth is the exception.** Human industrial defenders get their own full roster, their own weapon language (ballistic, tracers, shell casings), and their own audio identity. After nineteen worlds of alien natives, an organized human military should feel like a different genre.

### Faction art correction

The art direction doc originally cast **human industrial** as the primary faction. It isn't — it's the Earth finale faction. Reassign as follows:

- **Player fleet (the harvesters)** — the "advanced/energetic" language: smooth forms, bilateral symmetry, cyan and blue-white emissives, structures that unfold or materialize rather than being welded. Alien, precise, invasive.
- **Native defenders (Acts I–IV)** — the "organic/swarm" language, palette-shifted per biome.
- **Earth (Act V)** — the human industrial language in full. Riveted steel, olive drab, amber emissives, stenciled markings. Deliberately cruder than everything preceding it, and deliberately sympathetic.

All other rules in the art doc — silhouette-first, chunky forms, player color reservation, emissive tells, environment recedes — stand unchanged.

---

## 6. Badges and achievements

Route choice generates the achievement taxonomy automatically. Five tracks:

**Route badges** — awarded for the shape of a completed run.
*The Long March* (12+ worlds) · *Blitz* (≤6 worlds) · *Straight Line* (no reconverging paths taken) · *Pyrrhic* (quota met with 1 cycle remaining) · *Overshoot* (finished 25%+ above quota)

**Allocation badges** — awarded for the ship-home vs. upgrade ratio.
*Ascetic* (completed with zero fleet upgrades) · *Armada* (upgrade spend exceeded shipments) · *Even Hand* (within 5% of a 50/50 split)

**Mastery badges** — per-world, per-tier clears. The completionist grid.

**Challenge badges** — *Untouched* (no structure lost) · *Overstay* (hold 10 waves past quota) · *Bare Ground* (quota met without building a single defensive structure)

**Ending badges** — *Withdrawal* · *The Last Harvest* · both endings achieved.

**Co-op badges** — a separate parallel track so co-op play doesn't dilute solo mastery.

### Website integration

The natural shape: the game emits a **run summary** at campaign end — a small JSON payload with the route taken, tiers cleared, allocation ratio, cycles used, badges earned — which posts to a backend and renders as a public profile page with a badge wall and a visual map of the route the player carved.

That's a Node/Express + Postgres app on Render, which is squarely in your existing wheelhouse. It's likely the part of this project you're best equipped to build yourself.

**But make it phase 3.** Accounts mean auth, privacy policy, and a live service to keep up. The cheap v1 that captures 80% of the value: badges stored locally in the save file, plus an **exportable run card** — a generated image showing the player's route and badges that they can share anywhere. Zero backend. Add the profile site once there are players to fill it.

Badges also map cleanly onto Steam achievements if you ship there.

---

## 7. Co-op (phase 2)

Two players, PvE, on Tier 3 and Tier 4 worlds only. Shared base or adjacent bases on a wider map with more lanes.

PvE co-op is far more forgiving than competitive multiplayer: one player hosts, the host is authoritative, and latency barely matters because nobody is being cheated out of a fair match. Godot's high-level multiplayer API is adequate for this.

**Build it second.** Prove the single-player loop is fun first. Networking roughly doubles the complexity of every gameplay system, and adding it to a game that isn't fun yet just makes debugging harder.

**The one decision to make now:** route every game state change through a single command/action function rather than mutating state directly across your codebase. Building units, placing structures, spending resources, spawning waves — all of it goes through one door. That single habit is most of what separates "add networking later" from "rewrite the game later." Do this from your first grey-box prototype.

---

## 8. Build order

Do not touch art until phase 4. Grey boxes prove fun; art cannot rescue a loop that isn't.

**Phase 0 — Prove the loop.** One fixed map, capsules for units. One enemy type flowing along a flow field toward your base. One defensive structure. Base health. Waves on a timer. *Is holding this line interesting?* If not, nothing later matters.

**Phase 1 — Economy and win condition.** Harvester units, resource nodes, a build menu, the extraction quota counter, win and lose states. Now it's a game.

**Phase 2 — Combat depth.** Multiple enemy archetypes, air units, the player unit roster, tech unlocks. Tune the difficulty knobs from §4 until Tier 1 and Tier 4 feel genuinely different.

**Phase 3 — Meta layer.** Star map, node graph, cycle budget, quota tracking, the allocation screen, persistence between missions. The game becomes a campaign.

**Phase 4 — Art pass.** Apply the art direction doc. Player fleet first, then one biome end-to-end before touching the others.

**Phase 5 — Audio.** Adaptive music layers, unit voice, weapon and UI SFX. Budget real time for unit voice lines — they carry more personality per hour of work than anything else on the list.

**Phase 6 — Co-op.**

**Phase 7 — Website, profiles, badge backend.**

---

## 9. Scope guardrails

Explicitly **out** of v1. Revisit only after shipping:

- Competitive PvP of any kind
- Procedural map generation
- A map editor or mod support
- More than five biome sets
- Full voice acting for every unit — pick six units that carry personality and do those properly
- In-app purchases, ad integration, live-ops
- Mobile release — desktop first, port after the game is proven
- Destructible terrain
- A campaign map with more than one fleet or any 4X layer

The single greatest risk to this project is not technical difficulty. It's scope. Twenty worlds, an art style benchmarked against a AAA studio, co-op, and a companion website is already an ambitious solo slate. Ship Act I as a demo before building Act II.
