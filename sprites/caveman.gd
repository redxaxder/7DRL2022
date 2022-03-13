extends Mob

const mutter_chance: float = 0.05

func _ready():
	label = "caveman"
	._ready()

func on_turn():
	if rand_range(0, 1) < mutter_chance:
		combatLog.say("\"Ooga booga?\"",5)
	if pc_adjacent():
		attack()
	else:
		animated_move_to(seek_to_player())

func attack():
	combatLog.say("The caveman swings his club!")
	pc.injure()
