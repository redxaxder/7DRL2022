extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var constants = preload("res://lib/const.gd").new()

var actors: Array
var combat_round: int = 0
var turn: int = 0
var player_turn: bool = false
var turns_per_round: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player_turn = true

func _end_player_turn(pan: Vector2, player_pos: Vector2, terrain: Node2D):
	self.player_turn = false
	next_turn(player_pos, terrain, pan)
	
func register_actor(actor: Sprite):
	actors.push_back(actor)
	recalculate_turns()
	
func next_turn(player_pos: Vector2, terrain: Node2D, pan: Vector2):
	get_tree().call_group(constants.MOBS, "draw", pan)
	var largest: int = 0
	for actor in turns_per_round.keys():
		if priority(actor) > largest:
			largest = priority(actor)
	if largest == 0:
		# time to recalculate
		recalculate_turns()
		return next_turn(player_pos, terrain, pan)
	for actor in turns_per_round.keys():
		if priority(actor) == largest:
			turns_per_round[actor] -= 1	
			if actor.player:
				self.player_turn = true
				return
			actor.on_turn()
			next_turn(player_pos, terrain, pan)

func priority(a) -> int:
	return turns_per_round[a] * 30 / a.speed

func recalculate_turns():
	for a in actors:
		turns_per_round[a] = a.speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass