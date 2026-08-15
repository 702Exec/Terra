class_name MissionConfig
extends Resource

## Everything the mission needs that is a tunable number rather than a scene
## reference. Scene wiring stays in main.tscn; numbers live here.

@export_group("Base")
@export var base_max_health: int = 1000

@export_group("Economy")
@export var starting_credits: int = 100
@export var credits_per_second: float = 10.0

@export_group("Loadout")
@export var turret_stats: TurretStats
@export var wave_config: WaveConfig

@export_group("Placement rules")
## Half-extent of the placeable battlefield on X and Z.
@export var battlefield_extent: float = 18.0
@export var turret_min_spacing: float = 2.0
@export var turret_min_base_distance: float = 4.5
@export var turret_min_spawn_distance: float = 5.0
