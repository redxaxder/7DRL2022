extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, _terrain: Terrain = null):
	var attacked = false
	var swing_dir = flip(DIR.rot(dir))
	var opposite_dir = DIR.invert(swing_dir)
	var v0 = DIR.dir_to_vec(opposite_dir) + DIR.dir_to_vec(dir)
	var v1 = v0 + DIR.dir_to_vec(swing_dir)
	var v2 = v1 + DIR.dir_to_vec(swing_dir)
	for v in [v0,v1,v2]:
		var target = pos + v
		attacked = try_attack_at(ls, target, swing_dir) || attacked
	return attacked
