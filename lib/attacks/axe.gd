extends Attack

var indicator_step = 0.017

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
	var ts = []
	for d in path:
		t += DIR.dir_to_vec(d)
		ts.append(t)
		attacked = .try_attack_at(ls, t, d, anim_delay) || attacked
	if attacked:
		var indicator_delay = 0
		for x in ts:
			spawn_indicator(x, anim_delay + indicator_delay)
			indicator_delay += indicator_step
	return attacked
