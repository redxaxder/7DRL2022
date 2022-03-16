extends Attack

var indicator_step: float = 0.017

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, _terrain: Terrain = null) -> bool:
	var attacked = false
	var swing_dir = flip(DIR.rot(dir))
	var opposite_dir = DIR.invert(swing_dir)
	var v0 = DIR.dir_to_vec(opposite_dir) + DIR.dir_to_vec(dir)
	var v1 = v0 + DIR.dir_to_vec(swing_dir)
	var v2 = v1 + DIR.dir_to_vec(swing_dir)
	var targets = []
	for v in [v0,v1,v2]:
		var target = pos + v
		targets.append(target)
		attacked = try_attack_at(ls, target, swing_dir, anim_delay) || attacked
	if attacked:
		var indicator_delay = 0
		for t in targets:
			spawn_indicator(t, anim_delay + indicator_delay)
			indicator_delay += indicator_step
	return attacked
