extends Mob

var telegraph_timer: int = 2
const telegraph_duration: int = 4

var cur_blessing_cooldown: int = 0
const blessing_cooldown: int = 8
const blessing_range: int = 4
const blessing_start_cast_range: int = 3

func _ready():
	label = "priest"
	cur_blessing_cooldown = randi() % blessing_cooldown
	tiebreaker = 10
	._ready()

func on_turn():
	var d_score = self.enemy_dijkstra.d_score(self.get_pos())
	if telegraphing:
		if telegraph_timer > 0:
			telegraph_timer -= 1
		else:
			bless()
	elif blessing_start_cast_range <= 5 && cur_blessing_cooldown == 0 && d_score <= blessing_start_cast_range:
		combatLog.say("The priest begins chanting.",20)
		telegraphing = true
		update()
		telegraph_timer = telegraph_duration
	else:
		if cur_blessing_cooldown > 0:
			cur_blessing_cooldown -= 1
		animated_move_to(seek(enemy_dijkstra))

func bless():
	telegraphing = false
	update()
	combatLog.say("The priest completes his spell!", 50)
	cur_blessing_cooldown = blessing_cooldown
	var pos = get_pos()
	for i in range(-blessing_range, blessing_range+1):
		for j in range(-blessing_range, blessing_range+1):
			if i == 0 && j == 0:
				continue
			var target = pos + Vector2(i,j)
			var blessing_targets = locationService.lookup(target, constants.MOBS)
			for mob in blessing_targets:
				if !mob.blocking:
					combatLog.say("A shimmering barrier materializes around the {0}.".format([mob.label]), 10)
					mob.block()
