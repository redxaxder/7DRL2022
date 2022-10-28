extends Control

func _ready():
	$VBoxContainer/Button.connect("pressed", self, "button1")
	$VBoxContainer/Button2.connect("pressed", self, "button2")

const shuffle: AudioStream = preload("res://resources/sounds/splat.wav")
func button1():
	$AudioPlayerPool.play(shuffle)

func button2():
	$AudioPlayerPool.play(shuffle)
	$AudioPlayerPool.play(shuffle)
	$AudioPlayerPool.play(shuffle)
	$AudioPlayerPool.play(shuffle)
	$AudioPlayerPool.play(shuffle)
	$AudioPlayerPool.play(shuffle)
#	$AudioPlayerPool.play_delay(shuffle)
#	$AudioPlayerPool.play_delay(shuffle)
#	$AudioPlayerPool.play_delay(shuffle)
#	$AudioPlayerPool.play_delay(shuffle)
