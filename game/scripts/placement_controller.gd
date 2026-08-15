class_name PlacementController
extends Node3D

## Turret placement input.
##
## Lineage: this is the camera raycast and ground-hit plumbing from the old
## rts_controller.gd. Clicking the ground to place a structure is the same
## operation the move order used to be, so the raycast is unchanged and only the
## order path is retargeted. Unit selection is gone — the player builds and
## places, they do not micro (CLAUDE.md, phase 0).
##
## Touch works through Godot's mouse emulation, so the same click action covers
## both desktop and the planned mobile port.

@export var camera: Camera3D
@export var placement_marker: PlacementMarker

@export var ground_collision_mask: int = 1

var _hover_position: Vector3 = Vector3.ZERO
var _has_hover: bool = false


func _ready() -> void:
	GameCommands.credits_changed.connect(_on_credits_changed)
	GameCommands.turret_placed.connect(_on_battlefield_changed)
	GameCommands.run_ended.connect(_on_run_ended)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(event.position)
		return
	if event is InputEventMouseButton and event.pressed:
		if event.is_action_pressed("place_structure"):
			_place_at(event.position)


func _update_hover(screen_position: Vector2) -> void:
	if placement_marker == null:
		return
	if not GameCommands.is_run_active():
		placement_marker.hide_ghost()
		return

	var hit := _raycast(screen_position, ground_collision_mask)
	if hit.is_empty():
		_has_hover = false
		placement_marker.hide_ghost()
		return

	_hover_position = hit.get("position", Vector3.ZERO)
	_has_hover = true
	placement_marker.show_ghost(_hover_position, _is_placeable(_hover_position))


func _place_at(screen_position: Vector2) -> void:
	if not GameCommands.is_run_active():
		return
	var hit := _raycast(screen_position, ground_collision_mask)
	if hit.is_empty():
		return

	var target: Vector3 = hit.get("position", Vector3.ZERO)
	var placed: bool = GameCommands.submit(GameCommandBus.Command.PLACE_TURRET, {
		"position": target,
	})
	if placement_marker != null:
		placement_marker.flash(target, placed)
	_has_hover = false


## Both halves of the rule, so the ghost never claims a placement the command
## would refuse.
func _is_placeable(world_position: Vector3) -> bool:
	return GameCommands.can_afford_turret() and GameCommands.can_place_turret(world_position)


func _on_credits_changed(_credits: int) -> void:
	_refresh_ghost()


func _on_battlefield_changed(_turret: Node3D) -> void:
	_refresh_ghost()


func _on_run_ended(_final_wave: int) -> void:
	if placement_marker != null:
		placement_marker.hide_ghost()


func _refresh_ghost() -> void:
	if not _has_hover or placement_marker == null:
		return
	placement_marker.show_ghost(_hover_position, _is_placeable(_hover_position))


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
