class_name UpgradeTrack
extends Resource

## One purchasable upgrade line, bought from the Sovereign Spire.
##
## Tracks are global rather than per-unit: buying Weapons II improves every
## turret on the map, present and future. That is the cheap shape deliberately —
## it tests whether a credit sink fixes the surplus without committing to
## per-unit upgrade trees, which multiply both the UI and the balance surface.

## Stable identifier used by the bus and by whatever reads the effect. Changing
## it resets the track, so treat it as permanent once a save format exists.
@export var id: StringName = &""
@export var display_name: String = "Upgrade"
## Shown under the name. Say what the level actually does.
@export var description: String = ""

@export var max_level: int = 5
@export var base_cost: int = 150
## Each level costs this multiple of the one before it.
@export var cost_multiplier: float = 1.6

## Added to the tracked value per level. Interpretation belongs to whatever
## consumes it — flat damage for weapons, a fraction for fire rate.
@export var effect_per_level: float = 1.0


func cost_for_level(next_level: int) -> int:
	if next_level <= 0 or next_level > max_level:
		return 0
	return int(round(float(base_cost) * pow(cost_multiplier, float(next_level - 1))))


func effect_at_level(level: int) -> float:
	return effect_per_level * float(clampi(level, 0, max_level))
