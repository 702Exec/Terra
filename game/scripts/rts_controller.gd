class_name RTSController
extends Node3D

## Top-down RTS command layer. Left-click selects a commandable unit and
## right-click issues a move order at the clicked ground position. Raycasts use
## the orthographic camera's project_ray API, and the ground plane is XZ at
## y=0 so the coordinate math stays consistent with -Z world forward.

@export var camera: Camera3D
@export var move_marker: Node3D

@export var ground_collision_layer: int = 1
@export var unit_collision_layer: int = 2

var _selected_unit


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	if not event.pressed:
		return
	if event.is_action_pressed("select"):
		_handle_select(event.position)
	elif event.is_action_pressed("move_order"):
		_handle_move_order(event.position)


func _handle_select(screen_position: Vector2) -> void:
	var hit := _raycast(screen_position, unit_collision_layer)
	if hit.is_empty():
		_clear_selection()
		return
	var collider := hit.get("collider") as Node
	if collider != null and collider.is_in_group("commandable"):
		var selected_unit := collider.get_parent()
		if selected_unit != null and selected_unit.has_method("set_selected"):
			_set_selection(selected_unit)
			return
	_clear_selection()


func _handle_move_order(screen_position: Vector2) -> void:
	if _selected_unit == null:
		return
	var hit := _raycast(screen_position, ground_collision_layer)
	if hit.is_empty():
		return
	var target: Vector3 = hit.get("position", _selected_unit.global_position)
	_selected_unit.order_move(target)
	if move_marker != null:
		var marker = move_marker
		if marker.has_method("show_at"):
			marker.show_at(target)


func _set_selection(unit_to_select) -> void:
	if _selected_unit == unit_to_select:
		return
	_clear_selection()
	_selected_unit = unit_to_select
	_selected_unit.set_selected(true)


func _clear_selection() -> void:
	if _selected_unit != null:
		_selected_unit.set_selected(false)
		_selected_unit = null


func _raycast(screen_position: Vector2, collision_mask: int) -> Dictionary:
	if camera == null:
		return {}
	var origin: Vector3 = camera.project_ray_origin(screen_position)
	var direction: Vector3 = camera.project_ray_normal(screen_position)
	var end: Vector3 = origin + direction * 2000.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return get_world_3d().direct_space_state.intersect_ray(query)
