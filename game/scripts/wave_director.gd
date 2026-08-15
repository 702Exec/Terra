class_name WaveDirector
extends Node

## Schedules waves, warns about them, and drip-feeds their enemies onto the map.
##
## Which directions a wave comes from is a property of the wave number, read off
## WaveConfig's lane stages: the opening waves come from one side, later ones
## from two, then three, then everything at once. Within a wave the enemies are
## dealt round-robin across the live lanes so they arrive together rather than
## as separate columns.
##
## The director decides *when*; the command bus decides *what happens* — it
## never touches game state directly, it only submits WARN_WAVE, START_WAVE and
## SPAWN_ENEMY.

## Spawns are jittered inside this radius so a lane's arrivals do not stack on
## one point.
@export var spawn_scatter: float = 2.0

@onready var wave_timer: Timer = $WaveTimer
@onready var warn_timer: Timer = $WarnTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var countdown_timer: Timer = $CountdownTimer

var _config: WaveConfig = null
var _pending_spawns: int = 0
var _next_wave_number: int = 1
var _wave_lanes: PackedInt32Array = PackedInt32Array()
var _lane_cursor: int = 0
var _roster: Array[EnemyStats] = []


func _ready() -> void:
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	warn_timer.timeout.connect(_on_warn_timer_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	countdown_timer.timeout.connect(_on_countdown_tick)
	GameCommands.enemy_paths_ready.connect(_on_enemy_paths_ready, CONNECT_ONE_SHOT)
	GameCommands.run_ended.connect(_on_run_ended)


## Waves cannot start before there are lanes for them to walk, so the director
## waits on the paths rather than on mission start.
func _on_enemy_paths_ready(_paths: Array[PackedVector3Array]) -> void:
	_config = GameCommands.get_wave_config()
	if _config == null or _config.entries.is_empty():
		push_warning("WaveDirector has no wave composition; no waves will run.")
		return
	_schedule_next_wave()


func _schedule_next_wave() -> void:
	var gap: float = _config.gap_before_wave(_next_wave_number)
	wave_timer.start(gap)
	# The warning rides its own timer so the lead time stays honest even as the
	# gap shrinks; if the gap is shorter than the lead, the warning fires now.
	var lead: float = minf(_config.warning_lead_time, gap)
	warn_timer.start(maxf(0.01, gap - lead))
	countdown_timer.start()
	_on_countdown_tick()


## Once a second while the player is between waves. Knowing how long is left is
## what turns a gap into preparation time rather than a lull.
func _on_countdown_tick() -> void:
	if not GameCommands.is_run_active() or wave_timer.is_stopped():
		countdown_timer.stop()
		return
	GameCommands.submit(GameCommandBus.Command.SET_WAVE_COUNTDOWN, {
		"seconds_left": int(ceilf(wave_timer.time_left)),
		"wave_number": _next_wave_number,
	})


func _on_warn_timer_timeout() -> void:
	if not GameCommands.is_run_active():
		return
	GameCommands.submit(GameCommandBus.Command.WARN_WAVE, {
		"wave_number": _next_wave_number,
		"lanes": _lanes_for(_next_wave_number),
	})


func _on_wave_timer_timeout() -> void:
	if not GameCommands.is_run_active():
		return
	var wave_number: int = _next_wave_number
	var count: int = _config.count_for_wave(wave_number)
	if not GameCommands.submit(GameCommandBus.Command.START_WAVE, {"enemy_count": count}):
		return

	countdown_timer.stop()
	GameCommands.submit(GameCommandBus.Command.SET_WAVE_COUNTDOWN, {
		"seconds_left": -1,
		"wave_number": wave_number,
	})

	_next_wave_number += 1
	_pending_spawns = count
	_wave_lanes = _lanes_for(wave_number)
	_lane_cursor = 0
	# Dealt up front rather than rolled per spawn, so a wave always contains the
	# mix its composition promises.
	_roster = _config.composition_for_wave(wave_number, count)
	# Big waves arrive faster per unit so that they still land as a wave rather
	# than a stream that never ends.
	spawn_timer.wait_time = _config.spawn_interval_for_wave(count)
	_spawn_one()
	if _pending_spawns > 0:
		spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	if not GameCommands.is_run_active():
		spawn_timer.stop()
		return
	_spawn_one()
	if _pending_spawns <= 0:
		spawn_timer.stop()
		_schedule_next_wave()


func _spawn_one() -> void:
	if _pending_spawns <= 0 or _wave_lanes.is_empty():
		return
	if _roster.is_empty():
		return
	_pending_spawns -= 1

	var lane_index: int = _wave_lanes[_lane_cursor % _wave_lanes.size()]
	_lane_cursor += 1
	var archetype: EnemyStats = _roster[_lane_cursor % _roster.size()]
	GameCommands.submit(GameCommandBus.Command.SPAWN_ENEMY, {
		"stats": archetype,
		"lane_index": lane_index,
		"position": _scattered_spawn_position(lane_index),
	})


func _lanes_for(wave_number: int) -> PackedInt32Array:
	return _config.lanes_for_wave(wave_number, GameCommands.get_lane_count())


func _scattered_spawn_position(lane_index: int) -> Vector3:
	var origin: Vector3 = GameCommands.get_lane_spawn_position(lane_index)
	return origin + Vector3(
		randf_range(-spawn_scatter, spawn_scatter),
		0.0,
		randf_range(-spawn_scatter, spawn_scatter)
	)


func _on_run_ended(_final_wave: int) -> void:
	wave_timer.stop()
	warn_timer.stop()
	spawn_timer.stop()
	countdown_timer.stop()
