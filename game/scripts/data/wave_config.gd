class_name WaveConfig
extends Resource

## Wave schedule and composition. Frequency and composition are separate knobs
## from enemy stats, per the design doc's difficulty ranking — shrinking the gap
## is the pressure valve, not bigger numbers on the units.

@export var enemy_stats: EnemyStats

@export_group("Composition")
## Enemies in wave 1.
@export var first_wave_count: int = 4
## Added to the count with every subsequent wave.
@export var count_growth: int = 2
## Seconds between individual spawns inside one wave.
@export var spawn_interval: float = 0.35

@export_group("Frequency")
## Grace period before wave 1 so the player can place an opening turret or two.
@export var first_wave_delay: float = 15.0
## Gap before wave 2.
@export var wave_gap: float = 30.0
## Seconds shaved off the gap with every wave.
@export var wave_gap_shrink: float = 1.0
## The gap never drops below this.
@export var min_wave_gap: float = 14.0


func count_for_wave(wave_number: int) -> int:
	return maxi(1, first_wave_count + count_growth * (wave_number - 1))


## Seconds of quiet before `wave_number` begins.
func gap_before_wave(wave_number: int) -> float:
	if wave_number <= 1:
		return first_wave_delay
	return maxf(min_wave_gap, wave_gap - wave_gap_shrink * float(wave_number - 2))
