extends Node2D

class_name Terrain

var SCREEN = preload("res://lib/screen.gd").new()
var DIR = preload("res://lib/dir.gd").new()

var width: int = 20
var height: int = 6
var map: Map
#var hole_punch_chance: float = 0.1

var contents: Array = []
var dijkstra_map: Array = []
var blood_map: Array = []

const cosmetic_map_seed: int = 68000

func at(x,y):
	return atv(Vector2(x,y))

func atv(v: Vector2):
	if v.x >= 0 && v.x < width && v.y >= 0 && v.y < height:
		return contents[to_linear(v.x,v.y)]
	else:
		return '#'

func d_score(v: Vector2) -> int:
	var x = dijkstra_map[to_linear(v.x,v.y)]
	if x == null:
		return 100000
	return x

func _ready():
	randomize()

func from_linear(ix: int) -> Vector2:
	return Vector2(ix % width, ix / width)
	
func to_linear(x,y) -> int:
	return width * y + x

func update_dijkstra_map(dest: Array):
	var d_map: Array = []
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
	var ix = 200 # (randi() % 263 + 1) * 100
	load_map(ix)
	
func load_map_resource(ix):
	var path = "res://resources/maps/map{0}.tres".format([ix])
	return load(path)
	
func spawn_door(x: int, y: int):
	contents[to_linear(x, y)] = '.'
	var root = get_parent()
	root.spawn_door(Vector2(x, y))
	return true

func can_be_door(loc: Vector2) -> bool:
	if loc.x <= 0 || loc.x >= width-1: return false
	if loc.y <= 0 || loc.y >= height-1: return false
	return map.count_rooms(loc,1) == 2

func _place_a_door(start: Vector2, dir: Vector2, size: int):
	# first, check if a door is already placed:
	var candidates: Array = []
	var door_placed = false
	for i in range(size):
		var t = start + (i * dir)
		var tile = atv(t)
		if tile == '.':
			door_placed = true
		if can_be_door(t):
#			spawn_door(t.x,t.y)
			candidates.append(t)
	#if not, find a place for it
	if !door_placed && candidates.size() > 0:
		var v = candidates[randi() % candidates.size()]
		door_placed = spawn_door(v.x,v.y)
	return door_placed

func load_map(ix): # max index: 26460
	map = load_map_resource(ix)
	if randi() % 2 == 0:
		map.flip_v()
	if randi() % 2 == 0:
		map.flip_h()
	width = map.width + 1
	height = map.height + 1
	var size = width * height
	contents.clear()
	contents.resize(size)
	blood_map.clear()
	blood_map.resize(size)
	for i in blood_map.size():
		blood_map[i] = 0
	#spawn the doors:
	for room in map.rooms:
		var topleft=Vector2(room.x, room.y)
		var bottomright=Vector2(room.x + room.z, room.y + room.z)
		_place_a_door(topleft, Vector2(1,0), room.z) # top
		_place_a_door(topleft, Vector2(0,1), room.z) # bottom
		_place_a_door(bottomright, Vector2(-1,0), room.z) # left
		_place_a_door(bottomright, Vector2(0,-1), room.z) # right
	#nfill non-doors with walls
	for room in map.rooms:
		for i in range(room.z+1):
			for ix in [ \
				to_linear(room.x + i, room.y), # top \
				to_linear(room.x + i, room.y + room.z), # bottom \
				to_linear(room.x, room.y + i), # left \
				to_linear(room.x + room.z, room.y + i), # right \
				]:
				if contents[ix] == null:
					contents[ix] = '#'

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
			else:
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
