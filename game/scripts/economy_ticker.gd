class_name EconomyTicker
extends Node

## Pays out the mission's income on a fixed tick.
##
## The rate is not a constant — it is the base trickle plus whatever extractors
## are still standing, read from the bus each tick. That is what makes losing a
## forward node hurt twice: once on the map, and again for the rest of the
## mission in everything you cannot afford to rebuild.
##
## A timer rather than a _process accumulator: ten ticks a second is
## indistinguishable from sixty at this granularity and keeps the economy off
## the frame loop.

@onready var tick_timer: Timer = $TickTimer

var _fractional_credits: float = 0.0


func _ready() -> void:
	GameCommands.landing_phase_changed.connect(_on_landing_phase_changed)
	GameCommands.run_ended.connect(_on_run_ended)
	tick_timer.timeout.connect(_on_tick)


## Extraction starts when the engine is on the ground and awake — not when the
## scene loads.
func _on_landing_phase_changed(_phase: GameCommandBus.LandingPhase) -> void:
	if not GameCommands.is_landed():
		return
	_fractional_credits = 0.0
	tick_timer.start()


func _on_tick() -> void:
	# Accumulated as a float and paid out in whole credits, so a fractional rate
	# still averages out correctly instead of rounding away every tick.
	_fractional_credits += GameCommands.get_income_per_second() * tick_timer.wait_time
	var payout: int = int(floorf(_fractional_credits))
	if payout <= 0:
		return
	_fractional_credits -= float(payout)
	GameCommands.submit(GameCommandBus.Command.ADD_CREDITS, {"amount": payout})


func _on_run_ended(_final_wave: int) -> void:
	tick_timer.stop()
