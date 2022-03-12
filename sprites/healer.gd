extends Mob

const heal_damage: int = 5
const heal_cooldown: int = 3
var cur_heal_cooldown: int = 0

func _ready():
	label = "healer"
	._ready()

func on_turn():
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if cur_heal_cooldown == 0 and pc_adjacent():
		cur_heal_cooldown = heal_cooldown
		attack()
	else:
		cur_heal_cooldown = max(0, cur_heal_cooldown - 1)
		var next = seek_to_player(cur_heal_cooldown > 0)
		animated_move_to(next)

func attack():
	self.combatLog.say("The healer brings forth a wave of calming energy.")
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.calm(heal_damage)

func _draw() -> void:
	if cur_heal_cooldown == 0:
		self.modulate = constants.READY_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
