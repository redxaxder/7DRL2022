extends Mob


const the_hideout: Vector2 = Vector2(-1000,-1000)
const sneak_cooldown_flat: int = 12
const sneak_cooldown_rand: int = 4
const sneak_duration_flat: int = 3
const sneak_duration_rand: int = 3
var cur_sneak_duration: int = 0
var cur_sneak_cooldown:int = 0
var sneak_location: Vector2

var another_guy: bool = true

func _ready():
	label = "rogue"
	cur_sneak_cooldown = randi() % (sneak_cooldown_flat + sneak_cooldown_rand) 
	._ready()

func on_turn():
	if cur_sneak_duration > 0:
		cur_sneak_duration -= 1
		if cur_sneak_duration <= 0: # surprise!
			if locationService.lookup(sneak_location, constants.BLOCKER).size() > 0:
				cur_sneak_duration = 1
			else:
				combatLog.say("A rogue steps out of the shadows.", 500)
				set_pos(sneak_location)
				self.visible = true
				self.speed = 3
				cur_sneak_cooldown = sneak_cooldown_flat + (randi() % sneak_cooldown_rand)
		else: # sneaky rogue is sneaking
			set_pos(sneak_location)
			sneak_location = seek(enemy_dijkstra, true)
			set_pos(the_hideout)
	elif cur_sneak_cooldown <= 0: #enter stealth!
		combatLog.say("You lose sight of the rogue.", 50)
		set_pos(the_hideout)
		sneak_location = pc.get_pos()
		self.visible = false
		speed = 1
		cur_sneak_duration = sneak_cooldown_flat + (randi() % sneak_cooldown_rand)
	else:  # if we're not sneaking, we're fighting
		cur_sneak_cooldown -= 1
		var pos = self.get_pos()
		if .pc_adjacent():
			attack()
		else:
			var next = .seek_to_player()
			animated_move_to(next)
		.on_turn()

func attack():
	self.combatLog.say("The rogue stabs you!")
	var x = attack_indicator.instance()
	terrain.add_child(x)
	var pos = pc.get_pos()
	x.position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	x.update()
	self.pc.injure()

func _draw() -> void:
	if another_guy:
		self.modulate = constants.READY_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()

func die(_dir: Vector2):
	if another_guy and not is_ragdoll:
		another_guy = false
		var next: Vector2
		next = seek_to_player(true)
		if next == get_pos():
			.die(_dir)
		else:
			combatLog.say("The rogue dodges!", 20)
			animated_move_to(next)
	else:
		.die(_dir)
