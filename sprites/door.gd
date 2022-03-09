extends Mob

class_name Door

func _ready():
	self.door = true
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PROJECTILE_BLOCKER)
	remove_from_group(self.constants.MOBS)
