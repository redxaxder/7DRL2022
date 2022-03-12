extends Attack

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, terrain: Terrain = null) -> bool:
	if terrain == null:
		return false
	var attacked = false
	var forward = pos + DIR.dir_to_vec(dir)
	var left = flip(DIR.rot(dir))
	var leftv = DIR.dir_to_vec(left)
	var right = DIR.invert(left)
	var rightv = DIR.dir_to_vec(right)
	var target

	#forward
	target = forward
	attacked = .try_attack_at(ls, target, dir, anim_delay)
	if attacked:
		spawn_indicator(target)
		return attacked
	if ls.lookup(target, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(target):
		return attacked
	#left1
	target = forward + leftv
	attacked = .try_attack_at(ls, target, left, anim_delay)
	if attacked:
		spawn_indicator(target)
		return attacked
	#right1
	target = forward + rightv
	attacked = .try_attack_at(ls, target, right, anim_delay)
	if attacked:
		spawn_indicator(target)
		return attacked
	#left2
	target = forward + (2 * leftv)
	if !(ls.lookup(forward + leftv, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(forward + leftv)):
		attacked = .try_attack_at(ls, target, left, anim_delay)
		if attacked:
			spawn_indicator(target)
			return attacked
	#right2
	target = forward + (2 * rightv)
	if !(ls.lookup(forward + rightv, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(forward + rightv)):
		attacked = .try_attack_at(ls, target, right, anim_delay)
		if attacked:
			spawn_indicator(target)
			return attacked
	return attacked
#
#		if ls.lookup(target, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(target):
#			break
