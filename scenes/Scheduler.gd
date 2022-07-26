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
var turns_since_player: int = 0
signal start_player_turn()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player_turn = true

func _end_player_turn():
	self.player_turn = false
	while next_turn():
		pass
	emit_signal("start_player_turn")

func register_actor(actor: Actor):
	if !actors.has(actor):
		actors[actor] = 0

func next_turn() -> bool:
	var largest: float = 0
	for actor in actors.keys():
		if legit(actor):
			if priority(actor) > largest:
				largest = priority(actor)
	if largest <= 0:
		# time to recalculate
		recalculate_turns()
		return true
	var current_actors = []
	for actor in actors.keys():
		if legit(actor) && priority(actor) == largest:
			current_actors.push_back(actor)
	current_actors.shuffle()
	for actor in current_actors:
		if pc_dead:
			return false
		if legit(actor):
			turns_since_player+= 1
			actors[actor] -= 1
			if actor.player:
				self.player_turn = true
				turns_since_player = 0
				return false
			actor.animation_delay(sqrt(turns_since_player) * 0.15 + actor.pc.pending_animation())
			actor.do_turn()
			actor.update()
	return true

func priority(a) -> int:
	if is_instance_valid(a):
		return (1000 * actors[a] * 30 / a.speed) +  a.tiebreaker - 100
	else:
		return -1

func legit(a) -> bool:
	return a != null && is_instance_valid(a) && a.get_pos() != null

func recalculate_turns():
	var actors2 = {}
	for a in actors.keys():
		if legit(a):
			actors2[a] = a.speed
	actors = actors2

var pc_dead: bool = false
func _on_player_death():
	pc_dead = true

func clear():
	for a in actors.keys():
		if a != null && is_instance_valid(a) && !a.player:
			a.visible = false
			a.queue_free()
	actors = {}
