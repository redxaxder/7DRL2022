extends Actor

class_name Door

signal door_opened(pos)

func _ready():
	self.door = true
	add_to_group(self.constants.FURNITURE)
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PROJECTILE_BLOCKER)

func kick(dir: int) -> bool:
	combatLog.say("The door goes flying!")
	knockback(DIR.dir_to_vec(dir))
	combatLog.say("The door is smashed to pieces!")
	die(Vector2(0,0))
	return true

func nudge(_dir: int) -> bool:
	combatLog.say("You cautiously open the door.")
	die(Vector2(0,0))
	return true

func die(dir: Vector2):
	emit_signal("door_opened",get_pos())
	.die(dir)
