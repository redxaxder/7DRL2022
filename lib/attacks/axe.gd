extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, _terrain: Terrain = null) -> bool:
	var attacked = false
	var forward = dir
	var circle = flip(DIR.rot(dir))
	var back = DIR.invert(dir)
	var uncircle = DIR.invert(circle)
	var path = [ \
		forward, \
		circle, \
		back, \
		back, \
		uncircle, \
		uncircle, \
		forward, \
		forward, \
		]
	var t = pos
	for d in path:
		t += DIR.dir_to_vec(d)
		attacked = .try_attack_at(ls, t, d, anim_delay) || attacked
	return attacked
