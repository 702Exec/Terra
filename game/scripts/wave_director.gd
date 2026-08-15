class_name WaveDirector
extends Node

## Schedules waves and drip-feeds each wave's enemies onto the map.
##
## Every wave gets bigger and every gap gets shorter, both read off WaveConfig.
## The director decides *when*; the command bus decides *what happens* — the
## director never touches game state directly, it only submits START_WAVE and
## SPAWN_ENEMY.

@export var spawn_point: Node3D
## Spawns are jittered inside this radius so a wave does not stack on one point.
@export var spawn_scatter: float = 2.0

@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_timer: Timer = $SpawnTimer

var _config: WaveConfig = null
var _pending_spawns: int = 0
var _next_wave_number: int = 1


func _ready() -> void:
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	GameCommands.enemy_path_ready.connect(_on_enemy_path_ready, CONNECT_ONE_SHOT)
	GameCommands.run_ended.connect(_on_run_ended)


## Waves cannot start before there is a lane for them to walk, so the director
## waits on the path rather than on mission start.
func _on_enemy_path_ready(_path: PackedVector3Array) -> void:
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
	_pending_spawns -= 1
	GameCommands.submit(GameCommandBus.Command.SPAWN_ENEMY, {
		"stats": _config.enemy_stats,
		"position": _scattered_spawn_position(),
	})


func _scattered_spawn_position() -> Vector3:
	var origin: Vector3 = spawn_point.global_position if spawn_point != null else Vector3.ZERO
	var offset := Vector3(
		randf_range(-spawn_scatter, spawn_scatter),
		0.0,
		randf_range(-spawn_scatter, spawn_scatter)
	)
	return origin + offset


func _on_run_ended(_final_wave: int) -> void:
	wave_timer.stop()
	spawn_timer.stop()
