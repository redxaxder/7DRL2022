extends Node2D

class_name Actor

var constants = preload("res://lib/const.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()
const thump_scene = preload("res://audio/thump.tscn")
var thump_node: AudioStreamPlayer = null

export var glyph_index: int = 5 setget set_glyph_index
export var color: Color = Color(1,1,1,1) setget set_color
var actor_body: ActorBody = null


var terrain setget set_terrain
var combatLog: CombatLog
var locationService: LocationService
var pc
var tiebreaker: int = 50 # for actors with the same priority in the scheduler

var player: bool = false
var speed: int = 3
var label: String = ""
var door: bool = false
var blocking: bool = false
var telegraphing: bool = false
var is_ready: bool = false
var on_fire: int = 0 setget set_on_fire
var flammability: float = 0.3

const block_duration: int = 2
var cur_block_duration: int = 0

var is_ragdoll: bool = false
var ragdoll_dir: Vector2

signal killed_by_pc(label)
signal thump()

func _ready():
	position = Vector2.ZERO
	actor_body = ActorBody.new()
	add_child(actor_body)
	set_terrain(terrain)
	set_glyph_index(glyph_index)
	set_on_fire(on_fire)
	set_color(color)

func do_turn():
	if self.on_fire <= 0 || player:
		if has_method("on_turn"):
			call("on_turn")
		return
	# we're on fire! run around screaming
	var e = get_pos()
	var candidates = [e, Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	var legal_candidates = []
	for c in candidates:
		if self.locationService.lookup(c, Const.BLOCKER).size() == 0:
			if not terrain.is_wall(c) and c != pc.get_pos():
				legal_candidates.append(c)
	if legal_candidates.size() > 0:
		var target = legal_candidates[randi() % legal_candidates.size()]
		animated_move_to(target)

func get_pos(default = null) -> Vector2:
	if !locationService: return default
	return locationService.lookup_backward(self, default)

func set_pos(p: Vector2):
	locationService.insert(self,p)

func block_decay():
	if blocking:
		if cur_block_duration < block_duration:
			cur_block_duration += 1
		else:
			end_block()

func update():
	if self.is_in_group(Const.MOBS) && !self.is_in_group(Const.ON_FIRE):
		if blocking:
			if telegraphing:
				actor_body.set_color(Const.WINDUP_AND_PROTECTED_COLOR)
			elif is_ready:
				actor_body.set_color(Const.READY_AND_PROTECTED_COLOR)
			else:
				actor_body.set_color(Const.PROTECTED_COLOR)
		else:
			if telegraphing:
				actor_body.set_color(Const.WINDUP_COLOR)
			elif is_ready:
				actor_body.set_color(Const.READY_COLOR)
			else:
				actor_body.set_color(Color(0.7, 0.7, 0.7))
	actor_body.update()

func end_block():
	blocking = false
	update()

func block():
	cur_block_duration = 0
	if !blocking:
		blocking = true
		update()

func get_ready():
	is_ready = true
	update()

func end_ready():
	is_ready = false
	update()

func die(_dir: Vector2):
	#notify PC of kills
	#TODO: maybe handle if it was killed by someone else (eg: wizard)
	if is_in_group(Const.MOBS):
		emit_signal("killed_by_pc", label)
	if self.locationService:
		self.locationService.delete_node(self)
	#TODO: the body outlives the soul (briefly)
	queue_free()

func animated_move_to(target: Vector2, duration: float = 1):
	var start_pos = get_pos()
# warning-ignore:narrowing_conversion
	var prev_screen_position = self.SCREEN.dungeon_to_screen(start_pos)
# warning-ignore:narrowing_conversion
	var target_screen_position = self.SCREEN.dungeon_to_screen(target)
	var dp = prev_screen_position - target_screen_position
	var av = Vector3(dp.x,dp.y,duration)
	actor_body.anim_screen_offsets.push_back(av)
	set_pos(target)

func animated_move_to_combine(target: Vector2, backup_duration: float = 1):
	var start_pos = get_pos()
	var prev_screen_position = self.SCREEN.dungeon_to_screen(start_pos)
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	var target_screen_position = self.SCREEN.dungeon_to_screen(target)
	var dp = prev_screen_position - target_screen_position
	var av = Vector3(dp.x,dp.y,0)
	if actor_body.anim_screen_offsets.size() > 0:
		actor_body.anim_screen_offsets[actor_body.anim_screen_offsets.size() - 1] += av
		set_pos(target)
	else:
		animated_move_to(target, backup_duration)

const knockback_anim_tile = 0.2
func knockback(dir: Vector2, distance: int = 1000, power = 1):
	var landed = get_pos()
	var next
	var collision = false
	var strong_collision = false
	var anim = 0
	var travel = -1
	while distance > 0 && power > 0:
		distance -= 1
		anim += knockback_anim_tile
		travel += 1
		next = landed + dir
		if is_in_group(Const.ON_FIRE):
			try_ignite_neighbors(next)
		if terrain.is_wall(next):
			if !self.player:
				combatLog.say("The {0} collides with the wall.".format([self.label]))
			else:
				combatLog.say("You collide with the wall.", 20)
			collision = true
			strong_collision = true
			break
		var blockers = locationService.lookup(next, Const.BLOCKER)
		if blockers.size() > 0:
			if !self.player:
				combatLog.say("The {0} collides with the {1}.".format([self.label, blockers[0].label]))
			else:
				combatLog.say("You collide with the {1}.".format([self.label, blockers[0].label]))
			collision = true
			for b in blockers:
				power -= 1
				if b.blocking:
					var rem = power
					power = 0 #perfectly inelastic
					combatLog.say("The {0} goes flying!".format([blockers[0].label]))
					b.animation_delay(actor_body.pending_animation()+anim)
					b.knockback(dir, distance, rem)
					strong_collision = true
					break
				elif	 b.is_in_group(Const.FURNITURE):
					b.animation_delay(actor_body.pending_animation()+anim)
					b.die(dir)
				elif b.player:
					b.injure()
				else:
					b.animation_delay(actor_body.pending_animation()+anim)
					b.die(dir)
		if power > 0:
			landed = next
	animated_move_to(landed, anim)
	if collision:
		if self.blocking:
			if travel == 0 && strong_collision:
				self.die(dir)
			self.end_block()
		elif self.player:
			self.pc.injure()
		else:
			self.die(dir)
	if self.player:
		self.pc.stop_run()
	update()
	emit_signal("thump")

func do_fire():
	self.on_fire = self.on_fire - 1
	if on_fire <= 0:
		die(Dir.dir_to_vec(randi() % 4))
		extinguish()
	# spread the fire
	var e = get_pos()
	if e != null:
		try_ignite_neighbors(e)

func try_ignite_neighbors(e: Vector2):
	var candidates = [Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	for c in candidates:
		for thing in self.locationService.lookup(c, Const.FLAMMABLE):
			if randf() < thing.flammability:
				thing.ignite()

var fire_particles: Node = null
var pre_fire_color = null

func ignite():
	self.on_fire = 3
	if pre_fire_color == null:
		pre_fire_color = actor_body.self_modulate
	add_to_group(Const.ON_FIRE)
	if fire_particles == null:
		fire_particles = preload("res://scenes/burning.tscn").instance()
		add_child(fire_particles)

func extinguish():
	self.on_fire = 0
	remove_from_group(Const.ON_FIRE)
	actor_body.set_color(pre_fire_color)
	pre_fire_color = null
	if fire_particles != null:
		fire_particles.queue_free()
		fire_particles = null


########## indirection to actor_body

func pending_animation() -> float:
	if !actor_body:
		return 0.0
	return actor_body.pending_animation()

func animation_delay(duration: float):
	if !actor_body:
		return
	actor_body.animation_delay(duration)

func set_glyph_index(x: int):
	glyph_index = x
	if !actor_body:
		return
	actor_body.glyph_index = x
	actor_body._refresh()

func set_color(x: Color):
	color = x
	if !actor_body: return
	actor_body.self_modulate = color
	actor_body._refresh()

func set_terrain(x: Terrain):
	terrain = x
	if !actor_body:
		return
	actor_body.terrain = x

func set_on_fire(x: int):
	on_fire = x
	if !actor_body: return
	actor_body.on_fire = on_fire
	actor_body._refresh()
