class_name NavPathService
extends Node3D

## Computes the invasion lane once, for the whole map.
##
## CLAUDE.md rule 2: pathfinding is one-to-one, not many-to-many. There is one
## path from the spawn point to the base and every enemy reads it. This is the
## NavigationRegion3D-backed version; when unit counts make even shared-polyline
## following too coarse, this node is the single place that swaps for a flow
## field, and enemy_unit.gd does not change.

@export var navigation_region: NavigationRegion3D
@export var spawn_point: Node3D
@export var base_target: Node3D

## How far short of the base the lane stops, so the final waypoint sits at the
## structure's edge rather than inside it.
@export var base_standoff: float = 3.0

## How many physics frames to give the navigation server to publish the freshly
## baked region before falling back.
const MAX_SYNC_FRAMES: int = 30


func _ready() -> void:
	GameCommands.mission_started.connect(_on_mission_started)


func _on_mission_started() -> void:
	if navigation_region == null or spawn_point == null or base_target == null:
		push_warning("NavPathService is not wired; falling back to a straight lane.")
		_publish(_straight_lane())
		return
	navigation_region.bake_finished.connect(_on_bake_finished, CONNECT_ONE_SHOT)
	navigation_region.bake_navigation_mesh()


func _on_bake_finished() -> void:
	_publish(await _solve_lane())


## The bake lands on the region, but the map only picks the region up on a
## navigation server sync, and the sync is not guaranteed to have happened by
## any particular frame. So: force a sync, ask, and give it a few frames to come
## good before deciding the navmesh is unusable.
func _solve_lane() -> PackedVector3Array:
	var map: RID = get_world_3d().navigation_map
	var from: Vector3 = spawn_point.global_position
	var to: Vector3 = _standoff_point()
	for _attempt: int in range(MAX_SYNC_FRAMES):
		await get_tree().physics_frame
		NavigationServer3D.map_force_update(map)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, to, true)
		if path.size() >= 2:
			return path
	push_warning("Navigation returned no usable lane; falling back to a straight line.")
	return _straight_lane()


## Used when the navmesh is missing or unbakeable. On a flat grey-box plane this
## is the same answer the navmesh gives, so a failed bake degrades to a playable
## mission rather than to enemies standing still.
func _straight_lane() -> PackedVector3Array:
	return PackedVector3Array([spawn_point.global_position, _standoff_point()])


func _standoff_point() -> Vector3:
	var base_position: Vector3 = base_target.global_position
	var approach: Vector3 = spawn_point.global_position - base_position
	approach.y = 0.0
	if approach.length() < 0.01:
		return base_position
	return base_position + approach.normalized() * base_standoff


func _publish(path: PackedVector3Array) -> void:
	GameCommands.submit(GameCommandBus.Command.SET_ENEMY_PATH, {"path": path})
