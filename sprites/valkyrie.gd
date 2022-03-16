extends Mob

const shot_range: int = 6

signal valkyrie_summon(targets)

func _ready():
	label = "valkyrie"
	tiebreaker = 80
	get_ready()
	._ready()

func on_turn():
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if is_ready and dist > shot_range:
		animated_move_to(self.seek_to_player())
	elif is_ready and dist <= shot_range:
		end_ready()
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
	elif not is_ready:
		if pc_adjacent():
			attack()
		else:
			animated_move_to(self.seek_to_player())

func attack():
	combatLog.say("The valkyrie stabs with her spear!")
	pc.injure()
