extends Mob

class_name Door

func _ready():
	self.door = true
	add_to_group(self.constants.BLOCKER)
	remove_from_group(self.constants.MOBS)
