extends Actor

class_name Mob

var pc: PC
signal enemy_hit(dir)

func _ready():
	randomize()
	add_to_group(constants.MOBS)
	connect(constants.ENEMY_HIT, pc, constants.ENEMY_HIT)

func pc_adjacent() -> bool:
	var v = get_pos() - pc.get_pos()
	return (abs(v.x) + abs(v.y) <= 1)
	
func is_hit(dir: Vector2):
	emit_signal(constants.ENEMY_HIT, dir)
	emit_signal(constants.DESCHEDULE, self)
	queue_free()

func seek_to_player() -> Vector2:
	# find the smallest direction in the d_map
	var e = get_pos()
	var d_map = terrain.dijkstra_map
	var smallest_val = d_map[terrain.to_linear(e.x, e.y)]
	var candidates = [Vector2(e.x + 1, e.y), Vector2(e.x, e.y + 1), Vector2(e.x - 1, e.y), Vector2(e.x, e.y - 1)]
	for c in candidates:
		var t = d_map[terrain.to_linear(c.x,c.y)]
		if t:
			smallest_val = min(smallest_val, t)
	
	var final_candidates = []
	for c in candidates:
		if d_map[terrain.to_linear(c.x,c.y)] == smallest_val:
			final_candidates.append(c)
	
	if final_candidates.size() == 0:
		final_candidates = candidates
	
	return final_candidates[randi() % final_candidates.size()]

func draw() -> void:
	var pos = get_pos()
	var t_pos = self.SCREEN.dungeon_to_screen(pos.x,pos.y)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)
