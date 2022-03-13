extends Mob

const mutter_chance: float = 0.05
const wander_chance: float = 0.5

func _ready():
	label = "archaeologist"
	self.speed = 1
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
		combatLog.say("You hear someone muttering about artifacts.", 5)
	# find the smallest direction in the d_map
	var e = get_pos()
	var best_val = self.wander_dijkstra.d_score(e)
	var candidates = [e, Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
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
	.on_turn()

func attack():
	combatLog.say("The archaeologist bashes you with a trowel!")
	AttackIndicator.new(terrain, pc.get_pos(), self.pending_animation() / anim_speed)
	self.pc.injure()
