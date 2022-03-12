extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.TEMPO
	config()

func evolve_perk() -> bool:
	if level >= 1:
		return false
	level += 1
	config()
	return true

var titles = ["Tempo", "Tempo II"]
var bonuses = [20,100]
func config():
	title = titles[level]
	bonus = bonuses[level]
	description = "Each turn, there is a {0}% chance for your first attack to not end your turn.".format([bonus])
