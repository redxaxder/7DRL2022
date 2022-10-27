extends Control

func _ready():
	$VBoxContainer/Button.connect("pressed", self, "button1")

const shuffle: AudioStream = preload("res://resources/sounds/shuffle.wav")
func button1():
	$AudioPlayerPool.play(shuffle)
