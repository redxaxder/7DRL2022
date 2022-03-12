extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.OVERRUN
	config()

func evolve_perk() -> bool:
	return false

func config():
	title = "Overrun"
	description = "Break into a run after attacking."
