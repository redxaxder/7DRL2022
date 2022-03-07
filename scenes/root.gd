extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$terrain.load_map(0)
	pass # Replace with function body.

var x = 3
var y = 3
var tick = 0

func _unhandled_input(event):
	var acted = false
	if event.is_action_pressed("left"):
		acted = try_move(x-1,y)
	elif event.is_action_pressed("right"):
		acted = try_move(x+1,y)
	elif event.is_action_pressed("up"):
		acted = try_move(x,y-1)
	elif event.is_action_pressed("down"):
		acted = try_move(x,y+1)
	elif event.is_action_pressed("pass"):
		acted = true
	elif event.is_action_pressed("action"):
		acted = true
	
	if acted:
		$pc.position = dungeon_to_screen(x,y)
		tick += 1
		$gui/status.text = "tick {0}\n x {1}\n y {2}".format([tick,x,y])
		clear_terrain()
		display_terrain()

func try_move(i,j) -> bool:
	if $terrain.at(i,j) == '#':
		return false
	else:
		x = i
		y = j
		return true


func clear_terrain():
	for child in $terrain.get_children():
		$terrain.remove_child(child)
		child.queue_free()

func display_terrain():
	for i in range($terrain.width):
		for j in range($terrain.height):
			var t = $terrain.at(i,j)
			if t == '#':
				spawn_wall(i,j)
			else:
				spawn_floor(i,j)

const wall = preload("res://sprites/wall.tscn")
func spawn_wall(i,j):
	var p = dungeon_to_screen(i,j)
	var new_sprite = wall.instance()
	new_sprite.position = p
	$terrain.add_child(new_sprite)

const flr = preload("res://sprites/floor.tscn")
func spawn_floor(i,j):
	var p = dungeon_to_screen(i,j)
	var new_sprite = flr.instance()
	new_sprite.position = p
	$terrain.add_child(new_sprite)

# coordinate conversion from dungeon space to display space
# possibly later: zooming or panning to handle large maps? our maps get pretty large!
const TILE_WIDTH: int = 24
const TILE_HEIGHT: int = 36
func dungeon_to_screen(lx: int, ly: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = lx * TILE_WIDTH + sx + 20
	var scy = ly * TILE_HEIGHT + sy+ 20
	return Vector2(scx,scy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
