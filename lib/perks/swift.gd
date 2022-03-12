extends Perk

var bonus: int

func _init():
	perk_type = PERK_TYPE.SWIFT
	config()

func evolve_perk() -> bool:
	if level >= 2:
		return false
	level += 1
	config()
	return true

var titles = ["Swift", "Swift II", "Swift III"]
func config():
	title = titles[level]
	bonus = 1
	description = "Increase maximum running speed by 1."
	if level == 2:
		bonus = 100
		description = "You can no longer be afflicted with the 'limping' effect."
