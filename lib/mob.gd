extends "res://lib/actor.gd"

class_name Mob

var pc: PC

func _ready():
	randomize()
	add_to_group(constants.MOBS)

func pc_adjacent() -> bool:
	var v = pos - pc.pos
	return (abs(v.x) + abs(v.y) <= 1)

func seek_to_player(px: int, py: int, ex: int, ey: int, d_map: Array, terrain: Node2D) -> Vector2:
	# find the smallest direction in the d_map
	var smallest_val = d_map[terrain.to_linear(ex, ey)]
	var candidates = [Vector2(ex + 1, ey), Vector2(ex, ey + 1), Vector2(ex - 1, ey), Vector2(ex, ey - 1)]
	for c in candidates:
		var t = d_map[terrain.to_linear(c.x,c.y)]
		if t:
			smallest_val = min(smallest_val, t)
	
	var final_candidates = []
	for c in candidates:
		if d_map[terrain.to_linear(c.x,c.y)] == smallest_val:
			final_candidates.append(c)
	
	if final_candidates.size() == 0:
		return Vector2(ex,ey)
	
	return final_candidates[randi() % final_candidates.size()]

