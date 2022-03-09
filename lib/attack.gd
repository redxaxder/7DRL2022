class_name Attack

var constants: Const = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()

#returns true if an attack was made
func try_attack(ls: LocationService, pos: Vector2, dir: int):
	var attacked = false
	var d = DIR.dir_to_vec(dir)
	var target = pos + d
	var mobs = ls.lookup(target, constants.MOBS)
	for m in mobs:
		m.is_hit(d)
		attacked = true
	return attacked
