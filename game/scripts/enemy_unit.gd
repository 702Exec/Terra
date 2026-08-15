class_name EnemyUnit
extends Node3D

## A native defender walking the invasion lane toward the harvest base.
##
## Lineage: this is the XZ-plane movement driver from the old command_unit.gd,
## with the selection concern removed. Its forward basis is -Z, so look_at keeps
## travel facing consistent with the rest of the world math.
##
## Two things this unit deliberately does not own:
##
## 1. Its own pathfinding agent. Every enemy reads the same precomputed lane
##    (CLAUDE.md rule 2) with a per-unit lateral offset so the column reads as a
##    mass. When counts get high this swaps for a flow-field lookup and nothing
##    else in the file has to change.
## 2. Its own hitpoints. Health lives in GameCommandBus, which is the only thing
##    allowed to kill it.

@onready var attack_timer: Timer = $AttackTimer

## Injected by the bus before the node enters the tree.
var stats: EnemyStats = null
var path: PackedVector3Array = PackedVector3Array()
var target_base: Node3D = null

var _path_index: int = 0
var _lane_offset: Vector3 = Vector3.ZERO
var _in_contact: bool = false
## What this unit is currently chewing on: null means the base.
var _structure_target: Node3D = null

const ARRIVAL_EPSILON: float = 0.25


func _ready() -> void:
	add_to_group("enemy")
	if stats == null:
		set_process(false)
		return

	# The offset is per-unit and constant, so the whole wave shares one path but
	# arrives as a spread front rather than a single-file line.
	var spread: float = stats.lane_spread
	_lane_offset = Vector3(randf_range(-spread, spread), 0.0, randf_range(-spread, spread))

	attack_timer.wait_time = stats.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	_advance_to_nearest_waypoint()


func _process(delta: float) -> void:
	if _in_contact:
		# A structure under attack can die under someone else's fire; when it
		# does, resume the walk rather than standing over the wreck.
		if _structure_target != null and not _is_target_live(_structure_target):
			_leave_contact()
		return

	# Anything of the player's standing near the lane gets torn down on the way
	# past. This is what makes a forward extractor genuinely exposed while the
	# lane solve stays untouched.
	var structure: Node3D = _nearest_structure_in_reach()
	if structure != null:
		_enter_contact(structure)
		return

	if target_base != null and _flat_distance(global_position, target_base.global_position) <= stats.contact_range:
		_enter_contact(null)
		return
	if _path_index >= path.size():
		_enter_contact(null)
		return

	var offset: Vector3 = _waypoint(_path_index) - global_position
	offset.y = 0.0
	if offset.length() <= ARRIVAL_EPSILON:
		_path_index += 1
		if _path_index >= path.size():
			_enter_contact(null)
		return

	var direction: Vector3 = offset.normalized()
	global_position += direction * stats.move_speed * delta
	look_at(global_position + direction, Vector3.UP)


## The lane offset is faded out over the final waypoint so units converge on the
## base instead of orbiting it at a fixed distance.
func _waypoint(index: int) -> Vector3:
	var point: Vector3 = path[index]
	if index >= path.size() - 1:
		return point
	return point + _lane_offset


## Spawned units start at the head of the path, but a unit dropped anywhere on
## the map should still pick a sensible entry point.
func _advance_to_nearest_waypoint() -> void:
	var best_index: int = 0
	var best_distance: float = INF
	for i: int in range(path.size()):
		var distance: float = _flat_distance(global_position, path[i])
		if distance < best_distance:
			best_distance = distance
			best_index = i
	_path_index = best_index


## The cached structure list comes straight off the bus, so this costs a handful
## of distance checks per enemy per frame with no allocation.
func _nearest_structure_in_reach() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance: float = stats.structure_aggro_range
	for structure: Node3D in GameCommands.get_attackable_structures():
		if not is_instance_valid(structure):
			continue
		var distance: float = _flat_distance(global_position, structure.global_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest = structure
	return nearest


func _is_target_live(structure: Node3D) -> bool:
	if not is_instance_valid(structure):
		return false
	return GameCommands.get_attackable_structures().has(structure)


## `structure` of null means the target is the base, which ends the walk.
func _enter_contact(structure: Node3D) -> void:
	if _in_contact:
		return
	_in_contact = true
	_structure_target = structure
	if structure == null:
		_path_index = path.size()
	_strike()
	attack_timer.start()


func _leave_contact() -> void:
	_in_contact = false
	_structure_target = null
	attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	_strike()


func _strike() -> void:
	if _structure_target != null:
		GameCommands.submit(GameCommandBus.Command.DAMAGE_STRUCTURE, {
			"structure": _structure_target,
			"amount": stats.contact_damage,
			"source": self,
		})
		return
	if target_base == null:
		return
	GameCommands.submit(GameCommandBus.Command.DAMAGE_BASE, {
		"amount": stats.contact_damage,
		"source": self,
	})


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
