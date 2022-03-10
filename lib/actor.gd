extends Sprite

class_name Actor
signal deschedule(actor)

var constants = preload("res://lib/const.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()

var terrain: Terrain
var combatLog: CombatLog
var locationService: LocationService
var pc

var player: bool = false
var speed: int = 3
var label: String = ""
var door: bool = false
var knight: bool = false

func try_move(i,j) -> bool:
	var pos = Vector2(i,j)
	var blockers = locationService.lookup(pos, constants.BLOCKER)
	if terrain.at(i,j) == '#':
		return false
	elif blockers.size() > 0:
		if blockers.size() == 1 && blockers[0].door:
			var d = blockers[0]
			if player:
				if self.rage > 0:
					d.knockback(d.get_pos() - get_pos())
					combatLog.say("the door goes flying!")
					combatLog.say("the door is smashed to pieces!")
				else:
					combatLog.say("you cautiously open the door.")
				d.die()
				return true
		return false
	else:
		set_pos(pos)
		if player:
			terrain.update_dijkstra_map([pos])
		position = self.SCREEN.dungeon_to_screen(pos.x ,pos.y)
		return true

func get_pos(default = null) -> Vector2:
	return locationService.lookup_backward(self, default)

func set_pos(p: Vector2):
	locationService.insert(self,p)

func die():
	if is_in_group(self.constants.MOBS):
		emit_signal(constants.DESCHEDULE, self)
	self.locationService.delete_node(self)
	#TODO: handle if it was killed by someone else (eg: wizard)
	emit_signal(constants.KILLED_BY_PC, label)
	queue_free()
	
func knockback(dir: Vector2, distance: int = -1):
	var pos = get_pos()
	var i: int = pos.x + dir.x
	var j: int = pos.y + dir.y
	var mobs_at = locationService.lookup(Vector2(i, j), constants.MOBS)
	var obstacles_at = locationService.lookup(Vector2(i, j), constants.BLOCKER)
	for m in mobs_at:
		if m.knight and m.blocking:
			m.knockback(dir)
		else:
			m.die()
	for o in obstacles_at:
		o.die()
	if mobs_at.size() > 0 or obstacles_at.size() > 0:
		if not (self.knight and self.blocking):
			if not self.player:
				self.die()
		else:
			return
	if try_move(i, j) and abs(distance) > 0:
		knockback(dir, distance - 1)
	elif self.player:
		self.pc.injure()
