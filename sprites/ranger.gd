extends Mob

var telegraph_timer: int = 2
const telegraph_duration: int = 2
var telegraphing: bool = false
var cur_shot_cooldown: int = 0
const shot_cooldown: int = 3
const shot_range: int = 8
var target: Vector2

signal telegraph(target)
signal remove_target(target)

func _ready():
	label = "ranger"
	._ready()

func on_turn():
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if dist <= shot_range and not telegraphing:
		# run away
		if cur_shot_cooldown > 0:
			cur_shot_cooldown -= 1
			set_pos(self.seek_to_player(true))
		# shoot
		else:
			var pp = pc.get_pos()
			var candidates = [pp, Vector2(pp.x + 1, pp.y), Vector2(pp.x, pp.y + 1), Vector2(pp.x - 1, pp.y), Vector2(pp.x, pp.y - 1)]
			candidates.shuffle()
			target = candidates.pop_back()
			telegraphing = true
			telegraph_timer = telegraph_duration
			emit_signal("telegraph", target)
	elif telegraphing:
		if telegraph_timer > 0:
			telegraph_timer -= 1
		else:
			attack()
	else:
		set_pos(seek_to_player())
		cur_shot_cooldown = max(0, cur_shot_cooldown - 1)

func attack():
	if pc.get_pos() == target:
		combatLog.say("The ranger's arrow flies true!")
		pc.injure()
		telegraphing = false
		emit_signal("remove_target", target)

func _draw() -> void:
	._draw()
