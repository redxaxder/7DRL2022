extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.BLOODLUST
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Bloodlust", "Bloodlust II", "Bloodlust III"]
func config():
	title = titles[level]
	bonus = level + 1
	description = "On killing an enemy, gain {0} additional rage.".format([bonus])
