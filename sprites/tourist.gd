extends Mob

const flash_damage: int = 1
const flash_range: int = 3
const flash_cooldown: int = 3
var cur_flash_cooldown: int = 0
const mutter_chance: float = 0.05

func _ready():
	label = "tourist"
	tiebreaker = 70
	get_ready()
	._ready()

func on_turn():
	if rand_range(0, 1) < mutter_chance:
		combatLog.say("The tourist says something loudly and slowly in his own language.", 5)
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if cur_flash_cooldown == 0:
		if dist <= flash_range:
			cur_flash_cooldown = flash_cooldown
			end_ready()
			attack()
		else:
			var next = seek_to_player()
			animated_move_to(next)
	else:
		cur_flash_cooldown = max(0, cur_flash_cooldown - 1)
		if cur_flash_cooldown <= 0:
			get_ready()
		var next = .seek_to_player(true)
		animated_move_to(next)
	.on_turn()

func attack():
	self.combatLog.say("A camera flash dazzles you!")
	AttackIndicator.new(terrain, pc.get_pos(), self.pending_animation() / anim_speed)
	self.pc.dazzle()

func _draw() -> void:
	if cur_flash_cooldown == 0:
		self.modulate = constants.READY_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
