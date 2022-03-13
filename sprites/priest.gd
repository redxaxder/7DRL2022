extends Mob

var telegraph_timer: int = 2
const telegraph_duration: int = 2
var telegraphing: bool = false

var cur_blessing_cooldown: int = 0
const blessing_cooldown: int = 8
const blessing_range: int = 3

func _ready():
	label = "priest"
	._ready()


func on_turn():
	return
	var d_score = self.enemy_dijkstra.d_score(self.get_pos())
	if telegraphing:
		if telegraph_timer > 0:
			telegraph_timer -= 1
		else:
			bless()
	elif d_score <= 5 && cur_blessing_cooldown == 0:
		combatLog.say("The priest begins chanting.",20)
		telegraphing = true
		telegraph_timer = telegraph_duration
	else:
		pass # seek
	.on_turn()


#	var maybe_door = door_adjacent()
#	if .pc_adjacent():
#		attack()
#	elif maybe_door != null:
#		maybe_door.nudge(0, false)
#	else:
#		set_pos(wander_to_door())

func bless():
	telegraphing = false
	combatLog.say("The priest completes his spell!")
	var pos = get_pos()
	for i in range(-blessing_range, blessing_range+1):
		for j in range(-blessing_range, blessing_range+1):
			if i == 0 && j == 0:
				continue
			var target = pos + Vector2(i,j)
			var blessing_targets = locationService.lookup(target, constants.MOBS)
			for mob in blessing_targets:
				if !mob.block:
					combatLog.say("A shimmering barrier materializes around the {0}.".format([mob.label]), 10)
					mob.block()
	pass

func _draw() -> void:
	if telegraphing:
		self.modulate = constants.WINDUP_COLOR
	else:
		self.modulate = Color(1, 1, 1)
	._draw()
