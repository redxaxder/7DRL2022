extends Node

class_name AudioPlayerPool

export var pool_size: int = 4
export var bus: String
export var pitch_variance: float = 0

var __pool_ready = []

func _ready():
	for __ in pool_size:
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		__pool_ready.append(asp)

func play(stream: AudioStream) -> bool:
	if __started_sounds.get(stream) != null:
		return false
	var asp = __pool_ready.pop_back()
	if asp == null:
		return false
	asp.stream = stream
	asp.bus = bus
	if pitch_variance != 0:
		asp.pitch_scale = 1 + (randf() * pitch_variance)
	asp.play()
	asp.connect("finished", self, "_on_playback_complete", [asp], CONNECT_ONESHOT)
	if __started_sounds.empty():
		call_deferred("_clear_started")
	__started_sounds[stream] = 0
	return true

var __started_sounds: Dictionary = {}

func _clear_started():
	__started_sounds.clear()

func _on_playback_complete(asp: AudioStreamPlayer):
	__pool_ready.append(asp)

const shuffle: AudioStream = preload("res://resources/sounds/shuffle.wav")
