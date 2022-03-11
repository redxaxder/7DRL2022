extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, _terrain: Terrain = null) -> bool:
	var attacked = false
	var v = DIR.dir_to_vec(dir)
	var target = pos
	for _i in 3:
		target += v
		attacked = .try_attack_at(ls, target, dir) || attacked
		if ls.lookup(target, constants.STOPS_ATTACK).size() > 0:
			return attacked
	return attacked
