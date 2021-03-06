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
	add_to_group(Const.FLAMMABLE)
	self.flammability = 0.5

func kick(dir: int, extra_knockback = 0) -> bool:
	if combatLog != null:
		combatLog.say("The door goes flying!")
	knockback(DIR.dir_to_vec(dir), 1000, 1 + extra_knockback)
	emit_signal("door_opened",get_pos())
	return true

func die(dir):
	emit_signal("door_opened",get_pos())
	.die(dir)

func nudge(_dir: int, player_opened: bool = true) -> bool:
	if combatLog != null:
		if player_opened:
			combatLog.say("You cautiously open the door.")
		else:
			combatLog.say("You hear a door open.")
	die(Vector2(0,0))
	return true
