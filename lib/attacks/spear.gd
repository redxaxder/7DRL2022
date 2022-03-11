extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, _terrain: Terrain = null) -> bool:
	var attacked = false
	var v = DIR.dir_to_vec(dir)
	var forward = pos + v
	var forward2 = forward + v
	attacked = .try_attack_at(ls, forward, dir) || attacked
	if ls.lookup(forward, constants.STOPS_ATTACK).size() > 0:
		return attacked
	attacked = .try_attack_at(ls, forward2, dir) || attacked
	return attacked
