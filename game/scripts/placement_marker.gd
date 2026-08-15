class_name PlacementMarker
extends Node3D

## Turret placement indicator.
##
## Lineage: this is the old move_marker.gd — same flat marker, same fade-out
## tween — retargeted from "a move order landed here" to "a turret goes here."
##
## It has two jobs because the game has two input models. On desktop it tracks
## the pointer as a persistent ghost. On touch there is no hover, so it flashes
## at the tap point instead. Nothing that is only visible on hover is allowed to
## carry information the player needs (CLAUDE.md, mobile UI constraints) — the
## ghost is confirmation, the HUD carries the cost.

@export var flash_lifetime: float = 0.5

@onready var mesh: MeshInstance3D = $Mesh

const VALID_COLOR: Color = Color(0.15, 1.0, 0.9, 0.65)
const INVALID_COLOR: Color = Color(1.0, 0.25, 0.2, 0.65)
const HOVER_HEIGHT: float = 0.06

var _material: StandardMaterial3D = null
var _tween: Tween = null


func _ready() -> void:
	_material = (mesh.material_override as StandardMaterial3D).duplicate()
	mesh.material_override = _material
	visible = false


## Persistent ghost under the pointer. Desktop affordance only.
func show_ghost(world_position: Vector3, is_valid: bool) -> void:
	_kill_tween()
	global_position = world_position + Vector3.UP * HOVER_HEIGHT
	_material.albedo_color = VALID_COLOR if is_valid else INVALID_COLOR
	visible = true


func hide_ghost() -> void:
	_kill_tween()
	visible = false


## One-shot confirmation pulse at a committed (or rejected) placement point.
func flash(world_position: Vector3, is_valid: bool) -> void:
	_kill_tween()
	global_position = world_position + Vector3.UP * HOVER_HEIGHT
	var color: Color = VALID_COLOR if is_valid else INVALID_COLOR
	color.a = 0.95
	_material.albedo_color = color
	visible = true

	_tween = create_tween()
	_tween.tween_property(_material, "albedo_color:a", 0.0, flash_lifetime)
	_tween.tween_callback(_on_flash_finished)


func _on_flash_finished() -> void:
	visible = false


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
