extends Actor

class_name PC

signal player_died()
signal status_changed()
signal rage_lighting(switch)
signal level_up()
signal exit_level()

var rage: int = 0
var rage_decay: int = 0
const rage_speed: int = 6
const normal_speed: int = 3

const weapon_break_level: int = 100
var weapons_broken: int = 0

var fatigue: int = 0
var starting_recovery: int = 0
var recovery: int = 0
var southpaw = false
var run_speed: int = 1
const max_run_speed: int = 4
var run_dir: int = -1
var extra_knockback: int = 0
var second_wind_bonus: int = 0

const base_experience_gain_rate: int = 1
const experience_gain_step: int = 1
const max_experience_gain_rate: int = 100

var experience_gain_rate: int = base_experience_gain_rate
var experience: int = 0

const base_experience_needed = 1000
const experience_needed_step = 1000
var experience_needed = base_experience_needed

var pickup: Pickup = null
var weapon = null

var punch = preload("res://lib/attacks/punch.gd").new()
var throw = preload("res://lib/attacks/throw.gd").new()
const pickup_scene = preload("res://pickups/pickup.tscn")
var debuff_effects = preload("res://lib/debuffs.gd").new()

func _ready():
	randomize()
	self.player = true
	self.speed = normal_speed
	self.pc = self
	southpaw = randi() % 4 == 0
	add_to_group(self.constants.PLAYER)

var starting_rage: int = 40
var rage_on_got_hit: int = 6
var rage_on_kill: int = 2
var fatigue_on_got_hit: int = 5
var debuffs: Dictionary = {}

func enter_rage():
	combatLog.say("You fly into a rage!")
	emit_signal(self.constants.RAGE_LIGHTING, true)
	weapons_broken = 0
	rage += rage_on_got_hit + starting_rage
	fatigue += fatigue_on_got_hit
	recovery = starting_recovery
	speed = rage_speed

func injure():
	if rage > 0:
		rage += rage_on_got_hit
		fatigue += fatigue_on_got_hit
		self.combatLog.say(" +{0} rage  +{1} fatigue".format([rage_on_got_hit, fatigue_on_got_hit]))
	elif fatigue > 0:
		var pos = get_pos()
		for dir in [Dir.DIR.UP, Dir.DIR.LEFT, Dir.DIR.DOWN, Dir.DIR.RIGHT]:
			terrain.splatter_blood(pos, DIR.dir_to_vec(dir))
			terrain.splatter_blood(pos, DIR.dir_to_vec(dir))
			terrain.splatter_blood(pos, DIR.dir_to_vec(dir))
		emit_signal(self.constants.PLAYER_DIED)
	else:
		enter_rage()
	rage_decay = 1 + fatigue / 40
	emit_signal(self.constants.PLAYER_STATUS_CHANGED)

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
		rage = max(rage,int(0))
		rage_decay = 1 + fatigue / 40
		if rage == 0: # we left rage!
			experience_gain_rate = base_experience_gain_rate
			debuffs = debuff_effects.get_fatigue_effects(fatigue)
			emit_signal(constants.RAGE_LIGHTING, false)
	elif fatigue > 0:
		speed = normal_speed
		recover(recovery)
		recovery += 1
	else:
		speed = normal_speed
		recovery = 0
	emit_signal(constants.PLAYER_STATUS_CHANGED)

func stop_run():
	self.run_speed = 1
	self.run_dir = -1
	emit_signal(constants.PLAYER_STATUS_CHANGED)		

func try_attack(dir, force_bear_hands: bool = false) -> bool:
	var can_attack = false
	var did_attack = false
	if rage > 0:
		can_attack = true
	elif fatigue <= 0:
		can_attack = true
	if can_attack:
		if weapon != null and not force_bear_hands:
			weapon.attack.extra_knockback = extra_knockback
			did_attack = weapon.attack.try_attack(locationService, get_pos(), dir, pending_animation(), terrain)
			if did_attack && fatigue - (weapons_broken * weapon_break_level) > weapon_break_level:
				combatLog.say("The {0} crumbles in your grasp.".format([weapon.label]))
				weapons_broken += 1
				var w = weapon
				weapon = null
				w.queue_free()
		else:
			punch.extra_knockback = extra_knockback
			did_attack = punch.try_attack(locationService, get_pos(), dir, pending_animation(), terrain)
	return did_attack

func try_kick_furniture(dir) -> bool:
	var acted = false
	var targetCell = get_pos() + DIR.dir_to_vec(dir)
	var targets = locationService.lookup(targetCell, constants.FURNITURE)
	for t in targets:
		t.animation_delay(self.pending_animation())
		if rage > 0:
			acted = t.kick(dir, extra_knockback)
		else:
			acted = t.nudge(dir)
	return acted

func try_move(dir, anim_speed_multiplier = 1.0) -> bool:
	var pos = get_pos() + DIR.dir_to_vec(dir)
	var mobs = locationService.lookup(pos, constants.MOBS)
	if debuffs.has(self.constants.IMMOBILIZED) and debuffs[self.constants.IMMOBILIZED] > 0:
		combatLog.say("You are too weak to walk.")
		return false
	if mobs.size() > 0 && fatigue > 0 && rage == 0:
		combatLog.say("You are too exhausted to fight!")
		return false
	var blockers = locationService.lookup(pos, constants.BLOCKER)
	if terrain.is_wall(pos):
		if rage > 0:
			combatLog.say("The wall blocks your path.")
		else:
			combatLog.say("The wall looms over you.")
		return false
	elif blockers.size() > 0:
		return false
	elif terrain.is_exit(pos):
		combatLog.say("")
		combatLog.say("You make your way up the stairs.")
		emit_signal(constants.EXIT_LEVEL)
		return true
	else:
		animated_move_to(pos, 1/anim_speed_multiplier)
		update()
		return true

func pick_up(p: Pickup, l: Vector2):
	if debuffs.has(self.constants.FUMBLE) and debuffs[self.constants.FUMBLE] > 0:
		self.combatLog.say("You're too weak to pick up the {0}".format([p.label]))
		return
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
	for d in debuffs.keys():
		if fatigue == 0:
			debuffs[d] = 0
		else:
			debuffs[d] = max(0, debuffs[d] - amount)

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
			throw.combatLog = combatLog
			throw.message = "You throw your {0} at the ".format([pickup.label]) + "{0}."
			did_throw = throw.try_attack(locationService, get_pos(), d, self.pending_animation(), terrain)
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
		p.PERK_TYPE.POWER_ATTACK:
			extra_knockback += p.bonus
		p.PERK_TYPE.SECOND_WIND:
			second_wind_bonus += p.bonus
		_:
			pass
	var second_wind_recovery = float(second_wind_bonus) / 100.0
	fatigue = int(fatigue * (1 - second_wind_recovery))
	for d in debuffs.keys():
		debuffs[d] = int(debuffs[d] * (1 - second_wind_recovery))
	emit_signal(constants.PLAYER_STATUS_CHANGED)
	emit_signal(constants.PLAYER_LEVEL_UP)

func _on_enemy_killed(label: String):
	if rage == 0:
		enter_rage()
	experience += experience_gain_rate
	experience_gain_rate += experience_gain_step
	experience_gain_rate = min(experience_gain_rate, max_experience_gain_rate)
	rage += rage_on_kill
	combatLog.say("The {0} dies. \n +{1} rage  +{2} exp".format([label, rage_on_kill, experience_gain_rate]))
	emit_signal(constants.PLAYER_STATUS_CHANGED)
