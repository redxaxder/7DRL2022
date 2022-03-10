extends Actor

class_name Mob

signal enemy_hit(dir)
signal killed_by_pc(label)

func _ready():
	randomize()
	add_to_group(constants.MOBS)
	add_to_group(constants.BLOCKER)
	add_to_group(constants.PROJECTILE_BLOCKER)
	connect(constants.ENEMY_HIT, pc, constants.ENEMY_HIT)

func pc_adjacent() -> bool:
	var v = get_pos() - pc.get_pos()
	return (abs(v.x) + abs(v.y) <= 1)
	
func is_hit(dir: Vector2):
	emit_signal(constants.ENEMY_HIT, dir)
	die(dir)

func seek_to_player() -> Vector2:
	# find the smallest direction in the d_map
	var e = get_pos()
	var smallest_val = terrain.d_score(e)
	var candidates = [Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	for c in candidates:
		var t = terrain.d_score(c)
		if t:
			smallest_val = min(smallest_val, t)

	var legal_candidates = []
	for c in candidates:
		if self.locationService.lookup(c, constants.BLOCKER).size() == 0:
			if terrain.atv(c) != '#':
				legal_candidates.append(c)
	if legal_candidates.size() == 0:
		return get_pos()

	var final_candidates = []
	for c in legal_candidates:
		if terrain.d_score(c) == smallest_val:
			final_candidates.append(c)

	if final_candidates.size() == 0:
		final_candidates = legal_candidates

	return final_candidates[randi() % final_candidates.size()]


