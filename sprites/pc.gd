extends "res://lib/actor.gd"

class_name PC

var rage = 0
var fatigue = 0
var recovery = 0

func _ready():
	player = true
	speed = 6
	pos = Vector2(3,3)


var starting_rage = 20
var rage_on_got_hit = 5
var fatigue_on_got_hit = 5

func injure():
	if rage > 0:
		rage += rage_on_got_hit
		fatigue += fatigue_on_got_hit
	elif fatigue > 0:
		combatLog.say("You suffer a fatal blow!")
	else:
		combatLog.say("You fly into a rage!")
		rage += rage_on_got_hit + starting_rage
		fatigue += fatigue_on_got_hit
		recovery = 0

func tick():
	if rage > 0:
		rage -= 1
	elif fatigue > 0:
		fatigue -= recovery
		fatigue = max(fatigue,0)
		recovery += 1
	else:
		recovery = 0
