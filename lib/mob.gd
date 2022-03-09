extends Actor

class_name Mob

var pc
signal enemy_hit(dir)
signal killed_by_pc(label)

func _ready():
	randomize()
	add_to_group(constants.MOBS)
	add_to_group(constants.BLOCKER)
	add_to_group(constants.PROJECTILE_BLOCKER)
	connect(constants.ENEMY_HIT, pc, constants.ENEMY_HIT)

func pc_adjacent() -> bool:
	var v = get_pos() - pc.get_pos()
	return (abs(v.x) + abs(v.y) <= 1)
	
func is_hit(dir: Vector2):
	emit_signal(constants.ENEMY_HIT, dir)
	die()
	
func die():
	if is_in_group(self.constants.MOBS):
		emit_signal(constants.DESCHEDULE, self)
	self.locationService.delete_node(self)
	#TODO: handle if it was killed by someone else (eg: wizard)
	emit_signal(constants.KILLED_BY_PC, label)
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
	if pos != null:
		var t_pos = self.SCREEN.dungeon_to_screen(pos.x,pos.y)
		self.position.x = float(t_pos.x)
		self.position.y = float(t_pos.y)

func knockback(dir: Vector2):
	var pos = get_pos()
	var i: int = pos.x + dir.x
	var j: int = pos.y + dir.y
	var mobs_at = locationService.lookup(Vector2(i, j), constants.MOBS)
	var obstacles_at = locationService.lookup(Vector2(i, j), constants.BLOCKER)
	for m in mobs_at:
		if m.knight and m.blocking:
			m.knockback(dir)
		else:
			m.die()
	for o in obstacles_at:
		o.die()
	if mobs_at.size() > 0 or obstacles_at.size() > 0:
		if not (self.knight and self.blocking):
			self.die()
		else:
			return
	if try_move(i, j):
		knockback(dir)
