class_name AudioDirector
extends Node

## Non-positional audio cues, driven entirely off command-bus signals.
##
## These are placeholder tones, not an audio pass — Phase 5 owns that. What
## matters now is that the wiring is real, so replacing a cue is dropping a file
## into assets/audio rather than writing code.
##
## Two of these are load-bearing rather than decorative. Once the map outgrew
## one screen, "your extractor is under attack" became information the player
## cannot see, and the ear is the only channel that does not require looking in
## the right place.

@export var wave_warning: AudioStream
@export var under_attack: AudioStream
@export var structure_lost: AudioStream
@export var upgrade_ready: AudioStream
@export var turret_placed: AudioStream
@export var turret_sold: AudioStream
@export var run_over: AudioStream
@export var orbital_charge: AudioStream
@export var orbital_impact: AudioStream
@export var landing_descent: AudioStream
@export var landing_impact: AudioStream
@export var engine_wake: AudioStream

## Voices, so a cue never cuts off the one before it.
const VOICE_COUNT: int = 6
## An under-attack cue at most this often, however many enemies are chewing.
const ATTACK_CUE_COOLDOWN: float = 2.5

var _players: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
var _attack_cooldown: float = 0.0


func _ready() -> void:
	for _i: int in range(VOICE_COUNT):
		var player := AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		_players.append(player)

	GameCommands.landing_phase_changed.connect(_on_landing_phase_changed)
	GameCommands.wave_incoming.connect(_on_wave_incoming)
	GameCommands.structure_damaged.connect(_on_structure_damaged)
	GameCommands.structure_destroyed.connect(_on_structure_destroyed)
	GameCommands.upgrade_purchased.connect(_on_upgrade_purchased)
	GameCommands.turret_placed.connect(_on_turret_placed)
	GameCommands.turret_sold.connect(_on_turret_sold)
	GameCommands.orbital_strike_called.connect(_on_orbital_called)
	GameCommands.orbital_strike_impacted.connect(_on_orbital_impacted)
	GameCommands.run_ended.connect(_on_run_ended)


func _process(delta: float) -> void:
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)


## Ordinary teardown hygiene. Note this does not silence Godot's leaked-resource
## report when the game is closed mid-cue: playbacks are released on the audio
## thread, which does not run again after quit, so the reference outlives the
## node no matter what is done here. See the gotcha in CLAUDE.md.
func _exit_tree() -> void:
	for player: AudioStreamPlayer in _players:
		if is_instance_valid(player) and player.playing:
			player.stop()


func _play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = _players[_next_voice]
	_next_voice = (_next_voice + 1) % _players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


## The landing's three audible beats. The silence between impact and wake is
## deliberately not filled.
func _on_landing_phase_changed(phase: GameCommandBus.LandingPhase) -> void:
	match phase:
		GameCommandBus.LandingPhase.DESCENT:
			_play(landing_descent, -1.0)
		GameCommandBus.LandingPhase.IMPACT:
			_play(landing_impact, 4.0)
		GameCommandBus.LandingPhase.WAKING:
			_play(engine_wake, 0.0)


func _on_wave_incoming(_wave_number: int, _lane_names: PackedStringArray) -> void:
	_play(wave_warning)


## Damage arrives once per enemy per attack tick, so this is rate limited hard —
## otherwise a wave chewing an extractor is a machine gun.
func _on_structure_damaged(_structure: Node3D, current: int, maximum: int) -> void:
	if current >= maximum or _attack_cooldown > 0.0:
		return
	_attack_cooldown = ATTACK_CUE_COOLDOWN
	_play(under_attack)


func _on_structure_destroyed(_structure: Node3D) -> void:
	_play(structure_lost, 2.0)


func _on_upgrade_purchased(_track_id: StringName, _level: int) -> void:
	_play(upgrade_ready)


func _on_turret_placed(_turret: Node3D) -> void:
	_play(turret_placed, -6.0)


func _on_turret_sold(_position: Vector3, _refund: int) -> void:
	_play(turret_sold, -6.0)


func _on_orbital_called(_world_position: Vector3) -> void:
	_play(orbital_charge, -2.0)


func _on_orbital_impacted(_world_position: Vector3, _enemies_hit: int) -> void:
	_play(orbital_impact, 3.0)


func _on_run_ended(_final_wave: int) -> void:
	_play(run_over, 2.0)
