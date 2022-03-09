extends Mob

const knockback_cooldown: int = 3
var cur_knockback_cooldown: int = 0
const knockback_chance: float = 0.25

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
	#monk stuff i dunno
	pass
				
func is_hit(dir: Vector2):
	# todo after we redo targetting
	pass
	
func die():
	self.combatLog.say("the monk dies.")
	.die()
