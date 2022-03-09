extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, terrain: Terrain = null) -> bool:
	if terrain == null:
		return false
	var did_attack = false
	var v = DIR.dir_to_vec(dir)
	var target = pos
	while !did_attack: #scan down the line
		target += v
		did_attack = .try_attack_at(ls, target, dir)
		if terrain.at(target.x, target.y) == '#':
			break;
		if ls.lookup(target, constants.PROJECTILE_BLOCKER).size() > 0:
			break;
	return did_attack
