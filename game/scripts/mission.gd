class_name Mission
extends Node3D

## Mission root. Its only job is to hand the command bus the scene wiring and
## the tuning resource, then get out of the way.
##
## The split is deliberate: numbers live in the .tres (MissionConfig), scene and
## prefab references live here in the .tscn. Nothing in this file is a game
## rule.
##
## Godot readies children before their parent, so every listener — HUD, wave
## director, economy, path service — is already subscribed by the time
## BEGIN_MISSION fires.

@export var config: MissionConfig

@export_group("Scene wiring")
@export var base_structure: Node3D
@export var enemy_root: Node3D
@export var turret_root: Node3D
## Destructible player structures placed on the map — extractors. Their children
## are registered with the bus in scene order.
@export var structure_root: Node3D
## Where transient effects such as orbital strikes are parented.
@export var effect_root: Node3D

@export_group("Prefabs")
@export var enemy_scene: PackedScene
@export var turret_scene: PackedScene
@export var strike_scene: PackedScene


func _ready() -> void:
	GameCommands.submit(GameCommandBus.Command.BEGIN_MISSION, {
		"config": config,
		"base": base_structure,
		"enemy_root": enemy_root,
		"turret_root": turret_root,
		"structure_root": structure_root,
		"effect_root": effect_root,
		"enemy_scene": enemy_scene,
		"strike_scene": strike_scene,
		"turret_scene": turret_scene,
	})
