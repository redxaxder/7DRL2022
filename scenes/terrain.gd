extends Node2D

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
