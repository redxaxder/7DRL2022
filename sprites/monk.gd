extends Mob

const knockback_cooldown: int = 3
var cur_knockback_cooldown: int = 0
const knockback_chance: float = 0.25
const knockback_distance: int = 5

func _ready():
	label = "knight"
	._ready()

func on_turn():
	if .pc_adjacent():
		attack()
	else:
		var next = .seek_to_player()
		set_pos(next)

func attack():
	if cur_knockback_cooldown == 0 and rand_range(0, 1) < knockback_chance:
		self.combatLog.say("The monk yells something in Japanese and kicks you.")
		self.combatLog.say("You go flying!")
		self.pc.knockback(self.pc.get_pos() - get_pos(), knockback_distance)
	else:
		self.combatLog.say("The monk punches you!")
		self.pc.injure()
		if cur_knockback_cooldown > 0:
			cur_knockback_cooldown -= 1
	
func die(dir: Vector2):
	self.combatLog.say("the monk dies.")
	.die(dir)
