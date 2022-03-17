extends Actor

class_name Table

var fallen: bool = false
var fallen_inst = preload("res://sprites/furniture/fallen_table.tscn").instance() as Sprite

func _ready():
	self.label = "table"
	add_to_group(self.constants.FURNITURE)
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PATHING_BLOCKER)
	add_child(fallen_inst)
	fallen_inst.visible = false
	thump_node = thump_scene.instance()
	add_child(thump_node)


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
			self.texture = fallen_inst.texture
			fallen = true
			thump_node.play()
			var pos = get_pos()
			var target = get_pos() + DIR.dir_to_vec(dir)
			if locationService.lookup(target).size() == 0 and not terrain.is_wall(target):
				animated_move_to(target)
			update()
		else:
			if player_opened:
				combatLog.say("The table is stuck.")
				return false
	return true
