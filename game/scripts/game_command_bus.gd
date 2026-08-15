class_name GameCommandBus
extends Node

## The single door every game-state mutation walks through.
##
## Nothing outside this script writes credits, base health, wave number, enemy
## health, or the contents of the enemy/turret containers. Systems submit a
## command; the bus validates it, applies it, and emits a signal. That is the
## whole contract, and it is what makes co-op networking a later feature rather
## than a later rewrite (see CLAUDE.md, architecture rule 1).
##
## Registered as the `GameCommands` autoload. Call it as
## `GameCommands.submit(GameCommandBus.Command.PLACE_TURRET, {...})`.

enum Command {
	BEGIN_MISSION,
	SET_ENEMY_PATHS,
	ADD_CREDITS,
	PLACE_TURRET,
	START_WAVE,
	SPAWN_ENEMY,
	DAMAGE_ENEMY,
	DAMAGE_BASE,
	END_RUN,
}

signal mission_started()
signal enemy_paths_ready(paths: Array[PackedVector3Array])
signal credits_changed(credits: int)
signal base_health_changed(current_health: int, max_health: int)
signal wave_started(wave_number: int, enemy_count: int)
signal enemy_spawned(enemy: Node3D)
signal enemy_died(enemy: Node3D)
signal turret_placed(turret: Node3D)
signal command_rejected(command: Command, reason: String)
signal run_ended(final_wave: int)

var _config: MissionConfig = null
var _base: Node3D = null
var _enemy_root: Node3D = null
var _turret_root: Node3D = null
var _enemy_scene: PackedScene = null
var _turret_scene: PackedScene = null

var _credits: int = 0
var _wave_number: int = 0
var _base_health: int = 0
var _run_active: bool = false

## One lane per active approach vector. Every enemy on a lane reads the same
## polyline — the count scales with lanes, not with units (CLAUDE.md rule 2).
var _enemy_paths: Array[PackedVector3Array] = []

## Enemy health lives here, not on the enemy node, so that every hitpoint in the
## mission is owned by one authority.
var _enemy_health: Dictionary[Node3D, int] = {}


# --- Submission ---------------------------------------------------------------

func submit(command: Command, payload: Dictionary = {}) -> bool:
	if command != Command.BEGIN_MISSION and not _run_active:
		return false
	match command:
		Command.BEGIN_MISSION:
			return _begin_mission(payload)
		Command.SET_ENEMY_PATHS:
			return _set_enemy_paths(payload)
		Command.ADD_CREDITS:
			return _add_credits(payload)
		Command.PLACE_TURRET:
			return _place_turret(payload)
		Command.START_WAVE:
			return _start_wave(payload)
		Command.SPAWN_ENEMY:
			return _spawn_enemy(payload)
		Command.DAMAGE_ENEMY:
			return _damage_enemy(payload)
		Command.DAMAGE_BASE:
			return _damage_base(payload)
		Command.END_RUN:
			return _end_run()
	return false


# --- Queries ------------------------------------------------------------------
# Read-only. Safe for UI and for placement previews.

func is_run_active() -> bool:
	return _run_active


func get_credits() -> int:
	return _credits


func get_wave_number() -> int:
	return _wave_number


func get_base_health() -> int:
	return _base_health


func get_mission_config() -> MissionConfig:
	return _config


func get_wave_config() -> WaveConfig:
	if _config == null:
		return null
	return _config.wave_config


func get_turret_cost() -> int:
	if _config == null or _config.turret_stats == null:
		return 0
	return _config.turret_stats.cost


func can_afford_turret() -> bool:
	return _credits >= get_turret_cost()


## Placement legality, evaluated the same way here and inside PLACE_TURRET so the
## preview never disagrees with the command.
func can_place_turret(world_position: Vector3) -> bool:
	if not _run_active or _config == null:
		return false
	var extent: float = _config.battlefield_extent
	if absf(world_position.x) > extent or absf(world_position.z) > extent:
		return false
	if _base != null:
		if _flat_distance(world_position, _base.global_position) < _config.turret_min_base_distance:
			return false
	for spawn_position: Vector3 in _config_spawn_positions():
		if _flat_distance(world_position, spawn_position) < _config.turret_min_spawn_distance:
			return false
	if _turret_root != null:
		for turret: Node in _turret_root.get_children():
			var placed := turret as Node3D
			if placed == null:
				continue
			if _flat_distance(world_position, placed.global_position) < _config.turret_min_spacing:
				return false
	return true


func get_lane_count() -> int:
	return _enemy_paths.size()


func get_enemy_paths() -> Array[PackedVector3Array]:
	return _enemy_paths


## Head of a lane — where its enemies enter the map.
func get_lane_spawn_position(lane_index: int) -> Vector3:
	if lane_index < 0 or lane_index >= _enemy_paths.size():
		return Vector3.ZERO
	return _enemy_paths[lane_index][0]


func get_base_node() -> Node3D:
	return _base


# --- Command handlers ---------------------------------------------------------

func _begin_mission(payload: Dictionary) -> bool:
	_config = payload.get("config", null) as MissionConfig
	_base = payload.get("base", null) as Node3D
	_enemy_root = payload.get("enemy_root", null) as Node3D
	_turret_root = payload.get("turret_root", null) as Node3D
	_enemy_scene = payload.get("enemy_scene", null) as PackedScene
	_turret_scene = payload.get("turret_scene", null) as PackedScene
	if _config == null or _base == null or _enemy_root == null or _turret_root == null:
		command_rejected.emit(Command.BEGIN_MISSION, "mission wiring incomplete")
		return false
	if _enemy_scene == null or _turret_scene == null:
		command_rejected.emit(Command.BEGIN_MISSION, "enemy or turret scene missing")
		return false

	_enemy_health.clear()
	_enemy_paths = []
	_wave_number = 0
	_credits = _config.starting_credits
	_base_health = _config.base_max_health
	_run_active = true

	mission_started.emit()
	credits_changed.emit(_credits)
	base_health_changed.emit(_base_health, _config.base_max_health)
	return true


func _set_enemy_paths(payload: Dictionary) -> bool:
	var paths: Array[PackedVector3Array] = payload.get("paths", [] as Array[PackedVector3Array])
	if paths.is_empty():
		command_rejected.emit(Command.SET_ENEMY_PATHS, "no lanes supplied")
		return false
	for path: PackedVector3Array in paths:
		if path.size() < 2:
			command_rejected.emit(Command.SET_ENEMY_PATHS, "a lane needs at least two points")
			return false
	_enemy_paths = paths
	enemy_paths_ready.emit(_enemy_paths)
	return true


func _add_credits(payload: Dictionary) -> bool:
	var amount: int = int(payload.get("amount", 0))
	if amount <= 0:
		return false
	_credits += amount
	credits_changed.emit(_credits)
	return true


func _place_turret(payload: Dictionary) -> bool:
	var world_position: Vector3 = payload.get("position", Vector3.ZERO)
	var cost: int = get_turret_cost()
	if _credits < cost:
		command_rejected.emit(Command.PLACE_TURRET, "not enough credits")
		return false
	if not can_place_turret(world_position):
		command_rejected.emit(Command.PLACE_TURRET, "invalid placement")
		return false

	var turret := _turret_scene.instantiate() as Node3D
	if turret == null:
		return false
	turret.set("stats", _config.turret_stats)
	_turret_root.add_child(turret)
	turret.global_position = Vector3(world_position.x, 0.0, world_position.z)

	_credits -= cost
	credits_changed.emit(_credits)
	turret_placed.emit(turret)
	return true


func _start_wave(payload: Dictionary) -> bool:
	var enemy_count: int = int(payload.get("enemy_count", 0))
	if enemy_count <= 0:
		return false
	_wave_number += 1
	wave_started.emit(_wave_number, enemy_count)
	return true


func _spawn_enemy(payload: Dictionary) -> bool:
	var stats := payload.get("stats", null) as EnemyStats
	var lane_index: int = int(payload.get("lane_index", 0))
	if stats == null or lane_index < 0 or lane_index >= _enemy_paths.size():
		return false
	var lane: PackedVector3Array = _enemy_paths[lane_index]
	var spawn_position: Vector3 = payload.get("position", lane[0])

	var enemy := _enemy_scene.instantiate() as Node3D
	if enemy == null:
		return false
	enemy.set("stats", stats)
	enemy.set("path", lane)
	enemy.set("target_base", _base)
	_enemy_root.add_child(enemy)
	enemy.global_position = Vector3(spawn_position.x, 0.0, spawn_position.z)

	_enemy_health[enemy] = stats.max_health
	enemy_spawned.emit(enemy)
	return true


func _damage_enemy(payload: Dictionary) -> bool:
	var enemy := payload.get("enemy", null) as Node3D
	var amount: int = int(payload.get("amount", 0))
	if enemy == null or amount <= 0 or not _enemy_health.has(enemy):
		return false

	var remaining: int = _enemy_health[enemy] - amount
	if remaining > 0:
		_enemy_health[enemy] = remaining
		return true

	_enemy_health.erase(enemy)
	enemy_died.emit(enemy)
	enemy.queue_free()
	return true


func _damage_base(payload: Dictionary) -> bool:
	var amount: int = int(payload.get("amount", 0))
	if amount <= 0:
		return false
	_base_health = maxi(0, _base_health - amount)
	base_health_changed.emit(_base_health, _config.base_max_health)
	if _base_health == 0:
		_end_run()
	return true


func _end_run() -> bool:
	if not _run_active:
		return false
	_run_active = false
	run_ended.emit(_wave_number)
	return true


# --- Helpers ------------------------------------------------------------------

func _config_spawn_positions() -> Array[Vector3]:
	var heads: Array[Vector3] = []
	for path: PackedVector3Array in _enemy_paths:
		if not path.is_empty():
			heads.append(path[0])
	return heads


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
