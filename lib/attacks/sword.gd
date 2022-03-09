extends Attack

var southpaw = false

func xor(l: bool, r: bool) -> bool:
	return	(l && !r) || (!l && r)

func try_attack(ls: LocationService, pos: Vector2, dir: int):
	var attacked = false
	attacked = .try_attack(ls, pos, dir)
	if attacked:
		return true
	var forward = pos + DIR.dir_to_vec(dir)
	for b in [true, false]:
		var dir2 = DIR.rot(dir,xor(b,southpaw))
		attacked = .try_attack(ls, forward, dir2)
		if attacked:
			return true
	return false
