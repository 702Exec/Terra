class_name AbilityBar
extends Control

## The orbital strike button, and the arming state that goes with it.
##
## Arming is UI state rather than game state, so it lives here rather than in the
## bus: the placement controller asks whether the strike is armed before it
## treats a ground tap as a turret placement.
##
## Two taps to fire — arm, then choose a target — which is what stops a stray tap
## spending 300 credits, and gives the player a moment to see the radius preview
## before committing.

@onready var strike_button: Button = %StrikeButton

var _armed: bool = false


func _ready() -> void:
	add_to_group("ability_bar")
	strike_button.pressed.connect(toggle_arm)
	GameCommands.mission_started.connect(_refresh)
	GameCommands.credits_changed.connect(_on_credits_changed)
	GameCommands.orbital_cooldown_changed.connect(_on_cooldown_changed)
	GameCommands.run_ended.connect(_on_run_ended)
	_refresh()


func is_strike_armed() -> bool:
	return _armed


func toggle_arm() -> void:
	if _armed:
		disarm()
		return
	if not GameCommands.can_call_orbital_strike():
		return
	_armed = true
	_refresh()


func disarm() -> void:
	if not _armed:
		return
	_armed = false
	_refresh()


## Radius of the pending strike, so the controller can preview it under the
## pointer at the size it will actually land.
func get_strike_radius() -> float:
	var stats: OrbitalStrikeStats = GameCommands.get_orbital_strike_stats()
	return 1.0 if stats == null else stats.radius


func _on_credits_changed(_credits: int) -> void:
	# Losing affordability mid-aim should cancel rather than fail on release.
	if _armed and not GameCommands.can_call_orbital_strike() and GameCommands.get_orbital_cooldown() <= 0.0:
		_armed = false
	_refresh()


func _on_cooldown_changed(_seconds_left: float) -> void:
	_refresh()


func _on_run_ended(_final_wave: int) -> void:
	_armed = false
	_refresh()


func _refresh() -> void:
	var stats: OrbitalStrikeStats = GameCommands.get_orbital_strike_stats()
	if stats == null:
		visible = false
		return
	visible = true

	var cooldown: float = GameCommands.get_orbital_cooldown()
	if _armed:
		strike_button.text = "CHOOSE TARGET  ·  TAP TO CANCEL"
		strike_button.disabled = false
		return
	if cooldown > 0.0:
		strike_button.text = "%s  ·  %ds" % [stats.display_name.to_upper(), int(ceilf(cooldown))]
		strike_button.disabled = true
		return
	strike_button.text = "%s  ·  %d cr" % [stats.display_name.to_upper(), stats.cost]
	strike_button.disabled = GameCommands.get_credits() < stats.cost
