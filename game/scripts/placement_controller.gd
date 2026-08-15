class_name PlacementController
extends Node3D

## Pointer input: turret placement and camera panning off the same gesture.
##
## Lineage: the camera raycast and ground-hit plumbing is still the original
## rts_controller.gd, retargeted from move orders to structure placement. Unit
## selection is not a Phase 0 feature — the player builds and places.
##
## Now that the map is larger than the screen, drag has to mean "pan" while tap
## still means "place." Rather than reserving a second mouse button — which
## touch does not have — this measures the gesture: move past a small threshold
## and it becomes a pan, release inside it and it places. That reads identically
## under Godot's mouse emulation on touch, so the mobile target keeps working.

@export var camera: Camera3D
@export var camera_rig: CameraRig
@export var placement_marker: PlacementMarker

@export var ground_collision_mask: int = 1
## Clickable player structures sit on their own layer so a tap can be tested
## against them before it is treated as a placement.
@export var structure_collision_mask: int = 2

## Pixels of travel before a press stops being a tap. Generous enough to
## tolerate an unsteady finger, tight enough that deliberate taps land.
@export var drag_threshold: float = 10.0

var _pointer_down: bool = false
var _dragging: bool = false
var _press_position: Vector2 = Vector2.ZERO
var _hover_position: Vector3 = Vector3.ZERO
var _has_hover: bool = false


func _ready() -> void:
	GameCommands.credits_changed.connect(_on_credits_changed)
	GameCommands.turret_placed.connect(_on_battlefield_changed)
	GameCommands.run_ended.connect(_on_run_ended)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_motion(event as InputEventMouseMotion)


func _handle_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom(1.0)
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom(-1.0)
		return
	if not event.is_action_pressed("place_structure") and not event.is_action_released("place_structure"):
		return

	if event.pressed:
		_pointer_down = true
		_dragging = false
		_press_position = event.position
		return

	# Release: a gesture that never became a drag is a placement.
	if _pointer_down and not _dragging:
		_place_at(event.position)
	_pointer_down = false
	_dragging = false


func _handle_motion(event: InputEventMouseMotion) -> void:
	if _pointer_down:
		if not _dragging and event.position.distance_to(_press_position) > drag_threshold:
			_dragging = true
			if placement_marker != null:
				placement_marker.hide_ghost()
		if _dragging and camera_rig != null:
			camera_rig.pan_by_screen_delta(event.relative)
			_has_hover = false
		return
	_update_hover(event.position)


func _zoom(steps: float) -> void:
	if camera_rig == null:
		return
	camera_rig.zoom_by_steps(steps)
	_has_hover = false
	if placement_marker != null:
		placement_marker.hide_ghost()


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
	if _try_open_upgrade_panel(screen_position):
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


## Tapping the Spire opens its upgrade panel instead of placing anything. The
## structure layer is tested first so the building always wins over the ground
## behind it.
func _try_open_upgrade_panel(screen_position: Vector2) -> bool:
	var hit := _raycast(screen_position, structure_collision_mask)
	if hit.is_empty():
		return false
	var collider := hit.get("collider") as Node
	if collider == null:
		return false
	if collider.get_parent() != GameCommands.get_base_node():
		return false

	var panel: Node = get_tree().get_first_node_in_group("upgrade_panel")
	if panel == null:
		return false
	panel.call("toggle")
	return true


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
