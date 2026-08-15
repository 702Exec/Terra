class_name LandingSequence
extends Node3D

## The Spire's arrival, grey-boxed.
##
## This exists to test the *timing* of the beats described in
## `docs/terra-sovereign-spire.md` — breach, impact, silence, wake — which is the
## part that either works or does not, and the part that art cannot fix later.
## Everything here is primitives and tweens on purpose.
##
## The beat that matters most is the silence. The gap between the dust settling
## and the engine coming online is doing more work than the impact itself, and
## it is the easiest thing to cut too short. Tune `silence_time` first.
##
## The mission is gated on this: waves and extraction both wait for DONE, so a
## sequence that never completes is a soft-lock rather than a cosmetic problem.
## `abort()` exists for that reason.

@export var spire: Node3D
@export var camera_rig: CameraRig
## Optional. When it holds clips, they play instead of the grey box and this
## script becomes a fallback. The mission gate does not care which ran.
@export var cinematic: CinematicPlayer

@export_group("Beats")
## How high the Spire starts. Kept low enough that most of the fall is on
## screen: at this tilt an object at height h sits h * cos(55°) above its ground
## position, so a great height means it is out of frame until the last instant.
@export var descent_height: float = 96.0
@export var descent_time: float = 7.0
## Dust and debris settling. Nothing else happens.
@export var settle_time: float = 3.0
## Held silence before the engine wakes. The most important number here.
@export var silence_time: float = 4.5
@export var wake_time: float = 5.5

@export_group("Framing")
## Wide for the fall, so the descent is visible rather than a blur arriving.
@export var descent_zoom: float = 62.0
## Tight on the slam, then out to the default as the engine wakes and the
## battlefield is revealed.
@export var impact_zoom: float = 26.0

@export_group("Impact")
@export var shake_strength: float = 2.4
@export var shake_duration: float = 1.3
## The shockwave stops here. Sized against the map rather than the Spire so it
## reads as planetary rather than local.
@export var shockwave_radius: float = 46.0

@onready var shockwave: MeshInstance3D = $Shockwave
@onready var dust: MeshInstance3D = $Dust
@onready var entry_glow: MeshInstance3D = $EntryGlow

## How far beneath the Spire the entry glow trails.
const GLOW_TRAIL: float = 7.0

var _running: bool = false
var _resting_height: float = 0.0


func _ready() -> void:
	set_process_unhandled_input(false)
	shockwave.visible = false
	dust.visible = false
	entry_glow.visible = false
	GameCommands.mission_started.connect(_on_mission_started)


func _on_mission_started() -> void:
	if spire == null or GameCommands.is_landed():
		return
	_resting_height = spire.position.y

	# Footage wins when it exists. The grey box is the stand-in, not the
	# fallback of last resort — both end at the same gate.
	if cinematic != null and cinematic.has_clips():
		_running = true
		cinematic.finished.connect(_on_cinematic_finished, CONNECT_ONE_SHOT)
		cinematic.play()
		return

	_running = true
	set_process_unhandled_input(true)
	_run()


func _on_cinematic_finished() -> void:
	_running = false
	spire.position.y = _resting_height
	GameCommands.submit(GameCommandBus.Command.SET_LANDING_PHASE, {
		"phase": GameCommandBus.LandingPhase.DONE,
	})


## Twenty seconds is a long time on a mission the player may retry. Any input
## ends it.
func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	var pressed: bool = (event is InputEventKey and event.pressed) 		or (event is InputEventMouseButton and event.pressed) 		or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		get_viewport().set_input_as_handled()
		abort()


## Skips to the end. Anything that could leave the player stuck on an
## unfinished cinematic should call this rather than letting it hang.
func abort() -> void:
	if not _running:
		return
	_running = false
	set_process_unhandled_input(false)
	if camera_rig != null:
		camera_rig.set_zoom(camera_rig.default_zoom)
	if spire != null:
		spire.position.y = _resting_height
	shockwave.visible = false
	dust.visible = false
	entry_glow.visible = false
	GameCommands.submit(GameCommandBus.Command.SET_LANDING_PHASE, {
		"phase": GameCommandBus.LandingPhase.DONE,
	})


func _run() -> void:
	_begin_descent()
	await get_tree().create_timer(descent_time).timeout
	if not _running:
		return

	_impact()
	await get_tree().create_timer(settle_time).timeout
	if not _running:
		return

	# Silence. Deliberately nothing here.
	await get_tree().create_timer(silence_time).timeout
	if not _running:
		return

	_wake()
	await get_tree().create_timer(wake_time).timeout
	if not _running:
		return

	_running = false
	set_process_unhandled_input(false)
	GameCommands.submit(GameCommandBus.Command.SET_LANDING_PHASE, {
		"phase": GameCommandBus.LandingPhase.DONE,
	})


func _begin_descent() -> void:
	GameCommands.submit(GameCommandBus.Command.SET_LANDING_PHASE, {
		"phase": GameCommandBus.LandingPhase.DESCENT,
	})
	spire.position.y = _resting_height + descent_height
	# The glow is the leg tips burning off atmosphere, so it rides down with the
	# Spire rather than sitting at the point it is going to hit.
	entry_glow.visible = true
	entry_glow.scale = Vector3.ONE
	entry_glow.position = Vector3(0.0, _resting_height + descent_height - GLOW_TRAIL, 0.0)

	if camera_rig != null:
		camera_rig.focus_on(Vector3.ZERO)
		camera_rig.set_zoom(descent_zoom)

	# Eased in, so it accelerates the way something falling does rather than
	# descending at a constant, mechanical rate.
	var fall: Tween = create_tween()
	fall.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fall.tween_property(spire, "position:y", _resting_height, descent_time)
	fall.parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).tween_property(
		entry_glow, "position:y", _resting_height - GLOW_TRAIL, descent_time)
	fall.parallel().tween_property(entry_glow, "scale", Vector3(1.7, 1.4, 1.7), descent_time)


func _impact() -> void:
	GameCommands.submit(GameCommandBus.Command.SET_LANDING_PHASE, {
		"phase": GameCommandBus.LandingPhase.IMPACT,
	})
	entry_glow.visible = false

	if camera_rig != null:
		camera_rig.shake(shake_strength, shake_duration)
		camera_rig.set_zoom(impact_zoom)

	shockwave.visible = true
	shockwave.scale = Vector3(3.0, 1.0, 3.0)
	dust.visible = true
	dust.scale = Vector3(6.0, 1.0, 6.0)

	var blast: Tween = create_tween()
	blast.set_parallel(true)
	blast.tween_property(shockwave, "scale",
		Vector3(shockwave_radius, 1.0, shockwave_radius), settle_time + silence_time)
	blast.tween_property(shockwave, "transparency", 1.0, settle_time + silence_time)
	blast.tween_property(dust, "scale",
		Vector3(shockwave_radius * 0.65, 1.0, shockwave_radius * 0.65), settle_time + silence_time)
	blast.tween_property(dust, "transparency", 1.0, settle_time + silence_time)


func _wake() -> void:
	GameCommands.submit(GameCommandBus.Command.SET_LANDING_PHASE, {
		"phase": GameCommandBus.LandingPhase.WAKING,
	})
	shockwave.visible = false
	dust.visible = false

	# Pulling back on the wake is the reveal: the thing has landed, and here is
	# the world it landed on.
	if camera_rig != null:
		var pull: Tween = create_tween()
		pull.tween_method(camera_rig.set_zoom, impact_zoom, camera_rig.default_zoom, wake_time * 0.8)
