extends Node

class_name AudioPlayerPool

export var pool_size: int = 4

var __pool_ready = []

func _ready():
	for __ in pool_size:
		var asp = AudioStreamPlayer.new()
		add_child(asp)
		__pool_ready.append(asp)

func play(stream: AudioStream) -> bool:
	var asp = __pool_ready.pop_back()
	if asp == null:
		return false
	asp.stream = stream
	asp.play()
	asp.connect("finished", self, "_on_playback_complete", [asp], CONNECT_ONESHOT)
	return true

func _on_playback_complete(asp: AudioStreamPlayer):
	__pool_ready.append(asp)

const shuffle: AudioStream = preload("res://resources/sounds/shuffle.wav")
