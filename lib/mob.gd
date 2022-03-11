extends Actor

class_name Mob

var pc_dijkstra: Dijkstra

signal killed_by_pc(label)

func _ready():
	randomize()
	add_to_group(self.constants.MOBS)
	add_to_group(constants.BLOCKER)
	add_to_group(constants.PROJECTILE_BLOCKER)
	add_to_group(constants.BLOODBAG)

func pc_adjacent() -> bool:
	var v = get_pos() - pc.get_pos()
	return (abs(v.x) + abs(v.y) <= 1)
	
func is_hit(dir: Vector2):
	die(dir)

func seek_to_player(run_away: bool = false) -> Vector2:
	# find the smallest direction in the d_map
	var e = get_pos()
	var best_val = pc_dijkstra.d_score(e)
	var candidates = [e, Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	var scores = []
	for c in candidates:
		var t = pc_dijkstra.d_score(c)
		scores.append(t)
		if t:
			if run_away:
				best_val = max(best_val, t)
			else:
				best_val = min(best_val, t)

	var legal_candidates = []
	for c in candidates:
		if self.locationService.lookup(c, constants.BLOCKER).size() == 0:
			if !terrain.is_wall(c):
				legal_candidates.append(c)
	if legal_candidates.size() == 0:
		return get_pos()

	var final_candidates = []
	for c in legal_candidates:
		if pc_dijkstra.d_score(c) == best_val:
			final_candidates.append(c)

	if final_candidates.size() == 0:
		final_candidates = legal_candidates

	return final_candidates[randi() % final_candidates.size()]


