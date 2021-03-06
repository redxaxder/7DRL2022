extends Mob

const knockback_cooldown: int = 3
var cur_knockback_cooldown: int = 0
const knockback_chance: float = 0.25
const knockback_distance: int = 5

func _ready():
	label = "monk"
	tiebreaker = 85
	get_ready()
	._ready()

func on_turn():
	if .pc_adjacent():
		attack()
	else:
		var next = .seek_to_player()
		animated_move_to(next)

func attack():
	if cur_knockback_cooldown <= 0:
		self.combatLog.say("The monk yells something in Japanese and kicks you.")
		self.combatLog.say("You go flying!")
		self.pc.knockback(self.pc.get_pos() - get_pos(), knockback_distance)
		self.cur_knockback_cooldown = knockback_cooldown
		end_ready()
	else:
		self.combatLog.say("The monk punches you!")
# warning-ignore:return_value_discarded
		AttackIndicator.new(terrain, pc.get_pos(), self.pending_animation() / anim_speed)
		self.pc.injure()
		if cur_knockback_cooldown > 0:
			cur_knockback_cooldown -= 1
			if cur_knockback_cooldown <= 0:
				get_ready()
