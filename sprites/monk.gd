extends Mob

const knockback_cooldown: int = 3
var cur_knockback_cooldown: int = 0
const knockback_chance: float = 0.25

func _ready():
	self.name = "monk"
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

func draw() -> void:
	var pos = get_pos()
	var t_pos = self.SCREEN.dungeon_to_screen(pos.x,pos.y)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)
