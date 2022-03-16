extends Mob

var telegraph_timer: int = 2
const telegraph_duration: int = 2
var telegraphing: bool = false
var cur_shot_cooldown: int = 0
const shot_cooldown: int = 3
const shot_range: int = 8
var target: Vector2
var target_obj: Object = null

const arrow_projectile_scene: PackedScene = preload("res://sprites/arrow.tscn")
signal telegraph(target)
signal remove_target(target)

func _ready():
	label = "ranger"
	speed = 6
	._ready()

func on_turn():
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if dist <= shot_range and not telegraphing:
		# run away
		if cur_shot_cooldown > 0:
			cur_shot_cooldown -= 1
			if dist < shot_range:
				animated_move_to(self.seek_to_player(true))
		# shoot
		else:
			combatLog.say("The ranger takes aim!",20)
			var pp = pc.get_pos()
			var candidates = [pp, Vector2(pp.x + 1, pp.y), Vector2(pp.x, pp.y + 1), Vector2(pp.x - 1, pp.y), Vector2(pp.x, pp.y - 1)]
			var legal_candidates = []
			for c in candidates:
				if not self.terrain.is_wall(c):
					legal_candidates.push_back(c)
			legal_candidates.shuffle()
			target = legal_candidates.pop_back()
			telegraphing = true
			telegraph_timer = telegraph_duration
			emit_signal("telegraph", target, self)
	elif telegraphing:
		if telegraph_timer > 0:
			telegraph_timer -= 1
		else:
			attack()
	else:
		animated_move_to(seek_to_player())
		cur_shot_cooldown = max(0, cur_shot_cooldown - 1)
	.on_turn()

func attack():
	telegraphing = false
	cur_shot_cooldown = shot_cooldown
	emit_signal("remove_target", target_obj)
	target_obj = null
	if pc.get_pos() == target:
		combatLog.say("The ranger's arrow flies true!")
		pc.injure()
	else:
		combatLog.say("The ranger's arrow harmlessly flies wide.",  20)
	terrain.add_child(Projectile.new(15, get_pos(), target, arrow_projectile_scene.instance(), self.pending_animation() / anim_speed))

func _draw() -> void:
	if telegraphing:
		self.modulate = constants.WINDUP_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()

func die(dir: Vector2):
	emit_signal("remove_target", target_obj)
	.die(dir)
