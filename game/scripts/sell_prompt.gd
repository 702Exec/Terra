class_name SellPrompt
extends PanelContainer

## Confirmation for refunding a placed turret.
##
## A confirm step rather than a one-tap sell, because a stray tap on your own
## turret line during a wave should not delete it. Both buttons clear the 48dp
## touch minimum, and the refund amount is on the button rather than in a
## tooltip.

@onready var title: Label = %SellTitle
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

var _turret: Node3D = null


func _ready() -> void:
	add_to_group("sell_prompt")
	visible = false
	confirm_button.pressed.connect(_on_confirm)
	cancel_button.pressed.connect(close)
	GameCommands.run_ended.connect(_on_run_ended)


func open_for(turret: Node3D) -> void:
	if turret == null or not is_instance_valid(turret):
		return
	_turret = turret
	title.text = "PULSE TURRET"
	confirm_button.text = "SELL  (+%d cr)" % GameCommands.get_turret_refund()
	visible = true


func close() -> void:
	_turret = null
	visible = false


func _on_confirm() -> void:
	if _turret != null:
		GameCommands.submit(GameCommandBus.Command.SELL_TURRET, {"turret": _turret})
	close()


func _on_run_ended(_final_wave: int) -> void:
	close()
