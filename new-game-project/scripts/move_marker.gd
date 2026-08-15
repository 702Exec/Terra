class_name MoveMarker
extends Node3D

## A short-lived flat marker that shows where a move order landed. It fades out
## and hides itself after a moment so each order has clear, non-persistent
## feedback on the battlefield.

@export var lifetime: float = 1.4

@onready var mesh: MeshInstance3D = $Mesh

var _tween: Tween


func _ready() -> void:
	visible = false


func show_at(world_position: Vector3) -> void:
	global_position = world_position + Vector3.UP * 0.06
	visible = true
	var material := mesh.material_override as StandardMaterial3D
	if material == null:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	material.albedo_color.a = 0.9
	_tween = create_tween()
	_tween.tween_property(material, "albedo_color:a", 0.0, lifetime)
	_tween.tween_callback(_hide)


func _hide() -> void:
	visible = false
