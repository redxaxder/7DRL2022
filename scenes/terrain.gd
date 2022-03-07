extends Node2D

var SCREEN = preload("res://lib/screen.gd").new()
var maps = preload("res://resources/maps/static_map.gd").new().maps

var width: int = 20
var height: int = 6

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

func load_map(ix):
	var map = maps[ix]
	width = map.width + 1
	height = map.height + 1
	var size = width * height
	contents.clear()
	contents.resize(size + 1)
	for room in map.rooms:
		var bottom_edge = room.y + room.z
		for i in range(room.z):
			var x = room.x + i
			contents[to_linear(x, bottom_edge)] = '#'
		var right_edge = room.x + room.z
		for i in range(room.z):
			var y = room.y + i
			contents[to_linear(bottom_edge, y)] = '#'


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
