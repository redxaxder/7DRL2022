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
			
#func load_map(ix):
#	var map = maps[ix]
#	width = map.width + 1
#	height = map.height + 1
#	var size = width * height
#	contents.clear()
#	contents.resize(size + 1)
#	for room in map.rooms:
#		var hole_punched_x: bool = false
#		var hole_punched_y: bool = false
#		# punch x holes		
#		var bottom_edge = room.y + room.z
#		for i in range(room.z):
#			var x = room.x + i
#			contents[to_linear(x, bottom_edge)] = '#'
##			if xc < hole_punch_chance:
##				contents[to_linear(x, bottom_edge)] = ' '
##				hole_punched_x = true
#		# guarantee we have at least one x hole punched
##		if not hole_punched_x:
##			hole_punched_x = true
##			var x: int = int(rand_range(0, room.z))
##			contents[to_linear(x, bottom_edge)] = ' '
#		# punch y holes
#		var right_edge = room.x + room.z
#		for i in range(room.z):
#			var y = room.y + i
#			contents[to_linear(y, right_edge)] = '#'
##			if yc < hole_punch_chance:
##				contents[to_linear(y, right_edge)] = ' '
#		# guarantee we have at least one x hole punched
##		if not hole_punched_y:
##			hole_punched_y = true
##			var y: int = int(rand_range(0, room.z))
##			contents[to_linear(y, bottom_edge)] = ' '


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
