extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, terrain: Terrain = null) -> bool:
	var attacked = false
	if terrain == null:
		return false
	var v = DIR.dir_to_vec(dir)
	for i in 2:
		var target = pos + (v * (i + 1))
		attacked = .try_attack_at(ls, target, dir, anim_delay) || attacked
		if ls.lookup(target, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(target):
			return attacked
	if attacked:
		for i in 2:
			spawn_indicator(pos + (v * (i+1)), anim_delay + i * 0.017)
	return attacked
