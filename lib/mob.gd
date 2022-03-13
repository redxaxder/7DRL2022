extends Actor

class_name Mob

var pc_dijkstra: Dijkstra
var wander_dijkstra: Dijkstra
var ortho_dijkstra: Dijkstra
var enemy_dijkstra: Dijkstra

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

func is_hit(dir: Vector2, extra_knockback = 0):
	if self.blocking:
		self.combatLog.say("The {0} blocks your attack!".format([self.label]))
		self.combatLog.say("The {0} goes flying!".format([self.label]))
		self.knockback(dir, 1000, 1 + extra_knockback)
		self.end_block()
	else:
		die(dir)

func on_turn():
	block_decay()
	if label != "priest":
		enemy_dijkstra.update([self.get_pos()])

func seek_to_player(run_away: bool = false, ortho_seek: bool = false) -> Vector2:
	if ortho_seek:
		return seek(ortho_dijkstra, run_away)
	else:
		return seek(pc_dijkstra, run_away)

func seek(d_map: Dijkstra, reverse = false) -> Vector2:
	var e = get_pos()
	var best_val = d_map.d_score(e)
	var candidates = [e, Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	var scores = []
	for c in candidates:
		var t = d_map.d_score(c)
		scores.append(t)
		if t:
			if reverse:
				best_val = max(best_val, t)
			else:
				best_val = min(best_val, t)

	var legal_candidates = []
	for c in candidates:
		if self.locationService.lookup(c, constants.BLOCKER).size() == 0:
			if not terrain.is_wall(c) and c != pc.get_pos():
				legal_candidates.append(c)
	if legal_candidates.size() == 0:
		return get_pos()

	var final_candidates = []
	for c in legal_candidates:
		if d_map.d_score(c) == best_val:
			final_candidates.append(c)

	if final_candidates.size() == 0:
		final_candidates = legal_candidates

	return final_candidates[randi() % final_candidates.size()]
