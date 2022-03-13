extends Attack

var combatLog = null
var message = ""
var sprite: Sprite = null
const fireball_sprite: PackedScene = preload("res://sprites/fireball.tscn")

func try_attack(ls: LocationService, pos: Vector2, dir: int, anim_delay: float, terrain = null) -> bool:
	if terrain == null:
		return false
	var did_attack = false
	var v = DIR.dir_to_vec(dir)
	var target = pos
	while !did_attack: #scan down the line
		target += v
		did_attack = .try_attack_with_log_at(ls, target, dir, anim_delay, terrain, message, combatLog)
		if terrain.at(target.x, target.y) == '#':
			break;
		if ls.lookup(target, constants.PROJECTILE_BLOCKER).size() > 0:
			break;
	if did_attack && sprite != null:
		# this is dumb but the sane ways didnt work for mysterious reasons
		var projectile: Sprite = fireball_sprite.instance()
		projectile.texture = sprite.texture
		projectile.modulate = sprite.modulate
		projectile.self_modulate = sprite.self_modulate
		terrain.add_child(Projectile.new(25, pos, target, projectile))
	return did_attack
