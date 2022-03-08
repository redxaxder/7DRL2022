extends Node2D

var SCREEN = preload("res://lib/screen.gd").new()
var maps = preload("res://resources/maps/static_map.gd").new().maps

var width: int = 20
var height: int = 6
var hole_punch_chance: float = 0.1

var contents: Array = \
  ['#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#',
   '#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',
   '#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',
   '#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',
   '#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',
   '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#','#']
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func at(x,y):
	return contents[to_linear(x,y)]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func to_linear(x,y) -> int:
	return width * y + x
	
func dijkstra_map(source: Vector2, dest: Array, map: Array) -> Array:
	var d_map: Array
	d_map.clear()
	d_map.resize(contents.size())
	# initialize all non-wall things to a very high number
	for i in range(map.size()):
		if map[i] == '#':
			d_map[i] = null
		else:
			d_map[i] = 1000000
	# initialize all destinations to 0
	for v in dest:
		d_map[to_linear(v.x, v.y)] = 0
	var changed: bool = true
	while changed:
		changed = false
		for x in range(width):
			for y in range(height):
				var i: int = to_linear(x, y)
				if d_map[i] != null:
					var neighs: Array = neighbor_vals(x, y, d_map)
					if neighs.size() > 0:
						var m: int = array_min(neighs)
						if d_map[i] and d_map[i] > m + 1:
							d_map[i] = array_min(neighs) + 1
							changed = true
#	for y in range(height):
#		var start: int = to_linear(0, y)
#		var end: int = to_linear(width-1, y)
#		printt(d_map.slice(start, end))
	return d_map
	
func neighbor_vals(x: int, y: int, map: Array) -> Array:
	var arr: Array
	arr.clear()
	if x < width:
		var e = map[to_linear(x + 1, y)]
		if e !=	null:
			arr.push_back(e)
	if y < height - 1:
		var s = map[to_linear(x, y + 1)]
		if s != null:
			arr.push_back(s)
	if x > 0:
		var w = map[to_linear(x - 1, y)]
		if w != null:
			arr.push_back(w)
	if y > 0:
		var n = map[to_linear(x, y - 1)]
		if n != null:
			arr.push_back(n)
	return arr
	
func array_min(arr: Array) -> int:
	var m: int = arr[0]
	for i in arr:
		if i < m:
			m = i
	return m
	
func load_map(ix):
	var map = maps[ix]
	width = map.width + 1
	height = map.height + 1
	var size = width * height
	contents.clear()
	contents.resize(size + 1)
	for room in map.rooms:
		var hole_punched_x: bool = false
		var hole_punched_y: bool = false
		var bottom_edge = room.y + room.z
		var top_edge = room.y
		var right_edge = room.x + room.z
		var left_edge = room.x
		for i in range(room.z):
			var x = room.x + i
			# top edge
			if contents[to_linear(x, top_edge)] == null:
				contents[to_linear(x, top_edge)] = '#'
			# bottom edge
			contents[to_linear(x, bottom_edge)] = '#'
			if rand_range(0, 1) < hole_punch_chance:
				contents[to_linear(x, bottom_edge)] = ' '
				hole_punched_x = true
		# ensure x holes are punched
		if not hole_punched_x:
			var x = int(rand_range(room.x+1, right_edge-1))
			contents[to_linear(x, bottom_edge)] = ' '
		for i in range(room.z):
			var y = room.y + i
			# left edge
			if contents[to_linear(left_edge, y)] == null:
				contents[to_linear(left_edge, y)] = '#'
			# right edge
			contents[to_linear(right_edge, y)] = '#'
			if rand_range(0, 1) < hole_punch_chance:
				contents[to_linear(right_edge, y)] = ' '
				hole_punched_y = true
		# ensure y holes are punched
		if not hole_punched_y:
			var y = int(rand_range(room.y+1, bottom_edge-1))
			contents[to_linear(right_edge, y)] = ' '

var wall_txtr = (preload("res://sprites/wall.tscn").instance() as Sprite).texture
var floor_txtr = (preload("res://sprites/floor.tscn").instance() as Sprite).texture

const offset: Vector2 = Vector2(-12,-18)
func _draw():
	#instead of managing a bajillion sprites in here we manually
	#draw walls and floors
	for i in range(width):
		for j in range(height):
			var pos = SCREEN.dungeon_to_screen(i,j)
			var tile = at(i,j)
			if tile == '#':
				draw_texture(wall_txtr,pos + offset)
			elif tile == null:
				draw_texture(floor_txtr,pos + offset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
