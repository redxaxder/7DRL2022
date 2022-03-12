extends Actor

class_name Chair

func _ready():
	self.label = "chair"
	add_to_group(self.constants.FURNITURE)
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PATHING_BLOCKER)

func kick(dir: int, extra_knockback = 0) -> bool:
	if combatLog != null:
		combatLog.say("The chair goes flying!")
	knockback(DIR.dir_to_vec(dir), 1000, 1 + extra_knockback)	
	return true

func die(dir):
	if combatLog != null:
		combatLog.say("The chair is smashed to pieces!")
	.dir(dir)

func nudge(dir: int, player_opened: bool = true) -> bool:
	if combatLog != null:
		if player_opened:
			combatLog.say("You move the chair out of the way.")
		else:
			combatLog.say("You hear the sound of furniture being moved.")
		var pos = get_pos()
		var target = get_pos() + DIR.dir_to_vec(dir)
		if locationService.lookup(target).size() == 0 and not terrain.is_wall(target):
			set_pos(target)
		else:
			combatLog.say("But there's something in the way!")
		update()
	return true
