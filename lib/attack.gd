class_name Attack

var constants: Const = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()
var southpaw = false

#returns true if an attack was made
func try_attack(ls: LocationService, pos: Vector2, dir: int) -> bool:
	var attacked = false
	var d = DIR.dir_to_vec(dir)
	var target = pos + d
	return try_attack_at(ls, target, dir)

func try_attack_at(ls: LocationService, target: Vector2, dir: int) -> bool:
	var attacked = false
	var mobs = ls.lookup(target, constants.MOBS)
	var d = DIR.dir_to_vec(dir)
	for m in mobs:
		m.is_hit(d)
		attacked = true
	return attacked
	

# reverses the argument direction if southpaw
func flip(dir: int) -> int:
	if southpaw:
		return DIR.invert(dir)
	else:
		return dir
	

func xor(l: bool, r: bool) -> bool:
	return	(l && !r) || (!l && r)
