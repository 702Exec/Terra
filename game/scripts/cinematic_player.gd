class_name CinematicPlayer
extends CanvasLayer

## Plays a queue of video clips full-screen, then hands control back.
##
## Assign clips and they play; leave the list empty and this reports finished
## immediately, which is what lets the in-engine grey-box sequence stand in
## until real footage exists. The mission gate does not care which ran.
##
## Godot 4 plays **Ogg Theora only**. An `.mp4` will not import as a VideoStream
## no matter where it is put — see `docs/terra-asset-pipeline.md`.
##
## Skippable by default and it should stay that way: this plays at the start of
## a mission the player may retry a dozen times.

## Played in order. Two ten-second clips make a twenty-second opener.
@export var clips: Array[VideoStream] = []
@export var skippable: bool = true
## Ignores input for a moment after the cinematic starts, so a click that was
## meant for the previous screen does not skip it instantly.
@export var skip_lockout: float = 0.4

signal finished()

@onready var frame: AspectRatioContainer = $Frame
@onready var video: VideoStreamPlayer = $Frame/Video
@onready var skip_hint: Label = $SkipHint

var _index: int = 0
var _playing: bool = false
var _elapsed: float = 0.0
## Cleared per clip; the stream's real size is only knowable once it plays.
var _ratio_set: bool = false


func _ready() -> void:
	visible = false
	set_process(false)
	set_process_unhandled_input(false)
	video.finished.connect(_on_clip_finished)


func has_clips() -> bool:
	return not clips.is_empty()


func play() -> void:
	if not has_clips():
		finished.emit()
		return
	_index = 0
	_elapsed = 0.0
	_playing = true
	visible = true
	skip_hint.visible = skippable
	set_process(true)
	set_process_unhandled_input(skippable)
	_start_clip()


func skip() -> void:
	if not _playing:
		return
	_finish()


func _process(delta: float) -> void:
	_elapsed += delta
	# The frame takes its shape from the footage rather than the other way round,
	# so a 2.33:1 clip letterboxes in a 16:9 window instead of being stretched to
	# fill it. Only knowable once the stream is running.
	if not _ratio_set:
		var texture: Texture2D = video.get_video_texture()
		if texture != null and texture.get_height() > 0:
			frame.ratio = float(texture.get_width()) / float(texture.get_height())
			_ratio_set = true


func _unhandled_input(event: InputEvent) -> void:
	if not _playing or not skippable or _elapsed < skip_lockout:
		return
	var pressed: bool = (event is InputEventKey and event.pressed) \
		or (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		get_viewport().set_input_as_handled()
		skip()


func _start_clip() -> void:
	_ratio_set = false
	video.stream = clips[_index]
	video.play()


func _on_clip_finished() -> void:
	if not _playing:
		return
	_index += 1
	if _index >= clips.size():
		_finish()
		return
	_start_clip()


func _finish() -> void:
	_playing = false
	video.stop()
	video.stream = null
	visible = false
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit()
