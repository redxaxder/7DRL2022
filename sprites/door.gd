extends Actor

class_name Door

signal door_opened(pos)

func _ready():
	self.door = true
	self.label = "door"
	add_to_group(self.constants.FURNITURE)
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PROJECTILE_BLOCKER)
	add_to_group(self.constants.PATHING_BLOCKER)
	add_to_group(self.constants.STOPS_ATTACK)

func kick(dir: int) -> bool:
	combatLog.say("The door goes flying!")
	knockback(DIR.dir_to_vec(dir))
	combatLog.say("The door is smashed to pieces!")
	return true

func nudge(_dir: int, player_opened: bool = true) -> bool:
	if player_opened:
		combatLog.say("You cautiously open the door.")
	else:
		combatLog.say("You hear a door open.")
	die(Vector2(0,0))
	return true

func die(dir: Vector2):
	emit_signal("door_opened",get_pos())
	.die(dir)
