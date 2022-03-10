extends Actor

class_name Door

func _ready():
	self.door = true
	add_to_group(self.constants.FURNITURE)
	add_to_group(self.constants.BLOCKER)
	add_to_group(self.constants.PROJECTILE_BLOCKER)
