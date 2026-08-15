class_name EconomyTicker
extends Node

## Trickles credits in at a fixed rate so placement is a real choice — waiting
## for a second turret always costs you something.
##
## A timer rather than a _process accumulator: the rate is coarse enough that
## ten ticks a second is indistinguishable from sixty, and it keeps the economy
## off the frame loop.

@onready var tick_timer: Timer = $TickTimer

var _fractional_credits: float = 0.0
var _credits_per_second: float = 0.0


func _ready() -> void:
	GameCommands.mission_started.connect(_on_mission_started)
	GameCommands.run_ended.connect(_on_run_ended)
	tick_timer.timeout.connect(_on_tick)


func _on_mission_started() -> void:
	var config: MissionConfig = GameCommands.get_mission_config()
	if config == null:
		return
	_credits_per_second = config.credits_per_second
	_fractional_credits = 0.0
	tick_timer.start()


func _on_tick() -> void:
	# Accumulated as a float and paid out in whole credits, so a non-integer
	# rate still averages out correctly instead of rounding away every tick.
	_fractional_credits += _credits_per_second * tick_timer.wait_time
	var payout: int = int(floorf(_fractional_credits))
	if payout <= 0:
		return
	_fractional_credits -= float(payout)
	GameCommands.submit(GameCommandBus.Command.ADD_CREDITS, {"amount": payout})


func _on_run_ended(_final_wave: int) -> void:
	tick_timer.stop()
