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
	SELL_TURRET,
	PURCHASE_UPGRADE,
	CALL_ORBITAL_STRIKE,
	TICK_ABILITIES,
	SET_WAVE_COUNTDOWN,
	WARN_WAVE,
	START_WAVE,
	SPAWN_ENEMY,
	DAMAGE_ENEMY,
	DAMAGE_BASE,
	DAMAGE_STRUCTURE,
	END_RUN,
}

signal mission_started()
signal enemy_paths_ready(paths: Array[PackedVector3Array])
signal credits_changed(credits: int)
signal base_health_changed(current_health: int, max_health: int)
signal structure_damaged(structure: Node3D, current_health: int, max_health: int)
signal structure_destroyed(structure: Node3D)
signal income_changed(credits_per_second: float)
signal wave_countdown_changed(seconds_left: int, wave_number: int)
signal wave_incoming(wave_number: int, lane_names: PackedStringArray)
signal wave_started(wave_number: int, enemy_count: int)
signal enemy_spawned(enemy: Node3D)
signal enemy_died(enemy: Node3D)
signal turret_placed(turret: Node3D)
signal turret_sold(world_position: Vector3, refund: int)
signal upgrade_purchased(track_id: StringName, level: int)
signal orbital_strike_called(world_position: Vector3)
signal orbital_strike_impacted(world_position: Vector3, enemies_hit: int)
signal orbital_cooldown_changed(seconds_left: float)
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
var _seconds_to_wave: int = -1

## One lane per active approach vector. Every enemy on a lane reads the same
## polyline — the count scales with lanes, not with units (CLAUDE.md rule 2).
var _enemy_paths: Array[PackedVector3Array] = []

## Human-readable name per lane, parallel to `_enemy_paths`. Used by the
## incoming-wave warning so the player knows which side to look at.
var _lane_names: PackedStringArray = PackedStringArray()

## Enemy health lives here, not on the enemy node, so that every hitpoint in the
## mission is owned by one authority.
var _enemy_health: Dictionary[Node3D, int] = {}
## Archetype per live enemy, so armour is applied by the same authority that
## owns the hitpoints rather than trusted from the attacker.
var _enemy_stats: Dictionary[Node3D, EnemyStats] = {}

## However heavy the armour, a hit always does at least this much — otherwise an
## under-upgraded turret line does literally nothing and reads as broken rather
## than as outmatched.
const MIN_DAMAGE: int = 1

## Destructible player structures — extractors today. Held as a cached array as
## well as a health map because every living enemy scans it every frame looking
## for something to attack on the way past, and `get_nodes_in_group` allocates.
var _structures: Array[Node3D] = []
var _structure_health: Dictionary[Node3D, int] = {}

## Purchased level per upgrade track id. Absent means level zero.
var _upgrade_levels: Dictionary[StringName, int] = {}

## Seconds of orbital strike cooldown remaining. Zero means ready.
var _strike_cooldown: float = 0.0
var _effect_root: Node3D = null
var _strike_scene: PackedScene = null


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
		Command.SELL_TURRET:
			return _sell_turret(payload)
		Command.PURCHASE_UPGRADE:
			return _purchase_upgrade(payload)
		Command.CALL_ORBITAL_STRIKE:
			return _call_orbital_strike(payload)
		Command.TICK_ABILITIES:
			return _tick_abilities(payload)
		Command.SET_WAVE_COUNTDOWN:
			return _set_wave_countdown(payload)
		Command.WARN_WAVE:
			return _warn_wave(payload)
		Command.START_WAVE:
			return _start_wave(payload)
		Command.SPAWN_ENEMY:
			return _spawn_enemy(payload)
		Command.DAMAGE_ENEMY:
			return _damage_enemy(payload)
		Command.DAMAGE_BASE:
			return _damage_base(payload)
		Command.DAMAGE_STRUCTURE:
			return _damage_structure(payload)
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


## Seconds until the next wave, or -1 when one is already arriving.
func get_seconds_to_wave() -> int:
	return _seconds_to_wave


func get_map_half_extent() -> float:
	return 0.0 if _config == null else _config.map_half_extent


func get_base_health() -> int:
	return _base_health


func get_mission_config() -> MissionConfig:
	return _config


func get_wave_config() -> WaveConfig:
	if _config == null:
		return null
	return _config.wave_config


func get_upgrade_tracks() -> Array[UpgradeTrack]:
	if _config == null:
		return []
	return _config.upgrade_tracks


func get_upgrade_track(track_id: StringName) -> UpgradeTrack:
	for track: UpgradeTrack in get_upgrade_tracks():
		if track != null and track.id == track_id:
			return track
	return null


func get_upgrade_level(track_id: StringName) -> int:
	return _upgrade_levels.get(track_id, 0)


## Accumulated effect of a track at its current level. Zero for anything
## unpurchased or unknown, so callers can apply it unconditionally.
func get_upgrade_effect(track_id: StringName) -> float:
	var track: UpgradeTrack = get_upgrade_track(track_id)
	if track == null:
		return 0.0
	return track.effect_at_level(get_upgrade_level(track_id))


## Cost of the next level, or 0 when the track is maxed.
func get_upgrade_cost(track_id: StringName) -> int:
	var track: UpgradeTrack = get_upgrade_track(track_id)
	if track == null:
		return 0
	return track.cost_for_level(get_upgrade_level(track_id) + 1)


func get_orbital_strike_stats() -> OrbitalStrikeStats:
	return null if _config == null else _config.orbital_strike


func get_orbital_cooldown() -> float:
	return _strike_cooldown


func can_call_orbital_strike() -> bool:
	var stats: OrbitalStrikeStats = get_orbital_strike_stats()
	if stats == null or not _run_active:
		return false
	return _strike_cooldown <= 0.0 and _credits >= stats.cost


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
	for structure: Node3D in _structures:
		if _flat_distance(world_position, structure.global_position) < _config.turret_min_structure_distance:
			return false
	return true


func get_lane_count() -> int:
	return _enemy_paths.size()


func get_lane_name(lane_index: int) -> String:
	if lane_index < 0 or lane_index >= _lane_names.size():
		return "UNKNOWN"
	return _lane_names[lane_index]


func get_enemy_paths() -> Array[PackedVector3Array]:
	return _enemy_paths


## Head of a lane — where its enemies enter the map.
func get_lane_spawn_position(lane_index: int) -> Vector3:
	if lane_index < 0 or lane_index >= _enemy_paths.size():
		return Vector3.ZERO
	return _enemy_paths[lane_index][0]


func get_base_node() -> Node3D:
	return _base


## Live destructible structures. Returned as the cached array rather than a
## fresh one — enemies read this every frame and must not allocate.
func get_attackable_structures() -> Array[Node3D]:
	return _structures


func get_structure_health(structure: Node3D) -> int:
	return _structure_health.get(structure, 0)


## Base trickle plus whatever the surviving extractors are producing. Losing a
## forward node is meant to be felt in the credit counter, not just on the map.
func get_income_per_second() -> float:
	if _config == null:
		return 0.0
	var per_extractor: float = _config.extractor_credits_per_second \
		+ get_upgrade_effect(&"extraction")
	return _config.base_credits_per_second + per_extractor * float(_structures.size())


# --- Command handlers ---------------------------------------------------------

func _begin_mission(payload: Dictionary) -> bool:
	_config = payload.get("config", null) as MissionConfig
	_base = payload.get("base", null) as Node3D
	_enemy_root = payload.get("enemy_root", null) as Node3D
	_turret_root = payload.get("turret_root", null) as Node3D
	_enemy_scene = payload.get("enemy_scene", null) as PackedScene
	_effect_root = payload.get("effect_root", null) as Node3D
	_strike_scene = payload.get("strike_scene", null) as PackedScene
	_turret_scene = payload.get("turret_scene", null) as PackedScene
	if _config == null or _base == null or _enemy_root == null or _turret_root == null:
		command_rejected.emit(Command.BEGIN_MISSION, "mission wiring incomplete")
		return false
	if _enemy_scene == null or _turret_scene == null:
		command_rejected.emit(Command.BEGIN_MISSION, "enemy or turret scene missing")
		return false

	_enemy_health.clear()
	_enemy_stats.clear()
	_strike_cooldown = 0.0
	_upgrade_levels.clear()
	_enemy_paths = []
	_lane_names = PackedStringArray()
	_register_structures(payload.get("structure_root", null) as Node3D)
	_wave_number = 0
	_seconds_to_wave = -1
	_credits = _config.starting_credits
	_base_health = _config.base_max_health
	_run_active = true

	mission_started.emit()
	credits_changed.emit(_credits)
	base_health_changed.emit(_base_health, _config.base_max_health)
	income_changed.emit(get_income_per_second())
	orbital_cooldown_changed.emit(_strike_cooldown)
	for structure: Node3D in _structures:
		structure_damaged.emit(structure, _structure_health[structure], _config.extractor_max_health)
	return true


func _register_structures(structure_root: Node3D) -> void:
	_structures = []
	_structure_health.clear()
	if structure_root == null:
		return
	for child: Node in structure_root.get_children():
		var structure := child as Node3D
		if structure == null:
			continue
		_structures.append(structure)
		_structure_health[structure] = _config.extractor_max_health


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
	_lane_names = payload.get("names", PackedStringArray())
	while _lane_names.size() < paths.size():
		_lane_names.append("LANE %d" % (_lane_names.size() + 1))
	enemy_paths_ready.emit(_enemy_paths)
	return true


func _set_wave_countdown(payload: Dictionary) -> bool:
	var seconds_left: int = int(payload.get("seconds_left", 0))
	var wave_number: int = int(payload.get("wave_number", 0))
	if seconds_left == _seconds_to_wave:
		return false
	_seconds_to_wave = seconds_left
	wave_countdown_changed.emit(seconds_left, wave_number)
	return true


func _warn_wave(payload: Dictionary) -> bool:
	var wave_number: int = int(payload.get("wave_number", 0))
	var lanes: PackedInt32Array = payload.get("lanes", PackedInt32Array())
	if wave_number <= 0:
		return false
	var names: PackedStringArray = PackedStringArray()
	for lane_index: int in lanes:
		names.append(get_lane_name(lane_index))
	wave_incoming.emit(wave_number, names)
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


## Refunds a placed turret at a fraction of its cost. The fraction is what stops
## this being a free undo — repositioning should cost something, or placement
## stops being a decision.
func _sell_turret(payload: Dictionary) -> bool:
	var turret := payload.get("turret", null) as Node3D
	if turret == null or not is_instance_valid(turret):
		return false
	if turret.get_parent() != _turret_root:
		command_rejected.emit(Command.SELL_TURRET, "not a placed turret")
		return false

	var refund: int = get_turret_refund()
	var where: Vector3 = turret.global_position
	turret.queue_free()

	_credits += refund
	credits_changed.emit(_credits)
	turret_sold.emit(where, refund)
	return true


func get_turret_refund() -> int:
	if _config == null:
		return 0
	return int(floorf(float(get_turret_cost()) * _config.turret_refund_fraction))


func _call_orbital_strike(payload: Dictionary) -> bool:
	var stats: OrbitalStrikeStats = get_orbital_strike_stats()
	if stats == null or _strike_scene == null or _effect_root == null:
		command_rejected.emit(Command.CALL_ORBITAL_STRIKE, "orbital support unavailable")
		return false
	if _strike_cooldown > 0.0:
		command_rejected.emit(Command.CALL_ORBITAL_STRIKE, "still cooling down")
		return false
	if _credits < stats.cost:
		command_rejected.emit(Command.CALL_ORBITAL_STRIKE, "not enough credits")
		return false

	var where: Vector3 = payload.get("position", Vector3.ZERO)
	if absf(where.x) > _config.map_half_extent or absf(where.z) > _config.map_half_extent:
		command_rejected.emit(Command.CALL_ORBITAL_STRIKE, "outside the battlefield")
		return false

	var strike := _strike_scene.instantiate() as Node3D
	if strike == null:
		return false
	strike.set("stats", stats)
	strike.connect("impacted", _on_strike_impacted)
	_effect_root.add_child(strike)
	strike.global_position = Vector3(where.x, 0.0, where.z)

	_credits -= stats.cost
	_strike_cooldown = stats.cooldown
	credits_changed.emit(_credits)
	orbital_cooldown_changed.emit(_strike_cooldown)
	orbital_strike_called.emit(strike.global_position)
	return true


func _on_strike_impacted(world_position: Vector3, killed: int) -> void:
	orbital_strike_impacted.emit(world_position, killed)


## Driven by AbilityTicker rather than by a _process loop in the bus, so the bus
## stays a pure command sink.
func _tick_abilities(payload: Dictionary) -> bool:
	var delta: float = float(payload.get("delta", 0.0))
	if delta <= 0.0 or _strike_cooldown <= 0.0:
		return false
	_strike_cooldown = maxf(0.0, _strike_cooldown - delta)
	orbital_cooldown_changed.emit(_strike_cooldown)
	return true


func _purchase_upgrade(payload: Dictionary) -> bool:
	var track_id: StringName = payload.get("track_id", &"")
	var track: UpgradeTrack = get_upgrade_track(track_id)
	if track == null:
		command_rejected.emit(Command.PURCHASE_UPGRADE, "no such upgrade track")
		return false

	var next_level: int = get_upgrade_level(track_id) + 1
	if next_level > track.max_level:
		command_rejected.emit(Command.PURCHASE_UPGRADE, "already at maximum level")
		return false

	var cost: int = track.cost_for_level(next_level)
	if _credits < cost:
		command_rejected.emit(Command.PURCHASE_UPGRADE, "not enough credits")
		return false

	_credits -= cost
	_upgrade_levels[track_id] = next_level
	credits_changed.emit(_credits)
	upgrade_purchased.emit(track_id, next_level)
	# Extraction changes the payout rate, so anything showing income has to hear
	# about it too.
	income_changed.emit(get_income_per_second())
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
	_enemy_stats[enemy] = stats
	enemy_spawned.emit(enemy)
	return true


func _damage_enemy(payload: Dictionary) -> bool:
	var enemy := payload.get("enemy", null) as Node3D
	var amount: int = int(payload.get("amount", 0))
	if enemy == null or amount <= 0 or not _enemy_health.has(enemy):
		return false

	var archetype: EnemyStats = _enemy_stats.get(enemy, null)
	var armor: int = 0 if archetype == null else archetype.armor
	var effective: int = maxi(MIN_DAMAGE, amount - armor)

	var remaining: int = _enemy_health[enemy] - effective
	if remaining > 0:
		_enemy_health[enemy] = remaining
		return true

	_enemy_health.erase(enemy)
	_enemy_stats.erase(enemy)
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


func _damage_structure(payload: Dictionary) -> bool:
	var structure := payload.get("structure", null) as Node3D
	var amount: int = int(payload.get("amount", 0))
	if structure == null or amount <= 0 or not _structure_health.has(structure):
		return false

	var remaining: int = maxi(0, _structure_health[structure] - amount)
	_structure_health[structure] = remaining
	structure_damaged.emit(structure, remaining, _config.extractor_max_health)
	if remaining > 0:
		return true

	# The node stays in the scene as a wreck; it just stops being a target and
	# stops paying out.
	_structure_health.erase(structure)
	_structures.erase(structure)
	structure_destroyed.emit(structure)
	income_changed.emit(get_income_per_second())
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
