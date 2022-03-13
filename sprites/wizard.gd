extends Mob

var telegraph_timer: int = 2
const telegraph_duration: int = 2
var telegraphing: bool = false
var cur_shot_cooldown: int = 0
const shot_cooldown: int = 2
const shot_range: int = 6
var shot_dir: Vector2

const mutter_chance: float = 0.05

func _ready():
	label = "wizard"
	._ready()

func check_alignment():
	var alignment = get_pos() - pc.get_pos()
	return alignment.x == 0 or alignment.y == 0

func on_turn():
	if rand_range(0, 1) < mutter_chance:
		combatLog.say("You hear snatches of drunken spellcasting.", 10)
	var pos = self.get_pos()
	var dist = self.pc_dijkstra.d_score(pos)
	var aligned: bool = check_alignment()
	if telegraphing:
		if telegraph_timer > 0:
			telegraph_timer -= 1
		else:
			attack()
	elif dist > shot_range or not aligned:
		animated_move_to(self.seek_to_player(false, true))
		cur_shot_cooldown = max(0, cur_shot_cooldown - 1)
	elif dist <= shot_range and aligned:
		# run away
		if cur_shot_cooldown > 0:
			cur_shot_cooldown -= 1
			animated_move_to(self.seek_to_player(true, false))
		# shoot
		else:
			# march to see if we have a clear shot
			var ppos = pc.get_pos()
			#march the fireball until it hits something
			var target = pos + shot_dir
			var cont = true
			var clear_shot = true
			shot_dir = (pc.get_pos() - pos).normalized()
			while cont:
				var stuff_at = locationService.lookup(target)
				for thing in stuff_at:
					if thing.is_in_group(constants.FURNITURE) or thing.is_in_group(constants.MOBS):
						cont = false
						clear_shot = false
				if terrain.is_wall(target):
					cont = false
					clear_shot = false
				if target == ppos:
					cont = false
				target += shot_dir
			if clear_shot:
				combatLog.say("The wizard begins chanting.",20)
				telegraphing = true
				telegraph_timer = telegraph_duration
			else:
				animated_move_to(self.seek_to_player(false, true))

func attack():
	telegraphing = false
	combatLog.say("A fireball erupts from the wizard's fingers!", 20)
	var aligned = check_alignment()
	var dist = self.ortho_dijkstra.d_score(get_pos())
	var pos = get_pos()
	var ppos = pc.get_pos()
	#march the fireball until it hits something
	var target = pos + shot_dir
	var cont = true
	while cont:
		var stuff_at = locationService.lookup(target)
		if target == ppos:
			# hit the player
			combatLog.say("The fireball slams into you!")
			pc.injure()
			cont = false
		if stuff_at.size() > 0:
			for thing in stuff_at:
				if thing.is_in_group(constants.FURNITURE):
					combatLog.say("The {0} bursts into flames!".format([thing.label]))
					thing.die(shot_dir)
					cont = false
				if thing.is_in_group(constants.MOBS):
					if thing.blocking:
						combatLog.say("The fireball is blocked by the {0}".format([thing.label]))
						thing.knockback(shot_dir)
					else:
						combatLog.say("The {0} bursts into flames!".format([thing.label]))
						thing.die(shot_dir)
					cont = false
		if terrain.is_wall(target):
			combatLog.say("The fireball misses.", 20)
			cont = false
		target += shot_dir

func _draw() -> void:
	if telegraphing:
		self.modulate = constants.WINDUP_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
