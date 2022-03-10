extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.ENDURANCE
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Endurance", "Endurance II", "Endurance III"]
func config():
	title = titles[level]
	bonus = 1
	description = "After rage ends, gain {0} additional recovery.".format([bonus])
