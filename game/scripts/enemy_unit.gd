class_name EnemyUnit
extends Node3D

## A native defender walking the invasion lane toward the harvest engine.
##
## Lineage: the XZ-plane movement driver from the old command_unit.gd, with the
## selection concern removed. Forward basis is -Z.
##
## Three things this unit deliberately does not own:
##
## 1. Its own pathfinding agent. Every enemy on a lane reads the same precomputed
##    polyline (CLAUDE.md rule 2) with a per-unit lateral offset. Diversions to
##    attack a structure are straight-line moves, never path queries, so unit
##    count never multiplies the solve count.
## 2. Its own hitpoints or armour. Both live in GameCommandBus, which is the
##    only thing allowed to kill it.
## 3. Its own mesh or material. Those are cached per archetype and shared, so a
##    wave of four hundred allocates neither.

@onready var visual: MeshInstance3D = $Visual
@onready var beam: MeshInstance3D = $Beam
@onready var attack_timer: Timer = $AttackTimer

## Injected by the bus before the node enters the tree.
var stats: EnemyStats = null
var path: PackedVector3Array = PackedVector3Array()
var target_base: Node3D = null

var _path_index: int = 0
var _lane_offset: Vector3 = Vector3.ZERO
var _engaged: bool = false
## What this unit is attacking: null means the base.
var _structure_target: Node3D = null

const ARRIVAL_EPSILON: float = 0.25
const BEAM_FLASH_SECONDS: float = 0.08
const MUZZLE_HEIGHT: float = 0.8

## One mesh and one material per archetype, shared by every instance of it.
static var _mesh_cache: Dictionary[EnemyStats, CapsuleMesh] = {}
static var _material_cache: Dictionary[EnemyStats, StandardMaterial3D] = {}


func _ready() -> void:
	add_to_group("enemy")
	beam.visible = false
	if stats == null:
		set_process(false)
		return

	_build_visual()

	var spread: float = stats.lane_spread
	_lane_offset = Vector3(randf_range(-spread, spread), 0.0, randf_range(-spread, spread))

	attack_timer.wait_time = stats.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	_advance_to_nearest_waypoint()


## Art if the archetype supplies it, grey box otherwise. The swap is one
## branch, so nothing downstream cares which it got.
func _build_visual() -> void:
	if stats.visual_scene != null:
		var art := stats.visual_scene.instantiate() as Node3D
		if art != null:
			visual.visible = false
			add_child(art)
			return
	visual.mesh = _mesh_for(stats)
	visual.material_override = _material_for(stats)
	visual.position.y = stats.body_height * 0.5


static func _mesh_for(archetype: EnemyStats) -> CapsuleMesh:
	if not _mesh_cache.has(archetype):
		var mesh := CapsuleMesh.new()
		mesh.radius = archetype.body_radius
		mesh.height = maxf(archetype.body_height, archetype.body_radius * 2.0 + 0.01)
		_mesh_cache[archetype] = mesh
	return _mesh_cache[archetype]


static func _material_for(archetype: EnemyStats) -> StandardMaterial3D:
	if not _material_cache.has(archetype):
		var material := StandardMaterial3D.new()
		material.albedo_color = archetype.body_color
		_material_cache[archetype] = material
	return _material_cache[archetype]


func _process(delta: float) -> void:
	if _engaged:
		# A target can die under someone else's fire; when it does, resume.
		if _structure_target != null and not _is_target_live(_structure_target):
			_disengage()
		return

	var structure: Node3D = _nearest_structure_in_range()
	if structure != null:
		_engage(structure)
		return

	if target_base != null and _flat_distance(global_position, target_base.global_position) <= stats.attack_range:
		_engage(null)
		return

	if _path_index >= path.size():
		_engage(null)
		return

	var offset: Vector3 = _waypoint(_path_index) - global_position
	offset.y = 0.0
	if offset.length() <= ARRIVAL_EPSILON:
		_path_index += 1
		if _path_index >= path.size():
			_engage(null)
		return

	var direction: Vector3 = offset.normalized()
	global_position += direction * stats.move_speed * delta
	look_at(global_position + direction, Vector3.UP)


## The lane offset fades out on the final waypoint so units converge on the
## engine rather than orbiting it at a fixed distance.
func _waypoint(index: int) -> Vector3:
	var point: Vector3 = path[index]
	if index >= path.size() - 1:
		return point
	return point + _lane_offset


func _advance_to_nearest_waypoint() -> void:
	var best_index: int = 0
	var best_distance: float = INF
	for i: int in range(path.size()):
		var distance: float = _flat_distance(global_position, path[i])
		if distance < best_distance:
			best_distance = distance
			best_index = i
	_path_index = best_index


## Served from the bus's cached array, so this costs a handful of distance
## checks per enemy per frame with no allocation.
func _nearest_structure_in_range() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance: float = stats.attack_range
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


## `structure` of null means the target is the engine, which ends the walk.
func _engage(structure: Node3D) -> void:
	if _engaged:
		return
	_engaged = true
	_structure_target = structure
	if structure == null:
		_path_index = path.size()
	else:
		_face(structure.global_position)
	_strike()
	attack_timer.start()


func _disengage() -> void:
	_engaged = false
	_structure_target = null
	attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	_strike()


func _strike() -> void:
	var target: Node3D = _structure_target if _structure_target != null else target_base
	if target == null:
		return
	if stats.ranged:
		_flash_beam(target.global_position)

	if _structure_target != null:
		GameCommands.submit(GameCommandBus.Command.DAMAGE_STRUCTURE, {
			"structure": _structure_target,
			"amount": stats.attack_damage,
			"source": self,
		})
		return
	GameCommands.submit(GameCommandBus.Command.DAMAGE_BASE, {
		"amount": stats.attack_damage,
		"source": self,
	})


func _face(target_position: Vector3) -> void:
	var flat := Vector3(target_position.x, global_position.y, target_position.z)
	if flat.is_equal_approx(global_position):
		return
	look_at(flat, Vector3.UP)


## Ranged fire needs to be visible from across the map, or a Spitter line
## killing an extractor from standoff reads as the extractor dying on its own.
func _flash_beam(target_position: Vector3) -> void:
	var muzzle: Vector3 = global_position + Vector3.UP * MUZZLE_HEIGHT
	var hit: Vector3 = target_position + Vector3.UP * 1.2
	var distance: float = muzzle.distance_to(hit)
	if distance < 0.01:
		return

	beam.global_position = muzzle.lerp(hit, 0.5)
	beam.look_at(hit, Vector3.UP)
	beam.scale = Vector3(1.0, 1.0, distance)
	beam.visible = true

	var tween: Tween = create_tween()
	tween.tween_interval(BEAM_FLASH_SECONDS)
	tween.tween_callback(func() -> void:
		if is_instance_valid(beam):
			beam.visible = false)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
