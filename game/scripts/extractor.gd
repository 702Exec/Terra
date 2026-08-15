class_name Extractor
extends Node3D

## A forward resource extractor. It is the mission's income, and it can be
## destroyed — which is the whole point. Placed out in an approach lane, it
## forces the player to defend ground they cannot see from the base.
##
## Health lives in GameCommandBus like every other hitpoint in the mission; this
## node only reacts. Its stats come from MissionConfig, injected by the bus.

@onready var visual: MeshInstance3D = $Visual
@onready var status_ring: MeshInstance3D = $StatusRing

const HEALTHY_COLOR: Color = Color(1.0, 0.78, 0.25)
const CRITICAL_COLOR: Color = Color(0.9, 0.18, 0.16)

var _material: StandardMaterial3D = null


func _ready() -> void:
	add_to_group("attackable_structure")
	_material = (visual.material_override as StandardMaterial3D).duplicate()
	visual.material_override = _material
	GameCommands.structure_damaged.connect(_on_structure_damaged)
	GameCommands.structure_destroyed.connect(_on_structure_destroyed)


func _on_structure_damaged(structure: Node3D, current_health: int, max_health: int) -> void:
	if structure != self or max_health <= 0:
		return
	var fraction: float = float(current_health) / float(max_health)
	_material.albedo_color = CRITICAL_COLOR.lerp(HEALTHY_COLOR, fraction)


func _on_structure_destroyed(structure: Node3D) -> void:
	if structure != self:
		return
	# The wreck stays on the map as a readable "you lost this" marker rather
	# than vanishing, but it stops counting as a target or as income.
	remove_from_group("attackable_structure")
	_material.albedo_color = Color(0.24, 0.24, 0.26)
	status_ring.visible = false
