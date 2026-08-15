class_name OrbitalStrike
extends Node3D

## The strike itself: a marked target, a flight time, then impact.
##
## The marker is visible for the whole flight, to both sides of the fiction —
## the player watches to see whether their prediction was right, and enemies
## walking through the circle can leave it before the round lands. That delay is
## what makes calling a strike a read rather than a delete button.
##
## Damage is submitted per target through the bus, so armour is applied by the
## same authority that owns hitpoints. A Mite dies outright; a Carapace shrugs.

@onready var target_ring: MeshInstance3D = $TargetRing
@onready var column: MeshInstance3D = $Column
@onready var blast_ring: MeshInstance3D = $BlastRing
@onready var flight_timer: Timer = $FlightTimer

## Injected by the bus before the node enters the tree.
var stats: OrbitalStrikeStats = null

signal impacted(world_position: Vector3, killed: int)

const FADE_SECONDS: float = 0.55


func _ready() -> void:
	column.visible = false
	blast_ring.visible = false
	if stats == null:
		queue_free()
		return

	target_ring.scale = Vector3(stats.radius, 1.0, stats.radius)
	# A pulse rather than a static circle, so a marked area reads as a countdown
	# at a glance from across the map.
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(target_ring, "scale",
		Vector3(stats.radius * 0.88, 1.0, stats.radius * 0.88), 0.28)
	pulse.tween_property(target_ring, "scale",
		Vector3(stats.radius, 1.0, stats.radius), 0.28)

	flight_timer.wait_time = stats.flight_time
	flight_timer.one_shot = true
	flight_timer.timeout.connect(_on_impact)
	flight_timer.start()


func _on_impact() -> void:
	target_ring.visible = false
	column.visible = true
	blast_ring.visible = true
	blast_ring.scale = Vector3(stats.radius * 0.25, 1.0, stats.radius * 0.25)

	var killed: int = _apply_damage()
	impacted.emit(global_position, killed)

	var wave: Tween = create_tween()
	wave.set_parallel(true)
	wave.tween_property(blast_ring, "scale",
		Vector3(stats.radius * 1.15, 1.0, stats.radius * 1.15), FADE_SECONDS)
	wave.tween_property(column, "scale", Vector3(0.2, 1.0, 0.2), FADE_SECONDS)
	wave.chain().tween_callback(queue_free)


## One group query for the whole strike rather than one per target.
func _apply_damage() -> int:
	var hit: int = 0
	for candidate: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy := candidate as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var offset: Vector2 = Vector2(
			enemy.global_position.x - global_position.x,
			enemy.global_position.z - global_position.z
		)
		if offset.length() > stats.radius:
			continue
		GameCommands.submit(GameCommandBus.Command.DAMAGE_ENEMY, {
			"enemy": enemy,
			"amount": stats.damage,
			"source": self,
		})
		hit += 1
	return hit
