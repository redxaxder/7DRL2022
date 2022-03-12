extends Mob

const mutter_chance: float = 0.2
const wander_chance: float = 0.5

signal you_win()

func _ready():
	label = "His Highness"
	self.speed = 3
	._ready()

func door_adjacent():
	var e = get_pos()
	var candidates = [Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	var final_candidates = []
	for c in candidates:
		var targets = self.locationService.lookup(c)
		if targets != null:
			for t in targets:
				if t.label == "door":
					final_candidates.push_back(t)
	final_candidates.shuffle()
	return final_candidates.pop_back()
	
func wander_to_door():
	if rand_range(0, 1) < mutter_chance:
		combatLog.say("Guards! Guards!")
	# find the smallest direction in the d_map
	var e = get_pos()
	var best_val = self.wander_dijkstra.d_score(e)
	var candidates = [e, Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1), Vector2(e.x + 1, e.y + 1), Vector2(e.x + 1, e.y - 1), Vector2(e.x - 1, e.y + 1), Vector2(e.x - 1, e.y - 1)]
	for c in candidates:
		var t = self.wander_dijkstra.d_score(c)
		if t:
			best_val = min(best_val, t)

	var legal_candidates = []
	for c in candidates:
		if self.locationService.lookup(c, constants.BLOCKER).size() == 0:
			if !terrain.is_wall(c):
				legal_candidates.append(c)
	if legal_candidates.size() == 0:
		return get_pos()
		
	if rand_range(0, 1) < wander_chance:
		legal_candidates.shuffle()
		return legal_candidates.pop_back()
		
	var final_candidates = []
	for c in legal_candidates:
		if pc_dijkstra.d_score(c) == best_val:
			final_candidates.append(c)

	if final_candidates.size() == 0:
		final_candidates = legal_candidates

	return final_candidates[randi() % final_candidates.size()]

func on_turn():
	var maybe_door = door_adjacent()
	if .pc_adjacent():
		attack()
	elif maybe_door != null:
		maybe_door.nudge(0, false)
	else:
		set_pos(wander_to_door())

func attack():
	combatLog.say("His Highness strikes you with his sceptre.")
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.injure()

func die(dir: Vector2):
	emit_signal("you_win")
