class_name MissionHUD
extends CanvasLayer

## Wave number, base health, credits. Nothing else.
##
## Every value here is pushed by a command-bus signal — the HUD never polls the
## game state it displays. Placement cost is shown as persistent text rather
## than as a hover tooltip, because hover does not exist on the mobile target.

@onready var wave_label: Label = %WaveLabel
@onready var base_label: Label = %BaseLabel
@onready var credits_label: Label = %CreditsLabel
@onready var placement_label: Label = %PlacementLabel
@onready var run_over_label: Label = %RunOverLabel

const AFFORDABLE_COLOR: Color = Color(0.15, 1.0, 0.9)
const UNAFFORDABLE_COLOR: Color = Color(0.75, 0.75, 0.8)


func _ready() -> void:
	run_over_label.visible = false
	GameCommands.mission_started.connect(_on_mission_started)
	GameCommands.credits_changed.connect(_on_credits_changed)
	GameCommands.base_health_changed.connect(_on_base_health_changed)
	GameCommands.wave_started.connect(_on_wave_started)
	GameCommands.run_ended.connect(_on_run_ended)


func _on_mission_started() -> void:
	wave_label.text = "WAVE  —"


func _on_wave_started(wave_number: int, enemy_count: int) -> void:
	wave_label.text = "WAVE  %d   (%d)" % [wave_number, enemy_count]


func _on_base_health_changed(current_health: int, max_health: int) -> void:
	base_label.text = "BASE  %d / %d" % [current_health, max_health]


func _on_credits_changed(credits: int) -> void:
	credits_label.text = "CREDITS  %d" % credits
	var cost: int = GameCommands.get_turret_cost()
	placement_label.text = "Click the ground to place a turret  ·  %d credits" % cost
	placement_label.add_theme_color_override(
		"font_color",
		AFFORDABLE_COLOR if credits >= cost else UNAFFORDABLE_COLOR
	)


func _on_run_ended(final_wave: int) -> void:
	run_over_label.text = "BASE LOST\nSURVIVED %d WAVES" % final_wave
	run_over_label.visible = true
	placement_label.text = ""
