class_name Attack

var constants = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()
var parent: Node

var attack_indicator: PackedScene = preload("res://sprites/attack_indicator.tscn")
var southpaw = false
var extra_knockback: int = 0

#returns true if an attack was made
func try_attack(_ls: LocationService, _pos: Vector2, _dir: int, anim_delay: float, _terr = null) -> bool:
	return false

func try_attack_at(ls: LocationService, target: Vector2, dir: int, anim_delay: float, terr = null) -> bool:
	return try_attack_with_log_at(ls, target, dir, anim_delay, terr)

func try_attack_with_log_at(ls: LocationService, target: Vector2, dir: int, anim_delay: float, _terr = null, message: String = "", combatLog = null) -> bool:
	var attacked = false
	var mobs = ls.lookup(target, constants.MOBS)
	var d = DIR.dir_to_vec(dir)
	for m in mobs:
		m.animation_delay(anim_delay)
		if combatLog != null && message != "":
			combatLog.say(message.format([m.label]))
		m.is_hit(d, extra_knockback)
		attacked = true
	return attacked

# reverses the argument direction if southpaw
func flip(dir: int) -> int:
	if southpaw:
		return DIR.invert(dir)
	else:
		return dir

func spawn_indicator(target: Vector2):
	AttackIndicator.new(parent, target)

func xor(l: bool, r: bool) -> bool:
	return	(l && !r) || (!l && r)
