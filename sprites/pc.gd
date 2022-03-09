extends Actor

class_name PC

signal player_died()

var rage: int = 0
var rage_decay: int = 0
var fatigue: int = 0
var recovery: int = 0
var running: int = 0
var run_dir: int = 0

var pickup: Pickup = null
var weapon = null

var punch = preload("res://lib/attacks/punch.gd").new()
const pickup_scene = preload("res://pickups/pickup.tscn")

func _ready():
	self.player = true
	self.speed = 6

var starting_rage: int = 20
var rage_on_got_hit: int = 10
var fatigue_on_got_hit: int = 5

func injure():
	if rage > 0:
		rage += rage_on_got_hit
		fatigue += fatigue_on_got_hit
		self.combatLog.say("+{0} rage   +{1} fatigue".format([rage_on_got_hit, fatigue_on_got_hit]))
	elif fatigue > 0:
		self.combatLog.say("You die.")
		emit_signal(self.constants.PLAYER_DIED)
	else:
		combatLog.say("You fly into a rage!")
		rage += rage_on_got_hit + starting_rage
		fatigue += fatigue_on_got_hit
		recovery = 0

func make_shards() -> Pickup:
	var shards = pickup_scene.instance()
	shards.init(shards.ITEM_TYPE.SHARDS)
	shards.locationService = locationService
	return shards

func tick():
	if rage > 0:
		rage -= rage_decay
		rage = max(rage,0)
		rage_decay = 1 + fatigue / 40
	elif fatigue > 0:
		recover(recovery)
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
		if weapon != null:
			return weapon.attack.try_attack(locationService, get_pos(), dir)
		else:
			return punch.try_attack(locationService, get_pos(), dir)
	else:
		return false

func pick_up(p: Pickup, l: Vector2):
	if p.is_weapon:
		var wt = -1
		if weapon != null:
			wt = weapon.weapon_type
			weapon.place(l)
		weapon = p
		if p.weapon_type != wt:
			combatLog.say(p.pickup_text)
		p.take()
	else:
		var it = -1
		if pickup != null:
			it = pickup.type
			pickup.place(l)
		pickup = p
		if p.type != it:
			combatLog.say(p.pickup_text)
		p.take()

func consume() -> bool:
	var did_consume = false
	if pickup != null:
		if rage > 0:
			did_consume = consume_angry(pickup)
		else:
			did_consume = consume_calm(pickup)
	return did_consume

func recover(amount: int):
	fatigue = max(0, fatigue - amount)

func consume_calm(p: Pickup) -> bool:
	match p.type:
		p.ITEM_TYPE.APPLE:
			recover(30)
			combatLog.say("You eat the apple. Delicious!")
		p.ITEM_TYPE.TURKEY:
			recover(fatigue)
			combatLog.say("You choke down the entire turkey. You feel in fighting shape.")
		p.ITEM_TYPE.WATER:
			recovery += 5
			combatLog.say("You drink the water. You feel refreshed.")
		p.ITEM_TYPE.BRANDY:
			#TODO
			combatLog.say("You drink the brandy. You're itching for a fight.")
		p.ITEM_TYPE.SHARDS:
			return false
	pickup.queue_free()
	pickup = null
	return true

func throw_item() -> bool:
	#TODO
	return true

func consume_angry(p: Pickup) -> bool:
	match p.type:
		p.ITEM_TYPE.APPLE:
			return throw_item()
		p.ITEM_TYPE.TURKEY:
			return throw_item()
		p.ITEM_TYPE.SHARDS:
			return throw_item()
		p.ITEM_TYPE.WATER:
			combatLog.say("You smash the bottle against your face. You're soaked.")
			pickup.queue_free()
			pickup =	 make_shards()
			#TODO: put out fire. maybe add wet?
			return true
		p.ITEM_TYPE.BRANDY:
			combatLog.say("You smash the bottle against your face. You're soaked.")
			pickup.queue_free()
			pickup =	 make_shards()
			return true
			#TODO: soak in alchohol
	return true

