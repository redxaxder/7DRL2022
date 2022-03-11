extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.SECOND_WIND
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Second Wind", "Third Wind", "Windtouched"]
var bonuses = [25,15,10]
func config():
	title = titles[level]
	bonus = bonuses[level]
	description = "After gaining a perk (including this one) reduce the duration of ongoing status effects by {0}%.".format([bonus])
