extends Actor

class_name PC

signal player_died()
signal status_changed()

var rage: int = 0
var rage_decay: int = 0
var fatigue: int = 0
var starting_recovery: int = 0
var recovery: int = 0
var southpaw = false

const base_experience_gain_rate: int = 10
const experience_gain_step: int = 10
const max_experience_gain_rate: int = 200

var experience_gain_rate: int = base_experience_gain_rate
var experience: int = 0

const base_experience_needed = 200
const experience_needed_step = 400
var experience_needed = base_experience_needed


var running: int = 0
var run_dir: int = 0

var pickup: Pickup = null
var weapon = null

var punch = preload("res://lib/attacks/punch.gd").new()
var throw = preload("res://lib/attacks/throw.gd").new()
const pickup_scene = preload("res://pickups/pickup.tscn")

func _ready():
	randomize()
	self.player = true
	self.speed = 6
	self.pc = self
	southpaw = randi() % 4 == 0
	add_to_group(constants.PLAYER)

var starting_rage: int = 40
var rage_on_got_hit: int = 6
var rage_on_kill: int = 2
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
		recovery = starting_recovery
	rage_decay = 1 + fatigue / 40
	emit_signal(constants.PLAYER_STATUS_CHANGED)

func make_shards() -> Pickup:
	var shards = pickup_scene.instance()
	shards.init(shards.ITEM_TYPE.SHARDS)
	shards.locationService = locationService
	get_parent().add_child(shards)
	shards.take()
	return shards

func tick():
	if rage > 0:
		rage -= rage_decay
		rage = max(rage,0)
		rage_decay = 1 + fatigue / 40
		if rage == 0: # we left rage!
			experience_gain_rate = base_experience_gain_rate
	elif fatigue > 0:
		recover(recovery)
		recovery += 1
	else:
		recovery = 0
	emit_signal(constants.PLAYER_STATUS_CHANGED)

func try_attack(dir) -> bool:
	var can_attack = false
	var did_attack = false
	var calm = rage <= 0
	if rage > 0:
		can_attack = true
	elif fatigue <= 0:
		can_attack = true
	if can_attack:
		if weapon != null:
			did_attack = weapon.attack.try_attack(locationService, get_pos(), dir)
		else:
			did_attack = punch.try_attack(locationService, get_pos(), dir)
	if calm && did_attack:
		rage += starting_rage
	return did_attack

func try_kick_furniture(dir) -> bool:
	var acted = false
	var targetCell = get_pos() + DIR.dir_to_vec(dir)
	var targets = locationService.lookup(targetCell, constants.FURNITURE)
	for t in targets:
		if rage > 0:
			acted = t.kick(dir)
		else:
			acted = t.nudge(dir)
	return acted


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
	var did_throw := false
	var dirs = [Dir.DIR.UP, Dir.DIR.LEFT, Dir.DIR.DOWN, Dir.DIR.RIGHT]
	dirs.shuffle()
	for d in dirs: #first, try to throw at an enemy
		if !did_throw:
			did_throw = throw.try_attack(locationService, get_pos(), d, terrain)
	if did_throw:
		pickup.queue_free()
		pickup = null
	if !did_throw: #otherwise, throw it on the ground!
		combatLog.say("You throw the {0} on the ground!".format([pickup.label]))
		pickup.place(get_pos())
		pickup = null
		did_throw = true
	return did_throw

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
			make_shards().place(get_pos())
			#TODO: put out fire. maybe add wet?
			return true
		p.ITEM_TYPE.BRANDY:
			combatLog.say("You smash the bottle against your face. You're soaked.")
			pickup.queue_free()
			pickup =	 make_shards()
			make_shards().place(get_pos())
			return true
			#TODO: soak in alchohol
	return true

func _on_pick_perk(p: Perk):
	experience -= experience_needed
	experience_needed += experience_needed_step
	match p.perk_type:
		p.PERK_TYPE.BLOODLUST:
			rage_on_kill += p.bonus
		p.PERK_TYPE.VENGEANCE:
			rage_on_got_hit += p.bonus
		p.PERK_TYPE.ENDURANCE:
			starting_recovery += p.bonus
		p.PERK_TYPE.SHORT_TEMPERED:
			starting_rage += p.bonus
	emit_signal(constants.PLAYER_STATUS_CHANGED)
	emit_signal(constants.PLAYER_LEVEL_UP)

func _on_enemy_killed(label: String):
	experience += experience_gain_rate
	experience_gain_rate += experience_gain_step
	experience_gain_rate = min(experience_gain_rate, max_experience_gain_rate)
	rage += rage_on_kill
