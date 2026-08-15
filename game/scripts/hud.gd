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
@onready var warning_label: Label = %WarningLabel
@onready var run_over_label: Label = %RunOverLabel

const AFFORDABLE_COLOR: Color = Color(0.15, 1.0, 0.9)
const UNAFFORDABLE_COLOR: Color = Color(0.75, 0.75, 0.8)
const WARNING_HOLD_SECONDS: float = 3.5

var _warning_tween: Tween = null


func _ready() -> void:
	run_over_label.visible = false
	warning_label.visible = false
	GameCommands.mission_started.connect(_on_mission_started)
	GameCommands.wave_incoming.connect(_on_wave_incoming)
	GameCommands.income_changed.connect(_on_income_changed)
	GameCommands.structure_destroyed.connect(_on_structure_destroyed)
	GameCommands.wave_countdown_changed.connect(_on_wave_countdown_changed)
	GameCommands.credits_changed.connect(_on_credits_changed)
	GameCommands.base_health_changed.connect(_on_base_health_changed)
	GameCommands.wave_started.connect(_on_wave_started)
	GameCommands.run_ended.connect(_on_run_ended)


func _on_mission_started() -> void:
	wave_label.text = "WAVE  —"


func _on_wave_started(wave_number: int, enemy_count: int) -> void:
	wave_label.text = "WAVE  %d   (%d)" % [wave_number, enemy_count]


## Between waves the wave readout becomes the preparation clock. Knowing how
## much time is left is what makes the gap usable rather than merely quiet.
func _on_wave_countdown_changed(seconds_left: int, wave_number: int) -> void:
	if seconds_left < 0:
		return
	wave_label.text = "WAVE  %d  IN  %d:%02d" % [wave_number, seconds_left / 60, seconds_left % 60]


func _on_base_health_changed(current_health: int, max_health: int) -> void:
	base_label.text = "BASE  %d / %d" % [current_health, max_health]


func _on_credits_changed(credits: int) -> void:
	credits_label.text = "CREDITS  %d   (+%.0f/s)" % [credits, GameCommands.get_income_per_second()]
	var cost: int = GameCommands.get_turret_cost()
	placement_label.text = "Click the ground to place a turret  ·  %d credits" % cost
	placement_label.add_theme_color_override(
		"font_color",
		AFFORDABLE_COLOR if credits >= cost else UNAFFORDABLE_COLOR
	)


func _on_income_changed(_credits_per_second: float) -> void:
	_on_credits_changed(GameCommands.get_credits())


## Losing a forward node is the loudest thing that can happen short of the base
## falling, so it borrows the same banner.
func _on_structure_destroyed(_structure: Node3D) -> void:
	warning_label.text = "EXTRACTOR LOST  —  INCOME %.0f/s" % GameCommands.get_income_per_second()
	warning_label.visible = true
	_hold_then_fade()


## The base calling out where the next wave is coming from. Text rather than a
## hover cue, and it names the direction so the player knows which side to look
## at without hunting for the spawn ring.
func _on_wave_incoming(wave_number: int, lane_names: PackedStringArray) -> void:
	var where: String = " · ".join(lane_names) if not lane_names.is_empty() else "ALL SIDES"
	warning_label.text = "⚠  WAVE %d INCOMING — %s" % [wave_number, where]
	warning_label.visible = true
	_hold_then_fade()


func _hold_then_fade() -> void:
	if _warning_tween != null and _warning_tween.is_valid():
		_warning_tween.kill()
	warning_label.modulate.a = 1.0
	_warning_tween = create_tween()
	_warning_tween.tween_interval(WARNING_HOLD_SECONDS)
	_warning_tween.tween_property(warning_label, "modulate:a", 0.0, 0.6)
	_warning_tween.tween_callback(func() -> void: warning_label.visible = false)


func _on_run_ended(final_wave: int) -> void:
	run_over_label.text = "BASE LOST\nSURVIVED %d WAVES" % final_wave
	run_over_label.visible = true
	warning_label.visible = false
	placement_label.text = ""
