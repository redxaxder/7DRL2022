extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, _terrain: Terrain = null) -> bool:
	var attacked = false
	var forward = pos + DIR.dir_to_vec(dir)
	var left = flip(DIR.rot(dir))
	var leftv = DIR.dir_to_vec(left)
	var right = DIR.invert(left)
	var rightv = DIR.dir_to_vec(right)
	var targets = [\
		forward, \
		forward + leftv , \
		forward + rightv , \
		forward + (2 * leftv), \
		forward + (2 * rightv), \
		]
	var dirs = [dir, left, right, left, right]
	for i in targets.size():
		attacked = .try_attack_at(ls, targets[i], dirs[i], anim_delay)
		if attacked:
			spawn_indicator(targets[i])
			break
	return attacked
