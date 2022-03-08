extends Node2D

var SCREEN = preload("res://lib/screen.gd").new()

var width: int = 20
var height: int = 6
var hole_punch_chance: float = 0.1
var pan: Vector2 = Vector2(0,0)

var contents: Array = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func at(x,y):
	if x >= 0 && x < width && y >= 0 && y < height:
		return contents[to_linear(x,y)]
	else:
		return '#'


# Called when the node enters the scene tree for the first time.
#func _ready():
#	load_map(0)

func to_linear(x,y) -> int:
	return width * y + x
	
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

const offset: Vector2 = Vector2(-12,-18)
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
