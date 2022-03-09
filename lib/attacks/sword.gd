extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, _terrain: Terrain = null) -> bool:
	var attacked = false
	attacked = .try_attack(ls, pos, dir)
	if attacked:
		return true
	var forward = pos + DIR.dir_to_vec(dir)
	for b in [true, false]:
		var dir2 = flip(DIR.rot(dir))
		attacked = .try_attack(ls, forward, dir2)
		if attacked:
			return true
	return false
