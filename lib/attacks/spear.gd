extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int):
	var attacked = false
	var v = DIR.dir_to_vec(dir)
	var forward = pos + v
	attacked = .try_attack(ls, pos, dir) || attacked
	attacked = .try_attack(ls, forward, dir) || attacked
	return attacked
