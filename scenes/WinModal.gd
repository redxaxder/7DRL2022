extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("action"):
		get_parent().get_parent().reset()
