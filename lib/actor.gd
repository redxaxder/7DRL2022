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

var knocked_back: bool = false
var prev_screen_position: Vector2
var anim_screen_position: Vector2
var anim_speed: float = 0.05
var anim_ticks: int = 0


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
	
func knockback(dir: Vector2, distance: int = 1000000, power = 1):
	var landed = get_pos()
	var next
	var collision = false
	knocked_back = true
	prev_screen_position = self.SCREEN.dungeon_to_screen(landed.x, landed.y)
	anim_screen_position = prev_screen_position
	while distance > 0 && power > 0:
		distance -= 1
		next = landed + dir
		if terrain.atv(next) == '#':
			combatLog.say("The {0} collides with the wall.".format([self.label]))
			collision = true
			break
		var blockers = locationService.lookup(next, constants.BLOCKER)
		if blockers.size() > 0:
			combatLog.say("The {0} collides with the {1}.".format([self.label, blockers[0].label]))
			collision = true
			for b in blockers:
				power -= 1
				if b.blocking:
					combatLog.say("The {0} goes flying!".format([blockers[0].label]))
					b.knockback(dir, distance)
					break
				elif b.player:
					b.injure()
				else:
					b.die(dir)
		landed = next
	set_pos(landed)
	anim_ticks = (landed - prev_screen_position).length() * anim_speed
	if collision:
		if self.blocking:
			pass
		elif self.player:
			self.pc.injure()
		else:
			self.die(dir)
	update()
	
func _process(delta):
	if knocked_back:
		update()

func _draw() -> void:
	var pos = get_pos()
	if pos != null:
		var t_pos = self.SCREEN.dungeon_to_screen(pos.x,pos.y)
		if knocked_back and not is_zero_approx((t_pos - prev_screen_position).length()):
			var dir = t_pos - prev_screen_position
			var new_position = position + dir * anim_speed
			self.position = new_position
			anim_ticks -= 1
			if anim_ticks <= 0:
				self.position = t_pos
				knocked_back = false
				combatLog.say("Thud!")
		else:
			self.position.x = float(t_pos.x)
			self.position.y = float(t_pos.y)
