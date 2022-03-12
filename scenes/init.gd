extends Node2D

var run: PackedScene = preload("res://scenes/run.tscn")
var constants = preload("res://lib/const.gd").new()


func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_KEEP,Vector2(1024,600))

var r: Node2D

func _unhandled_input(event):
	if event.is_action_pressed("action"):
		r = run.instance()
		add_child(r)
		set_process_unhandled_input(false)
		for c in $splash.get_children():
			c.visible = false

func reset():
	set_process_unhandled_input(true)
	r.queue_free()
	for c in $splash.get_children():
		c.visible = true

