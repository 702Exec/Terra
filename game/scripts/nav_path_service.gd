class_name NavPathService
extends Node3D

## Computes the invasion lanes once, for the whole map.
##
## CLAUDE.md rule 2: pathfinding is one-to-one, not many-to-many. There is one
## path per approach lane and every enemy on that lane reads it — the solve
## count scales with lanes, not with units. This is the NavigationRegion3D
## version; when unit counts make shared-polyline following too coarse, this is
## the single file that swaps for a flow field, and enemy_unit.gd does not
## change.
##
## The map supplies the lane spawns as children of `lane_root`; MissionConfig
## decides how many of them are live, which is what makes lane count a
## difficulty dial rather than a map edit.

@export var navigation_region: NavigationRegion3D
@export var lane_root: Node3D
@export var base_target: Node3D

## How far short of the base a lane stops, so the final waypoint sits at the
## structure's edge rather than inside it.
@export var base_standoff: float = 3.0

## How many physics frames to give the navigation server to publish the freshly
## baked region before falling back.
const MAX_SYNC_FRAMES: int = 30


func _ready() -> void:
	GameCommands.mission_started.connect(_on_mission_started)


func _on_mission_started() -> void:
	if navigation_region == null or lane_root == null or base_target == null:
		push_warning("NavPathService is not wired; falling back to straight lanes.")
		_publish(_straight_lanes())
		return
	navigation_region.bake_finished.connect(_on_bake_finished, CONNECT_ONE_SHOT)
	navigation_region.bake_navigation_mesh()


func _on_bake_finished() -> void:
	var map: RID = get_world_3d().navigation_map
	var paths: Array[PackedVector3Array] = []
	for lane: Node3D in _active_lanes():
		paths.append(await _solve_lane(map, lane))
	_publish(paths)


## The bake lands on the region, but the map only picks the region up on a
## navigation server sync, and the sync is not guaranteed to have happened by
## any particular frame. So: force a sync, ask, and give it a few frames to come
## good before deciding the navmesh is unusable. Once the first lane resolves
## the rest succeed on their first attempt.
func _solve_lane(map: RID, lane: Node3D) -> PackedVector3Array:
	var from: Vector3 = lane.global_position
	var to: Vector3 = _standoff_point(from)
	for _attempt: int in range(MAX_SYNC_FRAMES):
		await get_tree().physics_frame
		NavigationServer3D.map_force_update(map)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, to, true)
		if path.size() >= 2:
			return path
	push_warning("No usable lane from %s; falling back to a straight line." % lane.name)
	return PackedVector3Array([from, to])


## The map's lane spawns, trimmed to the count this mission runs. Anything the
## config asks for beyond what the map provides is ignored rather than faked.
func _active_lanes() -> Array[Node3D]:
	var lanes: Array[Node3D] = []
	if lane_root == null:
		return lanes
	for child: Node in lane_root.get_children():
		var lane := child as Node3D
		if lane != null:
			lanes.append(lane)

	var config: MissionConfig = GameCommands.get_mission_config()
	var wanted: int = lanes.size() if config == null else config.active_lane_count
	wanted = clampi(wanted, 1, lanes.size())
	return lanes.slice(0, wanted)


## Used when the navmesh is missing or unbakeable. On a flat grey-box plane this
## is the same answer the navmesh gives, so a failed bake degrades to a playable
## mission rather than to enemies standing still.
func _straight_lanes() -> Array[PackedVector3Array]:
	var paths: Array[PackedVector3Array] = []
	for lane: Node3D in _active_lanes():
		var from: Vector3 = lane.global_position
		paths.append(PackedVector3Array([from, _standoff_point(from)]))
	return paths


func _standoff_point(from: Vector3) -> Vector3:
	var base_position: Vector3 = base_target.global_position
	var approach: Vector3 = from - base_position
	approach.y = 0.0
	if approach.length() < 0.01:
		return base_position
	return base_position + approach.normalized() * base_standoff


func _publish(paths: Array[PackedVector3Array]) -> void:
	GameCommands.submit(GameCommandBus.Command.SET_ENEMY_PATHS, {"paths": paths})
