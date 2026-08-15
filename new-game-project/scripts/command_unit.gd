class_name CommandUnit
extends Node3D

## A commandable RTS unit. It receives move orders and drives itself toward a
## target point on the XZ plane. Its forward basis is -Z, matching Godot's
## default convention, so an idle unit faces -Z and look_at keeps movement
## facing consistent with the top-down command math.

@export var move_speed: float = 6.0

@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var collision_body: StaticBody3D = $Collision

var _move_target: Vector3 = Vector3.ZERO
var _has_order: bool = false
var _is_selected: bool = false


func _ready() -> void:
	# The physics collider is what a selection raycast hits, so it carries the
	# "commandable" group rather than the Node3D root.
	collision_body.add_to_group("commandable")
	selection_ring.visible = false
	_move_target = global_position


func _process(delta: float) -> void:
	if not _has_order:
		return
	var offset: Vector3 = _move_target - global_position
	offset.y = 0.0
	if offset.length() < 0.15:
		_has_order = false
		return
	var direction: Vector3 = offset.normalized()
	global_position += direction * move_speed * delta
	# look_at points the node's local -Z (forward) at the target, keeping the
	# unit's forward basis aligned with world -Z for travel.
	look_at(global_position + direction, Vector3.UP)


func is_selected() -> bool:
	return _is_selected


func set_selected(value: bool) -> void:
	_is_selected = value
	selection_ring.visible = value


func order_move(target: Vector3) -> void:
	_move_target = target
	_move_target.y = global_position.y
	_has_order = true
