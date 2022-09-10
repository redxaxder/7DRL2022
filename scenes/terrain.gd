extends Node2D

class_name Terrain

var SCREEN = preload("res://lib/screen.gd").new()
var DIR = preload("res://lib/dir.gd").new()

var width: int = 20
var height: int = 6
var map
#var hole_punch_chance: float = 0.1

var contents: Array = []
var blood_map: Array = []
var blood_spread_frontier: Dictionary = {}
var active_rooms: Dictionary = {} # used as a set. room -> 0
var torch_map: Dictionary = {} # position to torches, used for lighting

const cosmetic_map_seed: int = 68000

var terrain_glyph = Glyph.new()

func _ready():
	randomize()
	add_child(terrain_glyph)
	terrain_glyph.visible = false

func at(x,y):
	return atv(Vector2(x,y))

func atv(v: Vector2):
	if in_bounds(v):
		return contents[to_linear(v.x,v.y)]
	else:
		return '#'

func in_bounds(v: Vector2) -> bool:
	return v.x >= 0 && v.x < width && v.y >= 0 && v.y < height

func from_linear(ix: int) -> Vector2:
# warning-ignore:integer_division
	return Vector2(ix % width, ix / width)

func to_linear(x,y) -> int:
	return width * y + x

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

func in_active_room(target: Vector2) -> bool:
	var is_active = false
	for room in map.get_rooms(target,1):
		is_active = is_active || active_rooms.has(room)
	return is_active

func load_map_resource(ix):
	var path = "res://resources/maps/map{0}.tres".format([ix])
	return load(path)

func spawn_door(v:Vector2):
	#terrain marks door spawn locations with '.' and they get filled later
	contents[to_linear(v.x, v.y)] = '.'
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
	var x = room.x + 2 + (randi() % int(room.z - 3))
	var y = room.y + 2 + (randi() % int(room.z - 3))
	contents[to_linear(x, y)] = '>'

func is_exit(v: Vector2) -> bool:
	return atv(v) == '>'

func is_wall(v: Vector2) -> bool:
	return atv(v) == '#' or atv(v) == 'w' or atv(v) == 'W'

func is_door(v: Vector2) -> bool:
	return atv(v) == '.'

func is_torch(v: Vector2) -> bool:
	return atv(v) == 'W'

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
			candidates.append(t)
	#if not, find a place for it
	if !door_placed && candidates.size() > 0:
		var ix = randi() % candidates.size()
		var v: Vector2 = candidates[ix]
		door_placed = spawn_door(v)
		if door_placed && (randi() % 2 == 0): # sometimes, we try to make this a double door
			var adj: Array = []
			for c in candidates:
				if v.distance_to(c) < 1.01:
					adj.append(c)
			if adj.size() > 0:
				adj.shuffle()
				spawn_door(adj[0])

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

func load_map(ix, level: int): # max index: 26460
	map = load_map_resource(ix)
	active_rooms = {}
	if randi() % 2 == 0:
		map.flip_v()
	if randi() % 2 == 0:
		map.flip_h()
	width = map.width + 1
	height = map.height + 1
	var size = width * height
	contents = []
	contents.resize(size)
	blood_map = []
	blood_spread_frontier = {}
	blood_map.resize(size)
	for i in blood_map.size():
		blood_map[i] = 0
	map.rooms.shuffle()
	#place the exit
	if level < 6:
		for i in map.rooms.size():
			if map.rooms[i].z > 7:
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
		for __ in range(room.z+1):
			for v in map.room_outline(room):
				var t = to_linear(v.x,v.y)
				if contents[t] == null:
					if randf() < 0.05:
						contents[t] = 'W'
					else:
						contents[t] = '#'
	update()

func splatter_blood(pos: Vector2, dir: Vector2):
	var blood = 15
	while blood > 0 && in_bounds(pos):
		var ix = to_linear(pos.x, pos.y)
		var pool = blood_map[ix]
		var deposit = max(int((blood - pool) * 0.6),1) + 1
		add_blood(ix, deposit)
		blood -= deposit
		if atv(pos) == '#':
			break
		pos += dir
	update()

func add_blood(ix, deposit): #TODO: dirty flags for rooms here
	if 0 <= ix && ix < blood_map.size():
		blood_map[ix] += deposit
		if blood_map[ix] > 40:
			blood_spread_frontier[ix] = 0

func spread_blood():
	for i in blood_spread_frontier.keys():
		var coord = from_linear(i)
		var neighs = [
			coord + Vector2(1, 0),
			coord + Vector2(-1, 0),
			coord + Vector2(0, 1),
			coord + Vector2(0, -1),
			coord + Vector2(1, 1),
			coord + Vector2(1, -1),
			coord + Vector2(-1, 1),
			coord + Vector2(-1, -1),
		]
		var targets = []
		for n in neighs:
			if in_bounds(n) and not is_wall(n):
				targets.push_back(n)
		blood_map[i] -= targets.size()
		if blood_map[i] <= 40:
# warning-ignore:return_value_discarded
			blood_spread_frontier.erase(i)
		targets.shuffle()
		for t in targets:
			add_blood(to_linear(t.x,t.y), 1)

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
			var pos = SCREEN.dungeon_to_screen(cell)
			var tile = atv(cell)
			var target = Rect2(pos + offset, Glyph.cell_size / 8)
			var glyph_color = Color(0.2, 0.2, 0.2)
			if blood > 0:
				glyph_color = blood_color
			if tile == '#':
				terrain_glyph.index = Glyph.from('#')
			elif tile == '>':
				terrain_glyph.index = Glyph.from('>')
				glyph_color = Color(1,1,1)
			elif tile == 'w':
				terrain_glyph.index = 206
			elif tile == 'W':
				terrain_glyph.index = 206
			else:
				if blood == 0:
					terrain_glyph.index = Glyph.from('.')
					var weight: float = float(n % 4) / 4.0
					glyph_color = min_floor_color.linear_interpolate(max_floor_color, weight)
				elif blood < 10:
					terrain_glyph.index = 250
				elif blood < 20:
					terrain_glyph.index = 249
				elif blood < 30:
					terrain_glyph.index = 248
				else:
					terrain_glyph.index = 247
			draw_texture_rect(terrain_glyph.texture,target, false, glyph_color, false, terrain_glyph.normal_map)

const burning = preload("res://scenes/burning.tscn")
func add_light_at(pos):
	if torch_map.has(pos):
		return
	var torch = burning.instance()
	torch.position = SCREEN.dungeon_to_screen(pos)
	torch_map[pos] = torch
	add_child(torch)

func remove_light_at(pos):
	if torch_map.has(pos):
		torch_map[pos].queue_free()
# warning-ignore:return_value_discarded
		torch_map.erase(pos)
	var ix = to_linear(pos.x, pos.y)
	if in_bounds(pos) && contents[ix] == 'W':
		contents[ix] = 'w'
