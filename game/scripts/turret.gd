class_name Turret
extends Node3D

## Auto-firing defensive structure. Picks the nearest enemy inside its range and
## shoots it until it dies or leaves.
##
## Both the retarget and the shot run off timers rather than _process. Firing is
## an event on a fixed interval, and target reacquisition four times a second is
## visually identical to doing it every frame at a fraction of the cost — which
## matters once there are a dozen turrets and a few hundred enemies.

@onready var head: MeshInstance3D = $Head
@onready var beam: MeshInstance3D = $Beam
@onready var range_ring: MeshInstance3D = $RangeRing
@onready var fire_timer: Timer = $FireTimer
@onready var retarget_timer: Timer = $RetargetTimer

## Injected by the bus before the node enters the tree.
var stats: TurretStats = null

var _target: Node3D = null

## Base stats plus whatever the Spire has bought. Recomputed on purchase rather
## than read per shot, and never written back into `stats` — that resource is
## shared by every turret and would persist the change across missions.
var _damage: int = 0
var _range: float = 0.0

const BEAM_FLASH_SECONDS: float = 0.06
const MUZZLE_HEIGHT: float = 0.9
## Fire interval never drops below this no matter how much Targeting is bought.
const MIN_FIRE_INTERVAL: float = 0.08


func _ready() -> void:
	add_to_group("turret")
	beam.visible = false
	if stats == null:
		# Without stats there is nothing to fire; leaving the timers stopped is
		# enough to make the turret inert.
		return

	_apply_upgrades()
	GameCommands.upgrade_purchased.connect(_on_upgrade_purchased)

	fire_timer.timeout.connect(_on_fire_timer_timeout)
	retarget_timer.wait_time = stats.retarget_interval
	retarget_timer.timeout.connect(_acquire_target)

	_acquire_target()
	fire_timer.start()
	retarget_timer.start()


func _on_upgrade_purchased(_track_id: StringName, _level: int) -> void:
	_apply_upgrades()


func _apply_upgrades() -> void:
	_damage = stats.damage + int(GameCommands.get_upgrade_effect(&"weapons"))
	_range = stats.attack_range + GameCommands.get_upgrade_effect(&"optics")

	var rate_bonus: float = clampf(GameCommands.get_upgrade_effect(&"targeting"), 0.0, 0.9)
	fire_timer.wait_time = maxf(MIN_FIRE_INTERVAL, stats.fire_interval * (1.0 - rate_bonus))
	range_ring.scale = Vector3(_range, 1.0, _range)


func _acquire_target() -> void:
	var nearest: Node3D = null
	var nearest_distance: float = _range
	for candidate: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy := candidate as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance: float = _flat_distance(global_position, enemy.global_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest = enemy
	_target = nearest
	if _target != null:
		_face(_target.global_position)


func _on_fire_timer_timeout() -> void:
	if not _has_valid_target():
		_acquire_target()
	if not _has_valid_target():
		return

	var target_position: Vector3 = _target.global_position
	_face(target_position)
	_flash_beam(target_position)
	GameCommands.submit(GameCommandBus.Command.DAMAGE_ENEMY, {
		"enemy": _target,
		"amount": _damage,
		"source": self,
	})


func _has_valid_target() -> bool:
	if _target == null or not is_instance_valid(_target):
		return false
	return _flat_distance(global_position, _target.global_position) <= _range


func _face(target_position: Vector3) -> void:
	var flat_target := Vector3(target_position.x, head.global_position.y, target_position.z)
	if flat_target.is_equal_approx(head.global_position):
		return
	head.look_at(flat_target, Vector3.UP)


## The beam is a unit-length box along local -Z, so pointing it and stretching it
## to the target distance is all the shot feedback a grey-box needs.
func _flash_beam(target_position: Vector3) -> void:
	var muzzle: Vector3 = global_position + Vector3.UP * MUZZLE_HEIGHT
	var hit: Vector3 = Vector3(target_position.x, target_position.y + 0.7, target_position.z)
	var distance: float = muzzle.distance_to(hit)
	if distance < 0.01:
		return

	beam.global_position = muzzle.lerp(hit, 0.5)
	beam.look_at(hit, Vector3.UP)
	beam.scale = Vector3(1.0, 1.0, distance)
	beam.visible = true

	var tween: Tween = create_tween()
	tween.tween_interval(BEAM_FLASH_SECONDS)
	tween.tween_callback(func() -> void: beam.visible = false)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
