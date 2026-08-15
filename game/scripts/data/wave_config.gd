class_name WaveConfig
extends Resource

## Wave schedule, size, and which approach lanes each wave uses.
##
## Size grows geometrically rather than by a flat step, because a flat step
## loses to the economy: credits buy a turret every few seconds while +2 enemies
## arrive every half minute. Geometric growth is what forces the player to stop
## widening their ring and start deepening it.
##
## Note the ceiling. Doubling from 6 reaches ~3.1 million by wave 20, so raw
## count cannot carry late-game difficulty on its own — it saturates around wave
## 8 and everything past that has to come from enemy composition (tougher
## archetypes), which is the design doc's higher-ranked knob anyway.

@export var enemy_stats: EnemyStats

@export_group("Size")
## Enemies in wave 1.
@export var first_wave_count: int = 6
## Each wave is this many times the size of the one before it.
@export var count_multiplier: float = 2.0
## Hard ceiling on a single wave. Protects frame rate and marks the point where
## escalation has to switch from count to composition.
@export var max_wave_count: int = 400
## Seconds between individual spawns inside one wave.
@export var spawn_interval: float = 0.2

@export_group("Frequency")
## Grace period before wave 1 so the player can place an opening turret or two.
@export var first_wave_delay: float = 15.0
## Gap before wave 2.
@export var wave_gap: float = 30.0
## Seconds shaved off the gap with every wave.
@export var wave_gap_shrink: float = 1.0
## The gap never drops below this.
@export var min_wave_gap: float = 14.0
## How long before a wave lands that the base warns about it.
@export var warning_lead_time: float = 5.0

@export_group("Approach lanes")
## Three parallel arrays, one entry per stage, in ascending wave order.
##
## `lane_stage_waves` is the wave a stage takes effect on.
## `lane_stage_masks` is a bitmask of which lanes that stage may draw from —
##   bit 0 = lane 0, bit 1 = lane 1, and so on, matching the order of the map's
##   Lanes container. With N/S/E/W that reads: N=1, S=2, E=4, W=8, so E+W = 12
##   and N+E+W = 13.
## `lane_stage_counts` is how many of those lanes attack at once. When it is
##   fewer than the mask allows, the selection rotates with the wave number so
##   successive rounds come from different sides.
@export var lane_stage_waves: PackedInt32Array = PackedInt32Array([1, 3, 10, 15, 20])
@export var lane_stage_masks: PackedInt32Array = PackedInt32Array([1, 15, 12, 13, 15])
@export var lane_stage_counts: PackedInt32Array = PackedInt32Array([1, 1, 2, 3, 4])


func count_for_wave(wave_number: int) -> int:
	var raw: float = float(first_wave_count) * pow(count_multiplier, float(wave_number - 1))
	# pow overflows to INF long before wave 20 at a multiplier of 2.
	if not is_finite(raw) or raw >= float(max_wave_count):
		return max_wave_count
	return maxi(1, int(round(raw)))


## Seconds of quiet before `wave_number` begins.
func gap_before_wave(wave_number: int) -> float:
	if wave_number <= 1:
		return first_wave_delay
	return maxf(min_wave_gap, wave_gap - wave_gap_shrink * float(wave_number - 2))


## Which lane indices attack on `wave_number`, given how many lanes the map has.
func lanes_for_wave(wave_number: int, available_lanes: int) -> PackedInt32Array:
	if available_lanes <= 0:
		return PackedInt32Array()

	var eligible: PackedInt32Array = _eligible_lanes(wave_number, available_lanes)
	if eligible.is_empty():
		return PackedInt32Array([0])

	var stage: int = _stage_index(wave_number)
	var wanted: int = 1 if stage < 0 else lane_stage_counts[stage]
	wanted = clampi(wanted, 1, eligible.size())
	if wanted == eligible.size():
		return eligible

	# Rotate the window so consecutive waves of the same width still arrive from
	# different directions.
	var chosen: PackedInt32Array = PackedInt32Array()
	var offset: int = wave_number % eligible.size()
	for step: int in range(wanted):
		chosen.append(eligible[(offset + step) % eligible.size()])
	return chosen


func _eligible_lanes(wave_number: int, available_lanes: int) -> PackedInt32Array:
	var stage: int = _stage_index(wave_number)
	var mask: int = 0 if stage < 0 else lane_stage_masks[stage]
	var eligible: PackedInt32Array = PackedInt32Array()
	for index: int in range(available_lanes):
		if mask & (1 << index) != 0:
			eligible.append(index)
	if eligible.is_empty():
		# A stage that names no lane the map actually has falls back to all of
		# them rather than to silence.
		for index: int in range(available_lanes):
			eligible.append(index)
	return eligible


## Index of the last stage that has come into effect, or -1 before the first.
func _stage_index(wave_number: int) -> int:
	var found: int = -1
	for index: int in range(lane_stage_waves.size()):
		if lane_stage_waves[index] <= wave_number:
			found = index
		else:
			break
	if found >= lane_stage_masks.size() or found >= lane_stage_counts.size():
		return -1
	return found
