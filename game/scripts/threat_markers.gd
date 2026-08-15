class_name ThreatMarkers
extends Control

## Screen-edge indicators for structures currently taking damage.
##
## The moment the map stops fitting on one screen, the player can be losing a
## node they cannot see. Without this, panning is punishment rather than
## pressure — you find out you lost an extractor when the income drops. These
## markers point at the trouble and say how far away it is.
##
## Drawn rather than built from nodes because the count is tiny and the
## positions change every frame with the camera.

## How long after the last hit a marker stays up.
const ALERT_SECONDS: float = 4.0
## Insets keeping markers clear of the screen edge. The top is deeper than the
## rest so markers never land on the wave/base/credits readout.
const EDGE_MARGIN: float = 52.0
const TOP_MARGIN: float = 132.0
const MARKER_RADIUS: float = 13.0

const ALERT_COLOR: Color = Color(1.0, 0.42, 0.24)
const ONSCREEN_COLOR: Color = Color(1.0, 0.55, 0.3, 0.85)

## Structure -> seconds since it was last hit.
var _since_hit: Dictionary[Node3D, float] = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameCommands.structure_damaged.connect(_on_structure_damaged)
	GameCommands.structure_destroyed.connect(_on_structure_destroyed)


func _on_structure_damaged(structure: Node3D, current_health: int, max_health: int) -> void:
	# The bus emits once per structure at mission start to seed the HUD; that is
	# not an attack, so ignore anything still at full health.
	if current_health >= max_health:
		return
	_since_hit[structure] = 0.0


func _on_structure_destroyed(structure: Node3D) -> void:
	_since_hit.erase(structure)


func _process(delta: float) -> void:
	if _since_hit.is_empty():
		return
	var expired: Array[Node3D] = []
	for structure: Node3D in _since_hit:
		_since_hit[structure] += delta
		if _since_hit[structure] > ALERT_SECONDS or not is_instance_valid(structure):
			expired.append(structure)
	for structure: Node3D in expired:
		_since_hit.erase(structure)
	queue_redraw()


func _draw() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null or _since_hit.is_empty():
		return

	var screen: Vector2 = get_viewport_rect().size
	var centre: Vector2 = screen * 0.5
	var font: Font = get_theme_default_font()

	for structure: Node3D in _since_hit:
		if not is_instance_valid(structure):
			continue
		var world: Vector3 = structure.global_position + Vector3.UP * 2.0
		var behind: bool = camera.is_position_behind(world)
		var point: Vector2 = camera.unproject_position(world)
		if behind:
			# unproject_position mirrors points behind the camera; flip them back
			# through the centre so the arrow still points the right way.
			point = centre - (point - centre)

		var on_screen: bool = not behind and Rect2(Vector2.ZERO, screen).has_point(point)
		if on_screen:
			draw_arc(point, 34.0, 0.0, TAU, 32, ONSCREEN_COLOR, 3.0, true)
			continue

		var direction: Vector2 = point - centre
		if direction.length() < 0.001:
			continue
		direction = direction.normalized()
		var edge: Vector2 = _edge_point(centre, direction, screen)

		draw_circle(edge, MARKER_RADIUS, ALERT_COLOR)
		_draw_pointer(edge, direction)

		if font != null:
			# Ground distance from what the player is looking at, not from the
			# camera — "how far do I have to pan" is the useful number.
			var focus: Vector3 = _camera_focus(camera)
			var metres: int = int(Vector2(focus.x - structure.global_position.x,
				focus.z - structure.global_position.z).length())
			var label: String = "%dm" % metres
			var size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
			# Label on the inward side so it never runs off the edge.
			var anchor: Vector2 = edge - direction * (MARKER_RADIUS + 14.0)
			draw_string(font, anchor - Vector2(size.x * 0.5, -size.y * 0.3),
				label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ALERT_COLOR)


## Where the camera's forward ray meets the ground plane.
func _camera_focus(camera: Camera3D) -> Vector3:
	var origin: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z
	if absf(forward.y) < 0.0001:
		return origin
	return origin + forward * (-origin.y / forward.y)


## A small triangle just outside the dot, aimed away from screen centre.
func _draw_pointer(origin: Vector2, direction: Vector2) -> void:
	var tip: Vector2 = origin + direction * (MARKER_RADIUS + 11.0)
	var side: Vector2 = Vector2(-direction.y, direction.x) * 7.0
	var base: Vector2 = origin + direction * (MARKER_RADIUS + 1.0)
	draw_colored_polygon(PackedVector2Array([tip, base + side, base - side]), ALERT_COLOR)


## Where a ray from the centre leaves the inset screen rectangle. The inset is
## asymmetric — deeper at the top to clear the HUD — so this solves against each
## boundary rather than assuming a centred box.
func _edge_point(centre: Vector2, direction: Vector2, screen: Vector2) -> Vector2:
	var left: float = EDGE_MARGIN
	var right: float = screen.x - EDGE_MARGIN
	var top: float = TOP_MARGIN
	var bottom: float = screen.y - EDGE_MARGIN

	var span_x: float = INF
	if direction.x > 0.0001:
		span_x = (right - centre.x) / direction.x
	elif direction.x < -0.0001:
		span_x = (left - centre.x) / direction.x

	var span_y: float = INF
	if direction.y > 0.0001:
		span_y = (bottom - centre.y) / direction.y
	elif direction.y < -0.0001:
		span_y = (top - centre.y) / direction.y

	return centre + direction * maxf(0.0, minf(span_x, span_y))
