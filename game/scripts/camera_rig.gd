class_name CameraRig
extends Node3D

## Pan and zoom for a fixed three-quarter camera.
##
## The angle never changes and the camera never rotates (CLAUDE.md): this moves
## a focus point across the ground plane and holds the camera at a constant
## offset above and behind it. Zoom adjusts orthographic size only, inside a
## tight range, so the viewing angle reads identically at every distance.
##
## The focus is clamped to the battlefield, which is what stops the player from
## losing the map entirely while panning between a base and a forward node.

@export var camera: Camera3D

## Offset from the focus point to the camera, in world space. Its Y and Z
## determine the pitch, so changing it changes the fixed angle — don't, unless
## the art direction changes.
@export var camera_offset: Vector3 = Vector3(0.0, 30.0, 21.0)

@export_group("Zoom")
## Tight enough that the map does not fit on screen — which is the point. At the
## widest setting the whole battlefield is visible and panning locks, so zoom
## doubles as the strategic overview.
@export var default_zoom: float = 26.0
@export var min_zoom: float = 18.0
@export var max_zoom: float = 56.0
@export var zoom_step: float = 3.0

@export_group("Pan")
@export var keyboard_pan_speed: float = 34.0
## Half-extent of the battlefield. The pan limit is derived from this and the
## current zoom rather than being a fixed number — how far you should be allowed
## to travel depends on how much you can already see. Zoomed out far enough to
## take in the whole map, there is nothing to pan to and the camera locks.
@export var map_half_extent: float = 32.0

## Sine of the camera pitch. Screen-vertical motion covers more ground than
## screen-horizontal motion at a tilt, and pan has to account for that or
## dragging feels lopsided.
var _pitch_sine: float = 1.0

var _focus: Vector3 = Vector3.ZERO


func _ready() -> void:
	add_to_group("camera_rig")
	GameCommands.mission_started.connect(_on_mission_started)
	if camera == null:
		push_warning("CameraRig has no camera; pan and zoom are disabled.")
		set_process(false)
		return
	var offset_flat: float = Vector2(camera_offset.y, camera_offset.z).length()
	_pitch_sine = camera_offset.y / offset_flat if offset_flat > 0.001 else 1.0
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = default_zoom
	_apply()


## The ground plane's size is mission data, not scene wiring — the export is a
## fallback for running this scene on its own.
func _on_mission_started() -> void:
	var half: float = GameCommands.get_map_half_extent()
	if half > 0.0:
		map_half_extent = half
	_apply()


func _process(delta: float) -> void:
	var move: Vector2 = Vector2(
		float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
			- float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
			- float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	)
	if move == Vector2.ZERO:
		return
	# Screen-down is world-south, so the Z term is not negated the way the
	# drag path is — this is a direct world-space nudge, not a drag.
	var step: float = keyboard_pan_speed * delta
	_focus += Vector3(move.x * step, 0.0, move.y * step)
	_apply()


## Drag panning. `screen_delta` is the pointer's movement in pixels; the world
## moves with the finger, so the focus travels the opposite way.
func pan_by_screen_delta(screen_delta: Vector2) -> void:
	var units_per_pixel: float = camera.size / float(get_viewport().get_visible_rect().size.y)
	_focus += Vector3(
		-screen_delta.x * units_per_pixel,
		0.0,
		-screen_delta.y * units_per_pixel / _pitch_sine
	)
	_apply()


func zoom_by_steps(steps: float) -> void:
	camera.size = clampf(camera.size - steps * zoom_step, min_zoom, max_zoom)
	_apply()


func focus_on(world_position: Vector3) -> void:
	_focus = Vector3(world_position.x, 0.0, world_position.z)
	_apply()


func get_focus() -> Vector3:
	return _focus


## Keeps the battlefield filling the frame. The visible ground is wider than it
## is deep at this tilt — screen height covers `size` world units vertically,
## which stretches to `size / sin(pitch)` of actual ground depth — so the two
## axes clamp differently.
func _apply() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = viewport_size.x / maxf(1.0, viewport_size.y)

	var visible_half_width: float = camera.size * aspect * 0.5
	var visible_half_depth: float = camera.size / (2.0 * _pitch_sine)

	var limit_x: float = maxf(0.0, map_half_extent - visible_half_width)
	var limit_z: float = maxf(0.0, map_half_extent - visible_half_depth)

	_focus.x = clampf(_focus.x, -limit_x, limit_x)
	_focus.z = clampf(_focus.z, -limit_z, limit_z)
	camera.global_position = _focus + camera_offset
