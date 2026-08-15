class_name AbilityTicker
extends Node

## Advances ability cooldowns on a fixed tick.
##
## Lives outside the bus so the bus stays a pure command sink with no clock of
## its own — same arrangement as EconomyTicker and the wave countdown.

@onready var tick_timer: Timer = $TickTimer


func _ready() -> void:
	GameCommands.mission_started.connect(_on_mission_started)
	GameCommands.run_ended.connect(_on_run_ended)
	tick_timer.timeout.connect(_on_tick)


func _on_mission_started() -> void:
	tick_timer.start()


func _on_tick() -> void:
	GameCommands.submit(GameCommandBus.Command.TICK_ABILITIES, {"delta": tick_timer.wait_time})


func _on_run_ended(_final_wave: int) -> void:
	tick_timer.stop()
