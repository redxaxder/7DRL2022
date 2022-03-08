extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var constants = preload("res://lib/const.gd").new()

var actors: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _end_player_turn(pan: Vector2, player_pos: Vector2, terrain: Node2D):
	get_tree().call_group(constants.MOBS, "draw", pan)
	next_turn(player_pos, terrain)
	
func register_actor(actor: Sprite):
	actors.push_back(actor)
	
func next_turn(player_pos: Vector2, terrain: Node2D):
	get_tree().call_group(constants.MOBS, "on_turn", player_pos.x, player_pos.y, terrain)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
