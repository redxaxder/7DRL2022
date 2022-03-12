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
	var targets = [\
		forward, \
		forward + leftv , \
		forward + (2 * leftv), \
		forward + rightv , \
		forward + (2 * rightv), \
		]
	var dirs = [dir, left, right, left, right]

	#forward
	attacked = .try_attack_at(ls, targets[0], dirs[0], anim_delay)
	if attacked:
		spawn_indicator(targets[0])
		return attacked
	if ls.lookup(targets[0], constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(targets[0]):
		return attacked
	#left1
	attacked = .try_attack_at(ls, targets[1], dirs[1], anim_delay)
	if attacked:
		spawn_indicator(targets[1])
		return attacked
	#right1
	attacked = .try_attack_at(ls, targets[2], dirs[2], anim_delay)
	if attacked:
		spawn_indicator(targets[2])
		return attacked
	#left2
	if !(ls.lookup(targets[1], constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(targets[1])):
		attacked = .try_attack_at(ls, targets[3], dirs[3], anim_delay)
		if attacked:
			spawn_indicator(targets[3])
			return attacked
	#right2
	if !(ls.lookup(targets[2], constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(targets[2])):
		attacked = .try_attack_at(ls, targets[4], dirs[4], anim_delay)
		if attacked:
			spawn_indicator(targets[4])
			return attacked
	return attacked
#
#		if ls.lookup(target, constants.STOPS_ATTACK).size() > 0 || terrain.is_wall(target):
#			break
