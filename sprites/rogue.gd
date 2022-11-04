extends Mob


const sneak_cooldown_flat: int = 20
const sneak_cooldown_rand: int = 4
const sneak_duration_flat: int = 3
const sneak_duration_rand: int = 3
var cur_sneak_duration: int = 0
var cur_sneak_cooldown:int = 0
var sneak_location: Vector2

func _ready():
	label = "rogue"
	tiebreaker = 75
	cur_sneak_cooldown = randi() % (sneak_cooldown_flat + sneak_cooldown_rand)
	get_ready()
	._ready()

func on_turn():
	var dist = self.pc_dijkstra.d_score(get_pos())
	if cur_sneak_duration > 0:
		cur_sneak_duration -= 1
		if cur_sneak_duration <= 0: # surprise!
			if locationService.lookup(sneak_location, Const.BLOCKER).size() > 0 || !terrain.in_active_room(sneak_location):
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
			set_pos(Const.THE_HIDEOUT)
	elif cur_sneak_cooldown <= 0 && dist <= 8 && pc.rage > 0: #enter stealth!
		combatLog.say("You lose sight of the rogue.", 50)
		set_pos(Const.THE_HIDEOUT)
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

func attack():
	self.combatLog.say("The rogue stabs you!")
	AttackIndicator.new(terrain, pc.get_pos(), self.pending_animation())
	self.pc.injure()

func die(_dir: Vector2):
	if is_ready and not is_ragdoll:
		end_ready()
		var next: Vector2
		next = seek_to_player(true)
		if next == get_pos():
			.die(_dir)
		else:
			if is_in_group(Const.ON_FIRE):
				combatLog.say("The rogue stops, drops, and rolls!")
			else:
				combatLog.say("The rogue dodges!", 20)
			animated_move_to(next)
			$dodge.play()
	else:
		.die(_dir)
