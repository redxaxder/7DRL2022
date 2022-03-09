extends Mob

const block_cooldown: int = 1
var cur_block_cooldown: int = 0
const block_chance: float = 0.25
var blocking = false

func _ready():
	self.name = "knight"
	._ready()

func on_turn():
	if .pc_adjacent():
		attack()
	else:
		var next = .seek_to_player()
		set_pos(next)

func attack():
	if not self.blocking:
		if rand_range(0, 1) < block_chance and self.cur_block_cooldown == 0:
			self.combatLog.say("the knight readies his shield!")
			self.blocking = true
		else:
			self.combatLog.say("the knight stabs you!")
			self.pc.injure()
			if self.cur_block_cooldown > 0:
				self.cur_block_cooldown -= 1
				
func is_hit(dir: Vector2):
	if self.blocking:
		var v = get_pos() - pc.get_pos()
		if abs(v.x) + abs(v.y) < 1 && (pc.fatigue <= 0 || pc.rage > 0):
			emit_signal(constants.ENEMY_HIT, dir)
			self.blocking = false
			self.cur_block_cooldown = self.block_cooldown
			self.combatLog.say("the knight blocks your attack!")
			self.combatLog.say("the knight goes flying!")
			self.knockback(dir)
	else:
		.is_hit(dir)

func draw() -> void:
	var pos = get_pos()
	var t_pos = self.SCREEN.dungeon_to_screen(pos.x,pos.y)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)
	if self.blocking:
		self.modulate = Color(0, 0, 1)
	else:
		self.modulate = Color(1, 1, 1)
