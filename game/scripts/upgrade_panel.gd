class_name UpgradePanel
extends PanelContainer

## The Sovereign Spire's upgrade panel. Opened by clicking the base.
##
## Rows are built from MissionConfig's upgrade tracks rather than hardcoded, so
## adding a track is a resource edit. Every purchase goes through the bus like
## any other state change.
##
## Sized for touch: buy buttons are 56px tall against a 48dp minimum, and the
## panel does not depend on hover for anything — cost, level, and affordability
## are all visible at rest.
##
## The mission does not pause while this is open. Spending during a wave is
## meant to be a risk, not a safe menu.

const BUTTON_MIN: Vector2 = Vector2(150.0, 56.0)
const AFFORDABLE: Color = Color(0.15, 1.0, 0.9)
const UNAFFORDABLE: Color = Color(0.72, 0.72, 0.78)
const MAXED: Color = Color(0.55, 0.85, 0.6)

@onready var rows: VBoxContainer = %Rows
@onready var close_button: Button = %CloseButton

## Track id -> the button that buys it, so refreshes do not rebuild the panel.
var _buttons: Dictionary[StringName, Button] = {}
var _levels: Dictionary[StringName, Label] = {}


func _ready() -> void:
	add_to_group("upgrade_panel")
	visible = false
	close_button.pressed.connect(close)
	GameCommands.mission_started.connect(_build_rows)
	GameCommands.credits_changed.connect(_on_credits_changed)
	GameCommands.upgrade_purchased.connect(_on_upgrade_purchased)
	GameCommands.run_ended.connect(_on_run_ended)


func open() -> void:
	if not GameCommands.is_run_active():
		return
	if _buttons.is_empty():
		_build_rows()
	visible = true
	_refresh()


func close() -> void:
	visible = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _build_rows() -> void:
	for child: Node in rows.get_children():
		child.queue_free()
	_buttons.clear()
	_levels.clear()

	for track: UpgradeTrack in GameCommands.get_upgrade_tracks():
		if track == null:
			continue
		rows.add_child(_build_row(track))
	_refresh()


func _build_row(track: UpgradeTrack) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 2)

	var title := Label.new()
	title.text = track.display_name
	title.add_theme_font_size_override("font_size", 20)
	text.add_child(title)

	var detail := Label.new()
	detail.text = track.description
	detail.add_theme_font_size_override("font_size", 14)
	detail.add_theme_color_override("font_color", UNAFFORDABLE)
	text.add_child(detail)

	var level := Label.new()
	level.add_theme_font_size_override("font_size", 14)
	_levels[track.id] = level
	text.add_child(level)

	row.add_child(text)

	var buy := Button.new()
	buy.custom_minimum_size = BUTTON_MIN
	buy.pressed.connect(_on_buy_pressed.bind(track.id))
	_buttons[track.id] = buy
	row.add_child(buy)

	return row


func _on_buy_pressed(track_id: StringName) -> void:
	GameCommands.submit(GameCommandBus.Command.PURCHASE_UPGRADE, {"track_id": track_id})


func _on_credits_changed(_credits: int) -> void:
	if visible:
		_refresh()


func _on_upgrade_purchased(_track_id: StringName, _level: int) -> void:
	_refresh()


func _on_run_ended(_final_wave: int) -> void:
	close()


func _refresh() -> void:
	var credits: int = GameCommands.get_credits()
	for track: UpgradeTrack in GameCommands.get_upgrade_tracks():
		if track == null or not _buttons.has(track.id):
			continue
		var level: int = GameCommands.get_upgrade_level(track.id)
		var button: Button = _buttons[track.id]
		var label: Label = _levels[track.id]

		label.text = "Level %d / %d" % [level, track.max_level]

		if level >= track.max_level:
			button.text = "MAX"
			button.disabled = true
			label.add_theme_color_override("font_color", MAXED)
			continue

		var cost: int = track.cost_for_level(level + 1)
		var affordable: bool = credits >= cost
		button.text = "%d cr" % cost
		button.disabled = not affordable
		label.add_theme_color_override("font_color", AFFORDABLE if affordable else UNAFFORDABLE)
