class_name BaseStructure
extends Node3D

## The harvest base. Hitpoints live in GameCommandBus like every other piece of
## mission state; this node only reacts to them, tinting toward red as the base
## takes damage so the player reads the situation off the battlefield rather
## than off the HUD.

@onready var visual: MeshInstance3D = $Visual

const HEALTHY_COLOR: Color = Color(0.13, 0.72, 0.85)
const CRITICAL_COLOR: Color = Color(0.9, 0.18, 0.16)

var _material: StandardMaterial3D = null


func _ready() -> void:
	# Duplicated so the tint is per-instance and does not write through to the
	# shared sub-resource.
	_material = (visual.material_override as StandardMaterial3D).duplicate()
	visual.material_override = _material
	GameCommands.base_health_changed.connect(_on_base_health_changed)
	GameCommands.run_ended.connect(_on_run_ended)


func _on_base_health_changed(current_health: int, max_health: int) -> void:
	if max_health <= 0:
		return
	var fraction: float = float(current_health) / float(max_health)
	_material.albedo_color = CRITICAL_COLOR.lerp(HEALTHY_COLOR, fraction)


func _on_run_ended(_final_wave: int) -> void:
	_material.albedo_color = CRITICAL_COLOR.darkened(0.5)
