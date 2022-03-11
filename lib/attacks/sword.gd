extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, _terrain: Terrain = null) -> bool:
	var attacked = false
	var forward = pos + DIR.dir_to_vec(dir)
	attacked = .try_attack_at(ls, forward, dir, anim_delay)
	var dir2 = flip(DIR.rot(dir))
	if !attacked:
		var side = forward + DIR.dir_to_vec(dir2)
		attacked = .try_attack_at(ls, side, dir2, anim_delay)
	var dir3 = DIR.invert(dir2)
	if !attacked:
		var side = forward + DIR.dir_to_vec(dir3)
		attacked = .try_attack_at(ls, side, dir3, anim_delay)
	return attacked
