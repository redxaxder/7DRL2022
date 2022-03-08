extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var constants = preload("res://lib/const.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _end_player_turn(pan: Vector2):
	get_tree().call_group(constants.MOBS, "draw", pan)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
