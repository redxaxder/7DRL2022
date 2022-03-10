extends Node2D

class_name Terrain

var SCREEN = preload("res://lib/screen.gd").new()

var width: int = 20
var height: int = 6
var hole_punch_chance: float = 0.1

var contents: Array = []
var dijkstra_map: Array = []
var blood_map: Array = []

const cosmetic_map_seed: int = 68000

func at(x,y):
	if x >= 0 && x < width && y >= 0 && y < height:
		return contents[to_linear(x,y)]
	else:
		return '#'

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
	
func spawn_door(x: int, y: int):
	contents[to_linear(x, y)] = '.'
	var root = get_parent()
	root.spawn_door(Vector2(x, y))

func load_map(ix): # max index: 26460
	var map = load_map_resource(ix)
	width = map.width + 1
	height = map.height + 1
	var size = width * height
	contents.clear()
	contents.resize(size + 1)
	blood_map.clear()
	blood_map.resize(size + 1)
	for i in blood_map.size():
		blood_map[i] = 0
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
				spawn_door(x, bottom_edge)
				hole_punched_x = true
		# ensure x holes are punched
		if not hole_punched_x:
			var x = int(rand_range(room.x+1, right_edge-1))
			spawn_door(x, bottom_edge)
		for i in range(room.z):
			var y = room.y + i
			# left edge
			if contents[to_linear(left_edge, y)] == null:
				contents[to_linear(left_edge, y)] = '#'
			# right edge
			contents[to_linear(right_edge, y)] = '#'
			if rand_range(0, 1) < hole_punch_chance:
				spawn_door(right_edge, y)
				hole_punched_y = true
		# ensure y holes are punched
		if not hole_punched_y:
			var y = int(rand_range(room.y+1, bottom_edge-1))
			spawn_door(right_edge, y)
			
func splatter_blood(pos: Vector2, dir: Vector2):
	blood_map[to_linear(pos.x, pos.y)] += 11
	pos += dir
	blood_map[to_linear(pos.x, pos.y)] += 9
	pos += dir
	blood_map[to_linear(pos.x, pos.y)] += 7
	pos += dir
	blood_map[to_linear(pos.x, pos.y)] += 5
	pos += dir
	blood_map[to_linear(pos.x, pos.y)] += 3
	pos += dir
	blood_map[to_linear(pos.x, pos.y)] += 1
	update()

var wall_txtr = (preload("res://sprites/wall.tscn").instance() as Sprite).texture
var floor_txtr = (preload("res://sprites/floor.tscn").instance() as Sprite).texture
var blood_txtr = (preload("res://sprites/blood.tscn").instance() as Sprite).texture
var some_blood_txtr = (preload("res://sprites/lots_of_blood.tscn").instance() as Sprite).texture
var more_blood_txtr = (preload("res://sprites/more_blood.tscn").instance() as Sprite).texture
var most_blood_txtr = (preload("res://sprites/most_blood.tscn").instance() as Sprite).texture
var max_floor_color = Color(0.300781, 0.300781, 0.300781)
var min_floor_color = Color(0.460938, 0.460938, 0.460938)
var blood_color = Color(1, 0, 0)

var offset: Vector2 = Vector2(-SCREEN.TILE_WIDTH / 2,-SCREEN.TILE_HEIGHT / 2)
func _draw():
	#instead of managing a bajillion sprites in here we manually
	#draw walls and floors
	var r: Array = rand_seed(cosmetic_map_seed)
	for i in range(width):
		for j in range(height):
			var blood = blood_map[to_linear(i, j)]
			var n: int = r[0]
			r = rand_seed(r[1])
			var pos = SCREEN.dungeon_to_screen(i,j)
			var tile = at(i,j)
			if tile == '#':
				if blood == 0:
					draw_texture(wall_txtr,pos + offset)
				else:
					draw_texture(wall_txtr,pos + offset, blood_color)
			elif tile == null:
				if blood == 0:
					var weight: float = float(n % 4) / 4.0
					var floor_color = min_floor_color.linear_interpolate(max_floor_color, weight)
					draw_texture(floor_txtr,pos + offset, floor_color)
				elif blood < 10:
					draw_texture(blood_txtr,pos + offset, blood_color)
				elif blood < 20:
					draw_texture(some_blood_txtr,pos + offset, blood_color)
				elif blood < 30:
					draw_texture(more_blood_txtr,pos + offset, blood_color)
				else:
					draw_texture(most_blood_txtr,pos + offset, blood_color)
