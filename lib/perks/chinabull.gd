extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.CHINA
	config()

func evolve_perk() -> bool:
	if level >= 1:
		return false
	level += 1
	config()
	return true

var titles = ["Bull in a China Shop", "Bull in a China Shop II"]
var bonuses = [20,100]
func config():
	title = titles[level]
	bonus = bonuses[level]
	description = "While raging, you have a {0}% chance to smash nearby furniture.".format([bonus])
