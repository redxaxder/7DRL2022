extends Mob

const shot_range: int = 6
var summon: bool = true

signal valkyrie_summon(targets)

func _ready():
	label = "valkyrie"
	tiebreaker = 80
	._ready()

func on_turn():
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if summon and dist > shot_range:
		animated_move_to(self.seek_to_player())
	elif summon and dist <= shot_range:
		summon = false
		var ppos = pc.get_pos()
		# target a 2-ball around the player
		var targets = [
			# distance 1
			ppos + Vector2(1, 0),
			ppos + Vector2(-1, 0),
			ppos + Vector2(0, 1),
			ppos + Vector2(0, -1),
			# distance 2
			ppos + Vector2(1, 1),
			ppos + Vector2(1, -1),
			ppos + Vector2(-1, 1),
			ppos + Vector2(-1, -1),
			ppos + Vector2(2, 0),
			ppos + Vector2(-2, 0),
			ppos + Vector2(0, 2),
			ppos + Vector2(0, -2),
		]
		combatLog.say("\"Come, my einherjar!\"")
		combatLog.say("Several foes appear!")
		emit_signal("valkyrie_summon", targets)
	elif not summon:
		if pc_adjacent():
			attack()
		else:
			animated_move_to(self.seek_to_player())

func attack():
	combatLog.say("The valkyrie stabs with her spear!")
	pc.injure()

func _draw() -> void:
	if summon:
		self.modulate = constants.READY_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
