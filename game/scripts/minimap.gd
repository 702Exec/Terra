class_name Minimap
extends Control

## Bottom-right minimap: the whole battlefield at a glance, plus where the
## camera currently is within it.
##
## Once the map stopped fitting on one screen this became required rather than
## decorative — the edge markers tell you something off-screen is being hit, but
## only this tells you what the board looks like.
##
## Tap or click anywhere on it to move the camera there. The control is far
## larger than the 48dp minimum, so it works as a touch target unchanged.

const BACKDROP: Color = Color(0.04, 0.06, 0.09, 0.82)
const BORDER: Color = Color(0.5, 0.58, 0.68, 0.55)
const GROUND: Color = Color(0.17, 0.29, 0.16, 0.9)
const LANE: Color = Color(0.85, 0.26, 0.2, 0.5)
const BASE: Color = Color(0.13, 0.72, 0.85)
const TURRET: Color = Color(0.35, 0.85, 0.95)
const EXTRACTOR: Color = Color(1.0, 0.78, 0.25)
const EXTRACTOR_LOST: Color = Color(0.35, 0.35, 0.38)
const ENEMY: Color = Color(1.0, 0.32, 0.26)
const VIEWPORT_BOX: Color = Color(1.0, 1.0, 1.0, 0.85)

## Ground half-extent, taken from MissionConfig at mission start.
var _map_half: float = 32.0
## Extractors that have been destroyed, kept so the wreck still reads.
var _lost: Array[Node3D] = []


func _ready() -> void:
	GameCommands.mission_started.connect(_on_mission_started)
	GameCommands.structure_destroyed.connect(_on_structure_destroyed)


func _on_mission_started() -> void:
	_lost.clear()
	var half: float = GameCommands.get_map_half_extent()
	if half > 0.0:
		_map_half = half


func _on_structure_destroyed(structure: Node3D) -> void:
	_lost.append(structure)


func _process(_delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var local: Vector2 = Vector2.ZERO
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if not button.pressed or not button.is_action_pressed("place_structure"):
			return
		local = button.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed:
			return
		local = touch.position
	else:
		return

	var rig: Node = get_tree().get_first_node_in_group("camera_rig")
	if rig == null:
		return
	rig.call("focus_on", _to_world(local))
	accept_event()


func _draw() -> void:
	var box: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(box, BACKDROP, true)
	draw_rect(box.grow(-2.0), GROUND, true)
	draw_rect(box, BORDER, false, 2.0)

	for index: int in range(GameCommands.get_lane_count()):
		draw_circle(_to_map(GameCommands.get_lane_spawn_position(index)), 4.0, LANE)

	for structure: Node3D in _lost:
		if is_instance_valid(structure):
			_draw_marker(structure.global_position, 4.0, EXTRACTOR_LOST)
	for structure: Node3D in GameCommands.get_attackable_structures():
		_draw_marker(structure.global_position, 5.0, EXTRACTOR)

	for turret: Node in get_tree().get_nodes_in_group("turret"):
		_draw_marker((turret as Node3D).global_position, 2.5, TURRET)

	for enemy: Node in get_tree().get_nodes_in_group("enemy"):
		draw_circle(_to_map((enemy as Node3D).global_position), 1.6, ENEMY)

	var base: Node3D = GameCommands.get_base_node()
	if base != null:
		_draw_marker(base.global_position, 7.0, BASE)

	_draw_viewport_box()


## The camera's visible ground footprint, so the player can see at a glance how
## much of the board they are currently looking at.
func _draw_viewport_box() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null or camera.projection != Camera3D.PROJECTION_ORTHOGONAL:
		return

	var screen: Vector2 = get_viewport_rect().size
	var aspect: float = screen.x / maxf(1.0, screen.y)
	var forward: Vector3 = -camera.global_transform.basis.z
	var pitch_sine: float = absf(forward.y)
	if pitch_sine < 0.001:
		return

	var origin: Vector3 = camera.global_position
	var focus: Vector3 = origin + forward * (-origin.y / forward.y)
	var half_width: float = camera.size * aspect * 0.5
	var half_depth: float = camera.size / (2.0 * pitch_sine)

	var top_left: Vector2 = _to_map(focus + Vector3(-half_width, 0.0, -half_depth))
	var bottom_right: Vector2 = _to_map(focus + Vector3(half_width, 0.0, half_depth))
	draw_rect(Rect2(top_left, bottom_right - top_left), VIEWPORT_BOX, false, 1.5)


func _draw_marker(world: Vector3, radius: float, color: Color) -> void:
	var point: Vector2 = _to_map(world)
	draw_rect(Rect2(point - Vector2(radius, radius), Vector2(radius, radius) * 2.0), color, true)


## World XZ to minimap pixels. North (-Z) is up, matching the camera.
func _to_map(world: Vector3) -> Vector2:
	var normalised: Vector2 = Vector2(
		(world.x + _map_half) / (_map_half * 2.0),
		(world.z + _map_half) / (_map_half * 2.0)
	)
	return normalised * size


func _to_world(local: Vector2) -> Vector3:
	var normalised: Vector2 = local / size
	return Vector3(
		normalised.x * _map_half * 2.0 - _map_half,
		0.0,
		normalised.y * _map_half * 2.0 - _map_half
	)
