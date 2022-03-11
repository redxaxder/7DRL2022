extends Mob

const block_cooldown: int = 1
var cur_block_cooldown: int = 0
const max_block_chance: float = 0.40
const block_duration: int = 2
var cur_block_duration: int = 0

func _ready():
	label = "knight"
	._ready()

func on_turn():
	if self.cur_block_cooldown > 0:
		self.cur_block_cooldown -= 1
	if blocking:
		if cur_block_duration < block_duration:
			cur_block_duration += 1
		else:
			blocking = false
	if not blocking:
		# chance to block increases linearly with proximity to player
		var pos = self.get_pos()
		var distance = pc_dijkstra.d_score(pos)
		if distance == null || distance <= 0:
			distance = 100000
		var block_chance: float = 1.0 / float(distance) * max_block_chance
		if rand_range(0, 1) < block_chance and self.cur_block_cooldown == 0:
#			self.combatLog.say("The knight readies his shield!")
			self.blocking = true
			self.cur_block_duration = 0
		elif .pc_adjacent():
			attack()
		else:
			var next = .seek_to_player()
			animated_move_to(next)

func attack():
	if not self.blocking:
		self.combatLog.say("The knight stabs you!")
		self.pc.injure()
				
func is_hit(dir: Vector2):
	if self.blocking:
		self.combatLog.say("The knight blocks your attack!")
		self.combatLog.say("The knight goes flying!")
		self.knockback(dir)
		self.blocking = false
		self.cur_block_cooldown = self.block_cooldown
	else:
		.is_hit(dir)

func _draw() -> void:
	if self.blocking:
		self.modulate = Color(0.460938, 0.460938, 1)
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
