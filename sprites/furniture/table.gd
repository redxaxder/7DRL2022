extends Actor

class_name Table

var fallen: bool = false
var fallen_txtr = (preload("res://sprites/furniture/fallen_table.tscn").instance() as Sprite).texture

func _ready():
	self.label = "table"
	add_to_group(self.constants.FURNITURE)
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PATHING_BLOCKER)

func kick(dir: int, extra_knockback = 0) -> bool:
	if combatLog != null:
		combatLog.say("The table goes flying!")
	knockback(DIR.dir_to_vec(dir), 1000, 1 + extra_knockback)
	return true

func die(dir):
	if combatLog != null:
		combatLog.say("The table is smashed to pieces!")
	.die(dir)

func nudge(dir: int, player_opened: bool = true) -> bool:
	if combatLog != null:
		if not fallen:
			if player_opened:
				combatLog.say("You knock over the table.")
			else:
				combatLog.say("You hear a table fall over. A plate shatters loudly.")
			self.texture = fallen_txtr
			fallen = true
			var pos = get_pos()
			var target = get_pos() + DIR.dir_to_vec(dir)
			if locationService.lookup(target).size() == 0 and not terrain.is_wall(target):
				set_pos(target)
			update()
		else:
			if player_opened:
				combatLog.say("The table is stuck.")
				return false
	return true
