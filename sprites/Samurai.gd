extends Mob

const dash_cooldown: int = 5
var cur_dash_cooldown: int = 0
const dash_distance: int = 5

func _ready():
	self.label = "samurai"
	._ready()

func on_turn():
	var pos = self.get_pos()
	var dir: Vector2 = self.pc.get_pos() - pos
	if cur_dash_cooldown > 0:
		cur_dash_cooldown -= 1
	if .pc_adjacent():
		attack()
	elif cur_dash_cooldown == 0 and (dir.x == 0 or dir.y ==0) and dir.length() <= dash_distance:
		# check if player is on te same line (and not in another room)
		var step: Vector2 = dir.normalized()
		var cursor: Vector2 = pos
		while true:
			cursor += step
			if self.terrain.is_wall(cursor):
				# hit a wall before player
				break
			else:
				var stuff_at = self.locationService.lookup(cursor, constants.PLAYER)
				for player in stuff_at:
					var target_tile = cursor - step
					var blockers = locationService.lookup(target_tile, constants.BLOCKER)
					if blockers.size() == 0 && !terrain.is_wall(target_tile):
						dash_attack(target_tile)
					return
	else:
		var next = .seek_to_player()
		animated_move_to(next)

func attack():
	self.combatLog.say("The samurai slashes with his katana!")
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.injure()
			
func dash_attack(pos: Vector2):
	self.combatLog.say("The samurai dashes at you with blinding speed!")
	self.combatLog.say("Before you can even blink, you feel the bite of his katana.")
	self.cur_dash_cooldown = dash_cooldown
	self.animated_move_to(pos)
	self.pc.injure()
