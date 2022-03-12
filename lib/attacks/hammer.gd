extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, _terrain: Terrain = null) -> bool:
	var attacked = false
	var d = DIR.dir_to_vec(dir)
	var target = pos + d
	var mobs = ls.lookup(target, constants.MOBS)
	for m in mobs:
		m.animation_delay(anim_delay)
		m.knockback(d, 1000,1 + extra_knockback)
		attacked = true
	if attacked:
		spawn_indicator(target)
	return attacked

