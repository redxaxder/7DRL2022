extends Node2D

class_name Terrain

var SCREEN = preload("res://lib/screen.gd").new()
var DIR = preload("res://lib/dir.gd").new()

var width: int = 20
var height: int = 6
var map
#var hole_punch_chance: float = 0.1

var contents: Array = []
var dijkstra_map: Array = []
var blood_map: Array = []
var active_rooms: Dictionary = {} # used as a set. room -> 0

const dijstra_map_limit = 70

const cosmetic_map_seed: int = 68000

func at(x,y):
	return atv(Vector2(x,y))

func atv(v: Vector2):
	if in_bounds(v):
		return contents[to_linear(v.x,v.y)]
	else:
		return '#'

func in_bounds(v: Vector2) -> bool:
	return v.x >= 0 && v.x < width && v.y >= 0 && v.y < height

func d_score(v: Vector2) -> int:
	var ix = to_linear(v.x,v.y)
	if ix >= dijkstra_map.size() || ix < 0:
		return 100000
	var x = dijkstra_map[ix]
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
							if m <= dijstra_map_limit:
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
	#terrain marks door spawn locations with '.' and they get filled later
	contents[to_linear(x, y)] = '.'
	return true

func can_be_door(loc: Vector2) -> bool:
	if loc.x <= 0 || loc.x >= width-1: return false
	if loc.y <= 0 || loc.y >= height-1: return false
	return map.count_rooms(loc,1) == 2

func has_door(cells: Array) -> bool:
	var door_placed = false
	for t in cells:
		if atv(t) == '.':
			door_placed = true
	return door_placed

func place_exit(room: Vector3):
	var x = room.x + 1 + (randi() % int(room.z - 1))
	var y = room.y + 1 + (randi() % int(room.z - 1))
	contents[to_linear(x, y)] = '>'

func is_exit(v: Vector2) -> bool:
	return atv(v) == '>'

func is_wall(v: Vector2) -> bool:
	return atv(v) == '#'

func is_floor(v: Vector2) -> bool:
	var t = atv(v)
	return t == '.' || t == null

func place_a_door(cells: Array) -> bool:
	# first, check if a door is already placed:
	var candidates: Array = []
	var door_placed = false
	for t in cells:
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

func room_side(room: Vector3, dir: int) -> Array:
	var results = []
	var topleft=Vector2(room.x, room.y)
	var bottomright=Vector2(room.x + room.z, room.y + room.z)
	var corner
	var v
	match dir:
		Dir.DIR.UP:
			corner = topleft
			v = Vector2(1,0)
		Dir.DIR.LEFT:
			corner = topleft
			v = Vector2(0,1)
		Dir.DIR.DOWN:
			corner = bottomright
			v = Vector2(-1,0)
		Dir.DIR.RIGHT:
			corner = bottomright
			v = Vector2(0,-1)
	for i in range(room.z):
		results.append(corner + (i * v))
	return results

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
	map.rooms.shuffle()
	#place the exit
	for i in map.rooms.size():
		if map.rooms[i].z > 2:
			place_exit(map.rooms[i])
		break
	#spawn the doors:	
	for room in map.rooms:
		var sides = [] # room sides lacking a door
		for dir in [Dir.DIR.UP,Dir.DIR.DOWN,Dir.DIR.RIGHT,Dir.DIR.LEFT]:
			var side = room_side(room,dir)
			if !has_door(side):
				sides.append(room_side(room,dir))
		sides.shuffle()
		var n = 4 - sides.size() # number of walls with a door
		while n < 3 && sides.size() > 0:
			var side = sides.pop_back()
			if place_a_door(side):
				n += 1
	#fill non-doors with walls
	for room in map.rooms:
		for i in range(room.z+1):
			for v in map.room_outline(room):
				var t = to_linear(v.x,v.y)
				if contents[t] == null:
					contents[t] = '#'

func splatter_blood(pos: Vector2, dir: Vector2):
	var blood = 15
	while blood > 0 && in_bounds(pos):
		var ix = to_linear(pos.x, pos.y)
		var pool = blood_map[ix]
		var deposit = max(int((blood - pool) * 0.6),1) + 1
		blood_map[ix] += deposit
		blood -= deposit
		if atv(pos) == '#':
			break
		pos += dir
	update()

var wall_txtr = (preload("res://sprites/wall.tscn").instance() as Sprite).texture
var floor_txtr = (preload("res://sprites/floor.tscn").instance() as Sprite).texture
var exit_txtr = (preload("res://sprites/exit.tscn").instance() as Sprite).texture
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
	for room in active_rooms:
		for cell in map.room_cells(room, 1):
			var ix = to_linear(cell.x,cell.y)
			var blood = blood_map[ix]
			var n: int = r[0]
			r = rand_seed(r[1])
			var pos = SCREEN.dungeon_to_screen(cell.x,cell.y)
			var tile = atv(cell)
			if tile == '#':
				if blood == 0:
					draw_texture(wall_txtr,pos + offset)
				else:
					draw_texture(wall_txtr,pos + offset, blood_color)
			elif tile == '>':
				if blood == 0:
					draw_texture(exit_txtr,pos + offset)
				else:
					draw_texture(exit_txtr,pos + offset, blood_color)
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
