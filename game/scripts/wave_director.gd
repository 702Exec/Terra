class_name WaveDirector
extends Node

## Schedules waves and drip-feeds each wave's enemies onto the map.
##
## Every wave gets bigger and every gap gets shorter, both read off WaveConfig.
## Enemies are dealt round-robin across the live lanes, so a wave arrives from
## every approach vector at once rather than as one column — splitting the
## player's attention is the pressure, not the raw count.
##
## The director decides *when*; the command bus decides *what happens* — it
## never touches game state directly, it only submits START_WAVE and
## SPAWN_ENEMY.

## Spawns are jittered inside this radius so a lane's arrivals do not stack on
## one point.
@export var spawn_scatter: float = 2.0

@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_timer: Timer = $SpawnTimer

var _config: WaveConfig = null
var _pending_spawns: int = 0
var _next_wave_number: int = 1
var _next_lane: int = 0


func _ready() -> void:
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	GameCommands.enemy_paths_ready.connect(_on_enemy_paths_ready, CONNECT_ONE_SHOT)
	GameCommands.run_ended.connect(_on_run_ended)


## Waves cannot start before there are lanes for them to walk, so the director
## waits on the paths rather than on mission start.
func _on_enemy_paths_ready(_paths: Array[PackedVector3Array]) -> void:
	_config = GameCommands.get_wave_config()
	if _config == null or _config.enemy_stats == null:
		push_warning("WaveDirector has no wave config; no waves will run.")
		return
	spawn_timer.wait_time = _config.spawn_interval
	_schedule_next_wave()


func _schedule_next_wave() -> void:
	wave_timer.start(_config.gap_before_wave(_next_wave_number))


func _on_wave_timer_timeout() -> void:
	if not GameCommands.is_run_active():
		return
	var count: int = _config.count_for_wave(_next_wave_number)
	if not GameCommands.submit(GameCommandBus.Command.START_WAVE, {"enemy_count": count}):
		return
	_next_wave_number += 1
	_pending_spawns = count
	# Rotate the starting lane each wave so the same vector is not always first
	# to arrive.
	_next_lane = (_next_wave_number - 1) % maxi(1, GameCommands.get_lane_count())
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
	if _pending_spawns <= 0:
		return
	var lane_count: int = GameCommands.get_lane_count()
	if lane_count <= 0:
		return
	_pending_spawns -= 1

	var lane_index: int = _next_lane % lane_count
	_next_lane += 1
	GameCommands.submit(GameCommandBus.Command.SPAWN_ENEMY, {
		"stats": _config.enemy_stats,
		"lane_index": lane_index,
		"position": _scattered_spawn_position(lane_index),
	})


func _scattered_spawn_position(lane_index: int) -> Vector3:
	var origin: Vector3 = GameCommands.get_lane_spawn_position(lane_index)
	return origin + Vector3(
		randf_range(-spawn_scatter, spawn_scatter),
		0.0,
		randf_range(-spawn_scatter, spawn_scatter)
	)


func _on_run_ended(_final_wave: int) -> void:
	wave_timer.stop()
	spawn_timer.stop()
