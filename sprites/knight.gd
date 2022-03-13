extends Mob

const block_cooldown: int = 1
var cur_block_cooldown: int = 0
const max_block_chance: float = 0.40

func _ready():
	label = "knight"
	._ready()

func on_turn():
	if self.cur_block_cooldown > 0:
		self.cur_block_cooldown -= 1
	# chance to block increases linearly with proximity to player
	var pos = self.get_pos()
	var distance = pc_dijkstra.d_score(pos)
	if distance == null || distance <= 0:
		distance = 100000
	var block_chance: float = 1.0 / float(distance) * max_block_chance
	if rand_range(0, 1) < block_chance and self.cur_block_cooldown == 0:
		self.combatLog.say("The knight readies his shield!", 20)
		block()
		self.cur_block_duration = 0
	elif .pc_adjacent():
		attack()
	else:
		var next = .seek_to_player()
		animated_move_to(next)
	.on_turn()

func attack():
	self.combatLog.say("The knight stabs you!")
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.injure()
