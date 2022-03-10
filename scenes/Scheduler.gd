extends Node

class_name Scheduler

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var constants = preload("res://lib/const.gd").new()

var actors: Dictionary = {} # maps actor -> turns per round (int)
var combat_round: int = 0
var turn: int = 0
var player_turn: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player_turn = true

func _end_player_turn():
	self.player_turn = false
	while next_turn():
		pass

func register_actor(actor: Actor):
	actors[actor] = 0

func next_turn() -> bool:
	var largest: int = 0
	for actor in actors:
		if priority(actor) > largest:
			largest = priority(actor)
	if largest == 0:
		# time to recalculate
		recalculate_turns()
		return true
	for actor in actors:
		if priority(actor) == largest:
			actors[actor] -= 1
			if actor.player:
				self.player_turn = true
				return false
			actor.on_turn()
			actor.update()
			return true
	return true

func priority(a) -> int:
	if is_instance_valid(a): 
		return actors[a] * 30 / a.speed
	else:
		print("whaaa")
		return 0

func recalculate_turns():
	print("rrr")
	var actors2 = {}
	for a in actors:
		if is_instance_valid(a):
			actors2[a] = a.speed
	actors = actors2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
