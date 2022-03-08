extends Node2D

var run: PackedScene = preload("res://scenes/run.tscn")
var constants = preload("res://lib/const.gd").new()


func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("action"):
		var r = run.instance()
		add_child(r)
		set_process_unhandled_input(false)
