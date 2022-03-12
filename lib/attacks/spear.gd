extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, terrain: Terrain = null) -> bool:
	var attacked = false
	if terrain == null:
		return false
	var v = DIR.dir_to_vec(dir)
	var target = pos
	for _i in 3:
		target += v
		attacked = .try_attack_at(ls, target, dir, anim_delay)
		if attacked:
			spawn_indicator(target)
			break
		if ls.lookup(target, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(target):
			break
	return attacked
