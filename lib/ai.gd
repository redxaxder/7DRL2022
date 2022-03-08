extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# d_map is a dijstra map
func seek_to_player(px: int, py: int, ex: int, ey: int, d_map: Array, terrain: Node2D) -> Vector2:
	# find the smallest direction in the d_map
	var smallest = Vector2(ex + 1, ex)
	var smallest_val = d_map[terrain.to_linear(ex, ey)]
	var e = d_map[terrain.to_linear(ex + 1, ey)]
	var w = d_map[terrain.to_linear(ex - 1, ey)]
	var n = d_map[terrain.to_linear(ex, ey - 1)]
	var s = d_map[terrain.to_linear(ex, ey + 1)]
	if e != null and e < smallest_val:
		smallest = Vector2(ex + 1, ey)
		smallest_val = e
	if s != null and  s < smallest_val:
		smallest = Vector2(ex, ey + 1)
		smallest_val = s
	if w != null and  w < smallest_val:
		smallest = Vector2(ex - 1, ey)
		smallest_val = w
	if n != null and  n < smallest_val:
		smallest = Vector2(ex, ey - 1)
		smallest_val = n
	return smallest

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
