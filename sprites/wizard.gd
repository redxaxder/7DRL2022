extends Mob

var telegraph_timer: int = 2
const telegraph_duration: int = 2
var telegraphing: bool = false
var cur_shot_cooldown: int = 0
const shot_cooldown: int = 3
const shot_range: int = 5

const mutter_chance: float = 0.01

func _ready():
	label = "wizard"
	._ready()
	
func check_alignment():
	var alignment = get_pos() - pc.get_pos()
	return alignment.x == 0 or alignment.y == 0
	
func on_turn():
	if rand_range(0, 1) < mutter_chance:
		combatLog.say("You hear snatches of drunken spellcasting.")
	var pos = self.get_pos()
	var dist = self.ortho_dijkstra.d_score(pos)
	var aligned: bool = check_alignment()
	if dist > shot_range or not aligned:
		set_pos(self.seek_to_player(false, true))
		cur_shot_cooldown = max(0, cur_shot_cooldown - 1)
	if dist <= shot_range and aligned and not telegraphing:
		# run away
		if cur_shot_cooldown > 0:
			cur_shot_cooldown -= 1
			set_pos(self.seek_to_player(true, false))
		# shoot
		else:
			combatLog.say("The wizard begins chanting.",20)
			telegraphing = true
			telegraph_timer = telegraph_duration
	if telegraphing:
		if telegraph_timer > 0:
			telegraph_timer -= 1
		else:
			attack()

func attack():
	telegraphing = false
	combatLog.say("A fireball erupts from the wizard's fingers!", 20)
	var aligned = check_alignment()
	var dist = self.ortho_dijkstra.d_score(get_pos())
	if aligned and dist <= shot_range:
		combatLog.say("The fireball slams into you!")
		pc.injure()
	else:
		combatLog.say("The fireball misses.",  20)

func _draw() -> void:
	if telegraphing:
		self.modulate = Color(0.75, 0.421875, 0)
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
