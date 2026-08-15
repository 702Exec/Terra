# Native Defenders — Enemy Roster

*The forces the harvest fleet meets on each world, and what the player buys to answer them.*

---

## The rule this roster obeys

**Enemy stats do not inflate across worlds.** A Rime Mite has the same health as an Ashfall Mite. Escalation comes from *which* archetypes show up, how many, how often, and from how many directions — the design doc's four higher-ranked difficulty knobs (§4). Stat inflation is knob five, "use last, use sparingly," because players always notice.

That has a direct consequence for the player: **you cannot out-level a world, you can only out-compose it.** Arriving at a Tier 3 planet without an answer to armour is a loss regardless of how many turrets you own. This is what makes the pre-mission loadout choice matter, and what makes the threat profile on the star map worth reading.

---

## The four families

Three ground archetypes plus air, reskinned per biome. Every world draws from these.

### Mite — *swarm*
Fast, fragile, and numerous. Dies to almost anything but arrives in counts that overwhelm single-target fire. The default filler of every wave.

- **Threatens:** anything that kills one target at a time
- **Countered by:** Apex Strider's thermal sweep, Acolyte's astral storm, a Vanguard plugging the lane
- **Fails against:** area damage of any kind

### Spitter — *ranged*
Stops short of its target and shoots from outside melee reach. Wears down forward extractors without ever entering a Vanguard's threat range, and will kill an undefended turret line from a standoff.

- **Threatens:** static defenses, forward structures, melee blockers
- **Countered by:** Riftwalker outranging it, Aegis Warden's barrier breaking line of fire, Vanguard's kinetic rush closing the gap
- **Fails against:** anything that reaches it before it sets up

### Carapace — *armored*
Slow, heavily plated, hits hard. Shrugs off light massed fire — the wall that a turret ring of tier-1 pulse turrets simply cannot chew through in time.

- **Threatens:** turret lines, massed light units, the base itself
- **Countered by:** Bulwark, Eclipse's prismatic overload, Monolith Turret III
- **Fails against:** sustained anti-armor damage

### Drifter — *air*
**Ignores the lane system entirely.** Flies straight from its spawn to the base, over every forward turret, chokepoint, and barrier the player has built. The first air wave is the moment a player who built a perfect ground perimeter discovers it does not cover them.

- **Threatens:** the base directly, bypassing all ground defense
- **Countered by:** Riftwalker, anti-air Monolith Turret, Eclipse
- **Fails against:** nothing on the ground — this must be answered in kind

---

## Apex defenders

One per act. Genuinely unique, arrives mid-mission on Tier 3 and Tier 4 worlds, and is meant to be an event rather than a stat block.

| Act | Biome | Apex | What it does |
|---|---|---|---|
| I | Ashfall | **Cinder Titan** | Leaves burning ground behind it that damages anything standing in the lane, including the player's own blockers. |
| II | Drift | **Void Harrower** | Phases through terrain and barriers. The Aegis Warden's force wall does not stop it. |
| III | Rime | **Glacial Maw** | Freezes turrets it passes, disabling them for a period rather than destroying them. |
| IV | Verdance | **Rootmind** | Spawns Mites continuously until killed. Ignoring it is not an option. |
| V | Sol | **Coalition Siege Platform** | Long-range artillery that out-ranges every static defense and shells the base from outside the perimeter. |

---

## Biome skins

Same four families, four palettes. Per §5 of the design doc, this is where the art savings live — silhouette and palette variation, not new units.

| Biome | Palette | Silhouette note |
|---|---|---|
| **Ashfall** | Rust, ochre, ember glow | Cracked plating, heat vents |
| **Drift** | Void grey, white, hard edges | Angular, low-gravity limbs |
| **Rime** | Blue-grey, pale | Ice-crusted, brittle |
| **Verdance** | Green-black | Overgrown, organic tendrils |

---

## Earth is the exception

Act V is not a reskin. After nineteen worlds of alien natives, a unified human coalition should read as a different genre entirely — riveted steel, olive drab, amber emissives, stenciled markings, ballistic weapons with tracers and shell casings.

| Unit | Family | Note |
|---|---|---|
| **Coalition Infantry** | swarm | Cheap, endless, and sympathetic. |
| **Support Squad** | ranged | Missile teams that outrange most turrets. |
| **Main Battle Tank** | armored | The most heavily armoured thing in the game. |
| **Gunship** | air | Fast, and comes in formations rather than singly. |
| **Siege Platform** | apex | See above. |
| **Orbital Railgun** | hazard | Timed strike on a telegraphed area — a hazard event, not a unit. |

Humans are deliberately cruder than everything preceding them, and deliberately sympathetic. The player is the invader.

---

## What each tier fields

This is the table the star map's threat profile is generated from. The player reads it *before* committing to a node, and buys accordingly.

| Tier | Families present | Apex | Lanes | Wave gap |
|---|---|---|---|---|
| **1** | Mite, Spitter | — | 1 | Generous |
| **2** | + Carapace | — | 2 | Standard |
| **3** | + Drifter *(air)* | Mid-mission | 3 | Tight |
| **4** | Full roster | Mid-mission, plus a hazard event | 4 | Punishing |

### The counter matrix

| Enemy | Buy this |
|---|---|
| Mite | Apex Strider · Acolyte · Vanguard |
| Spitter | Riftwalker · Aegis Warden · Vanguard |
| Carapace | Bulwark · Eclipse · Monolith Turret III |
| Drifter | Riftwalker · anti-air turret · Eclipse |
| Apex | Bulwark · Eclipse · Avatar |

A player who has not unlocked *any* anti-air should be able to see that a Tier 3 world will field Drifters, and route around it. That is the star map doing its job.

---

## Star map threat profile

The design doc's node preview already shows Tier, Yield, Lanes, Modifier, and Biome. Add one line:

```
THREAT   Mite · Spitter · Carapace · Drifter        APEX  Glacial Maw
```

Listing the families rather than the counts is the right resolution — it tells the player what to *bring* without telling them what the fight will look like, so the mission still holds surprises.

---

## Where the prototype is

The grey-box currently fields one enemy type, which is the **Mite** with placeholder stats. Everything above is unbuilt.

The cheapest next step is not the whole roster — it is **Spitter and Carapace**. Those two prove the counter loop: does having the wrong composition actually feel like a loss you could have prevented? If yes, the rest of the roster is worth building. If the player just adds more turrets and wins anyway, the counter system is not carrying its weight and the roster should shrink rather than grow.
