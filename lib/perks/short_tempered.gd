extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.SHORT_TEMPERED
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Short Tempered", "Quick Tempered", "Hot Tempered"]
func config():
	title = titles[level]
	bonus = 10 * (level + 1)
	description = "On entering rage, gain {0} additional rage.".format([bonus])
