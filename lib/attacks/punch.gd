extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int):
	var attacked = false
	var d = DIR.dir_to_vec(dir)
	var target = pos + d
	var mobs = ls.lookup(target, constants.MOBS)
	for m in mobs:
		m.is_hit(d)
		print("you punch")
		attacked = true
	return attacked
