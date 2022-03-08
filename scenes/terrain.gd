extends Node2D

class_name Terrain

var SCREEN = preload("res://lib/screen.gd").new()

var width: int = 20
var height: int = 6
var hole_punch_chance: float = 0.1
var pan: Vector2 = Vector2(0,0)

var contents: Array = []
var dijkstra_map: Array = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func at(x,y):
	if x >= 0 && x < width && y >= 0 && y < height:
		return contents[to_linear(x,y)]
	else:
		return '#'


# Called when the node enters the scene tree for the first time.

func _ready():
	randomize()

func from_linear(ix: int) -> Vector2:
	return Vector2(ix % width, ix / width)
	
func to_linear(x,y) -> int:
	return width * y + x

func update_dijkstra_map(dest: Array):
	var d_map: Array
	d_map.clear()
	d_map.resize(contents.size())
	# initialize all non-wall things to a very high number
	for i in range(contents.size()):
		if contents[i] == '#':
			d_map[i] = null
		else:
			d_map[i] = 1000000
	# initialize all destinations to 0
	for v in dest:
		d_map[to_linear(v.x, v.y)] = 0
	var live: Array = []
	var next: Array = []
	for v in dest:
		var ix = to_linear(v.x, v.y)
		for n in neighbors(ix):
			live.append(n)
	var prev
	var tmp
	while live.size() > 0:
		next.clear()
		for i in live:
			if i != prev:
				prev = i
				if d_map[i] != null:
					var ns = neighbors(i)
					var neighs: Array = []
					for n in ns:
						var v = d_map[n]
						if v != null:
							neighs.push_back(d_map[n])
					if neighs.size() > 0:
						var m: int = array_min(neighs)
						if d_map[i] and d_map[i] > m + 1:
							d_map[i] = array_min(neighs) + 1
							if m <= 70:
								for n in ns:
									next.append(n)
		tmp = live
		live = next
		next = tmp
		next.sort()
	dijkstra_map = d_map

func neighbors(i: int) -> Array:
	var arr: Array = []
	var p = from_linear(i)
	if p.x > 0:
		arr.push_back(i-1)
	if p.y > 0:
		arr.push_back(i-width)
	if p.x < width - 1:
		arr.push_back(i+1)
	if p.y < height - 1:
		arr.push_back(i+width)
	return arr
	
func array_min(arr: Array) -> int:
	var m: int = arr[0]
	for i in arr:
		if i < m:
			m = i
	return m

func load_random_map():
	var ix = 20000 # (randi() % 263 + 1) * 100
	load_map(ix)
	
func load_map_resource(ix):
	var path = "res://resources/maps/map{0}.tres".format([ix])
	return load(path)

func load_map(ix): # max index: 26460
	var map = load_map_resource(ix)
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

var offset: Vector2 = Vector2(-SCREEN.TILE_WIDTH / 2,-SCREEN.TILE_HEIGHT / 2)
func _draw():
	#instead of managing a bajillion sprites in here we manually
	#draw walls and floors
	var min_x = max(pan.x,0)
	var max_x = min(pan.x + SCREEN.VIEWPORT_WIDTH, width)
	var min_y = max(pan.y,0)
	var max_y = min(pan.y + SCREEN.VIEWPORT_HEIGHT, height)
	for i in range(min_x,max_x):
		for j in range(min_y,max_y):
			var pos = SCREEN.dungeon_to_screen(i-pan.x,j-pan.y)
			var tile = at(i,j)
			if tile == '#':
				draw_texture(wall_txtr,pos + offset)
			elif tile == null:
				draw_texture(floor_txtr,pos + offset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
