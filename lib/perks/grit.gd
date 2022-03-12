extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.GRIT
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Grit", "Grit II", "Grit III"]
var bonuses = [20,15,15]

func config():
	title = titles[level]
	bonus = bonuses[level]
	description = "Fatigue causes {0}% less rage decay.".format([bonus])
