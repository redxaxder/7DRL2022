extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, _terrain: Terrain = null) -> bool:
	var attacked = false
	var d = DIR.dir_to_vec(dir)
	var target = pos + d
	return try_attack_at(ls, target, dir, anim_delay)
