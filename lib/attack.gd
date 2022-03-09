class_name Attack

var constants: Const = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()

#returns true if an attack was made
func try_attack(ls: LocationService, pos: Vector2, dir: int) -> bool:
	return false
