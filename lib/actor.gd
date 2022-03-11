extends Sprite

class_name Actor

var constants = preload("res://lib/const.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()

var terrain
var combatLog: CombatLog
var locationService: LocationService
var pc

var player: bool = false
var speed: int = 3
var label: String = ""
var door: bool = false
var blocking: bool = false

var anim_screen_offsets: Array
var anim_speed: float = 7


func get_pos(default = null) -> Vector2:
	return locationService.lookup_backward(self, default)

func set_pos(p: Vector2):
	locationService.insert(self,p)

func die(dir: Vector2):
	if is_in_group(self.constants.MOBS):
		# splatter blood everywhere
		var pos = get_pos()
		terrain.splatter_blood(pos, dir)
	self.locationService.delete_node(self)
	#TODO: handle if it was killed by someone else (eg: wizard)
	emit_signal(constants.KILLED_BY_PC, label)
	queue_free()

func animated_move_to(target: Vector2, duration: float = 1):
	var start_pos = get_pos()
	var prev_screen_position = self.SCREEN.dungeon_to_screen(start_pos.x, start_pos.y)
	var target_screen_position = self.SCREEN.dungeon_to_screen(target.x, target.y)
	var dp = prev_screen_position - target_screen_position
	var av = Vector3(dp.x,dp.y,duration)
	anim_screen_offsets.push_back(av)
	set_pos(target)

func animation_delay(duration: float):
	var av = Vector3(0,0,duration)
	anim_screen_offsets.push_back(av)

func knockback(dir: Vector2, distance: int = 1000000, power = 1):
	var landed = get_pos()
	var next
	var collision = false
	while distance > 0 && power > 0:
		distance -= 1
		next = landed + dir
		if terrain.atv(next) == '#':
			if !self.player:
				combatLog.say("The {0} collides with the wall.".format([self.label]))
			else:
				combatLog.say("You collide with the wall.".format([self.label]))				
			collision = true
			break
		var blockers = locationService.lookup(next, constants.BLOCKER)
		if blockers.size() > 0:
			if !self.player:
				combatLog.say("The {0} collides with the {1}.".format([self.label, blockers[0].label]))
			else:
				combatLog.say("You collide with the {1}.".format([self.label, blockers[0].label]))
			collision = true
			for b in blockers:
				power -= 1
				if b.blocking:
					combatLog.say("The {0} goes flying!".format([blockers[0].label]))
					b.knockback(dir, distance)
					break
				elif	 b.is_in_group(constants.FURNITURE):
					combatLog.say("The {0} is destroyed.".format([b.label]))
					b.die(dir)
				elif b.player:
					b.injure()
				else:
					b.die(dir)
		landed = next
	animated_move_to(landed)
	if collision:
		if self.blocking:
			pass
		elif self.player:
			self.pc.injure()
		else:
			self.die(dir)
	update()
	
func _process(delta):
	if anim_screen_offsets.size() > 0:
		if is_zero_approx(anim_screen_offsets[0].z):
			anim_screen_offsets.pop_front()
		else:
			var speed_mult = max(1,anim_screen_offsets.size() - 2)
			var v: Vector3 = anim_screen_offsets[0]
			var v0 = v
			var dz = anim_speed * delta * speed_mult
			var z1 = max(0,v.z - dz)
			var c = z1 / v.z
			v *= Vector3(c, c, 1)
			v.z = z1
			anim_screen_offsets[0] = v
		update()

func _draw() -> void:
	var pos = get_pos()
	if pos != null:
		self.position = self.SCREEN.dungeon_to_screen(pos.x,pos.y)
		for v in anim_screen_offsets:
			 self.position += Vector2(v.x,v.y)
