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
		self.pos = next

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

func draw() -> void:
	var t_pos = self.SCREEN.dungeon_to_screen(self.pos.x,self.pos.y)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)
