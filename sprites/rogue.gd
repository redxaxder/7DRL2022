extends Mob

var another_guy: bool = true
var revealed: bool = false

func _ready():
	label = "rogue"
	._ready()

func on_turn():
	var pos = self.get_pos()
	if .pc_adjacent():
		attack()
	else:
		var next = .seek_to_player()
		animated_move_to(next)

func attack():
	self.combatLog.say("The rogue stabs you!")
	revealed = true
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.injure()

func _draw() -> void:
	if not revealed:
		self.modulate = Color(0.269531, 0.269531, 0.269531)
	else:
		self.modulate = Color(1, 1, 1)
	._draw()

func die(_dir: Vector2):
	if another_guy and not is_ragdoll:
		another_guy = false
		revealed = true
		var next: Vector2
		next = seek_to_player(true)
		if next == get_pos():
			.die(_dir)
		else:
			combatLog.say("The rogue dodges!")
			animated_move_to(next)
	else:
		.die(_dir)
