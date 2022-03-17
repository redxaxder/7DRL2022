extends Mob

const heal_damage: int = 50
const heal_cooldown: int = 0
var cur_heal_cooldown: int = 0

func _ready():
	label = "healer"
	tiebreaker = 45
	._ready()

func on_turn():
	var pos = self.get_pos()
	if cur_heal_cooldown == 0 and pc_adjacent():
		cur_heal_cooldown = heal_cooldown
		attack()
	else:
		cur_heal_cooldown = max(0, cur_heal_cooldown - 1)
		var next = seek_to_player(cur_heal_cooldown > 0)
		animated_move_to(next)
	.on_turn()

func attack():
	self.combatLog.say("The healer brings forth a wave of calming energy.")
	AttackIndicator.new(terrain, pc.get_pos(), self.pending_animation() / anim_speed)
	self.pc.calm(heal_damage)
