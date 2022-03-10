extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.VENGEANCE
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Vengeance", "Vengeance II", "Vengeance III"]
func config():
	title = titles[level]
	bonus = 3 * (level + 1)
	description = "Gain {0} additional rage when injured.".format([bonus])
