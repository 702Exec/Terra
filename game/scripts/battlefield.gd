class_name Battlefield
extends NavigationRegion3D

## Builds the ground plane, its collider, and the lane spawn ring to whatever
## size MissionConfig asks for, then bakes navigation over the result.
##
## Map size used to be three numbers that had to agree: a mesh, a collision
## shape, and the camera's pan limit. Now it is one — `MissionConfig.
## map_half_extent` — and everything derives from it. Changing the battlefield
## from 64 to 144 is editing a resource, not moving nodes.

@export var ground_mesh: MeshInstance3D
@export var ground_collision: CollisionShape3D
@export var lane_root: Node3D
@export var structure_root: Node3D

@export_group("Layout")
## Lane spawns sit this far in from the map edge.
@export var lane_inset: float = 6.0
## Forward extractors sit this fraction of the way from the base to the spawns.
## Below about 0.5 the enemy is on top of the extractor before the player can
## pan across to look at it.
@export_range(0.2, 0.9) var extractor_lane_fraction: float = 0.6


func _ready() -> void:
	GameCommands.mission_started.connect(_on_mission_started)


func _on_mission_started() -> void:
	var half: float = GameCommands.get_map_half_extent()
	if half <= 0.0:
		push_warning("Battlefield has no map size; leaving the scene as authored.")
		return
	_resize_ground(half)
	_place_lanes(half)
	_place_extractors(half)


func _resize_ground(half: float) -> void:
	var span: float = half * 2.0
	if ground_mesh != null:
		var box := ground_mesh.mesh as BoxMesh
		if box != null:
			# Duplicated so a resize never writes through to the shared mesh
			# resource and leak into another scene.
			box = box.duplicate() as BoxMesh
			box.size = Vector3(span, box.size.y, span)
			ground_mesh.mesh = box
	if ground_collision != null:
		var shape := ground_collision.shape as BoxShape3D
		if shape != null:
			shape = shape.duplicate() as BoxShape3D
			shape.size = Vector3(span, shape.size.y, span)
			ground_collision.shape = shape


## Lanes keep their compass bearing and move out to the new edge. Child order is
## preserved because WaveConfig's lane bitmasks index into it.
func _place_lanes(half: float) -> void:
	if lane_root == null:
		return
	var radius: float = maxf(1.0, half - lane_inset)
	var bearings: Array[Vector3] = [
		Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0)
	]
	var index: int = 0
	for child: Node in lane_root.get_children():
		var lane := child as Node3D
		if lane == null:
			continue
		if index < bearings.size():
			lane.position = bearings[index] * radius
		index += 1


## Extractors sit out along a lane, far enough from the spawn that a warning
## gives the player time to pan over and watch the wave arrive.
func _place_extractors(half: float) -> void:
	if structure_root == null or lane_root == null:
		return
	var lanes: Array[Node3D] = []
	for child: Node in lane_root.get_children():
		var lane := child as Node3D
		if lane != null:
			lanes.append(lane)
	if lanes.is_empty():
		return

	var index: int = 0
	for child: Node in structure_root.get_children():
		var structure := child as Node3D
		if structure == null:
			continue
		# Extractor N sits on lane N; the scene decides which lanes are used by
		# how many extractors it contains.
		var lane: Node3D = lanes[index % lanes.size()]
		var direction: Vector3 = lane.position.normalized()
		structure.position = direction * (lane.position.length() * extractor_lane_fraction)
		index += 1
