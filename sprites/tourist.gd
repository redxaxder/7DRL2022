extends Mob

const flash_damage: int = 1
const flash_range: int = 2
const flash_cooldown: int = 3
var cur_flash_cooldown: int = 0
const mutter_chance: float = 0.02

func _ready():
	label = "tourist"
	._ready()

func on_turn():
	if rand_range(0, 1) < mutter_chance:
		combatLog.say("The tourist says something loudly and slowly in his own language.")
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	if cur_flash_cooldown == 0:
		if dist <= flash_range:
			cur_flash_cooldown = flash_cooldown
			attack()
		else:
			var next = seek_to_player()
			animated_move_to(next)
	else:
		cur_flash_cooldown = max(0, cur_flash_cooldown - 1)
		var next = .seek_to_player(true)
		animated_move_to(next)

func attack():
	self.combatLog.say("A camera flash dazzles you!")
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.dazzle()

func _draw() -> void:
	if cur_flash_cooldown == 0:
		self.modulate = Color(0.501961, 0.501961, 0.027451)
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
