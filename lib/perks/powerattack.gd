extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.POWER_ATTACK
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Bull Rush", "Bull Rush II", "Bull Rush III"]
func config():
	title = titles[level]
	bonus = level + 1
	if level == 2:
		bonus = 1000
	match level:
		0:
			description = "Your knockback propels objects through an additional target."
		1:
			description = "Your knockback propels objects through 2 additional targets."
		2:
			description = "Your knockback propels objects through all targets."
	
