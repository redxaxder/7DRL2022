extends Actor

class_name PC

signal player_died()

var rage: int = 0
var rage_decay: int = 0
var fatigue: int = 0
var recovery: int = 0
var running: int = 0
var run_dir: int = 0
var attack: Attack = preload("res://lib/attacks/punch.gd").new()


func _ready():
	player = true
	speed = 6

var starting_rage: int = 20
var rage_on_got_hit: int = 10
var fatigue_on_got_hit: int = 5

func injure():
	if rage > 0:
		rage += rage_on_got_hit
		fatigue += fatigue_on_got_hit
		combatLog.say("+{0} rage   +{1} fatigue".format([rage_on_got_hit, fatigue_on_got_hit]))
	elif fatigue > 0:
		combatLog.say("You die.")
		emit_signal(constants.PLAYER_DIED)
	else:
		combatLog.say("You fly into a rage!")
		rage += rage_on_got_hit + starting_rage
		fatigue += fatigue_on_got_hit
		recovery = 0


func tick():
	if rage > 0:
		rage -= rage_decay
		rage = max(rage,0)
		rage_decay = 1 + fatigue / 40
	elif fatigue > 0:
		fatigue -= recovery
		fatigue = max(fatigue,0)
		recovery += 1
	else:
		recovery = 0
		
func enemy_hit(dir):
	#you've just hit an enemy!
	pass

func try_attack(dir) -> bool:
	var can_attack = false
	if rage > 0:
		can_attack = true
	elif fatigue <= 0:
		can_attack = true
	if can_attack:
		return attack.try_attack(locationService, get_pos(), dir)
	else:
		return false
