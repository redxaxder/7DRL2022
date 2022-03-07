extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var x = 5
var y = 5
var tick = 0

func _unhandled_input(event):
	var acted = false
	if event.is_action_pressed("left"):
		x -= 1
		acted = true
	elif event.is_action_pressed("right"):
		x += 1
		acted = true
	elif event.is_action_pressed("up"):
		y -= 1
		acted = true
	elif event.is_action_pressed("down"):
		y += 1
		acted = true
	
	if acted:
		$pc.position = dungeon_to_screen(x,y)
		tick += 1
		$gui/status.text = "tick {0}\n x {1}\n y {2}".format([tick,x,y])
	
# coordinate conversion from dungeon space to display space
# possibly later: zooming or panning to handle large maps? our maps get pretty large!
const TILE_WIDTH: int = 24
const TILE_HEIGHT: int = 36
func dungeon_to_screen(lx: int, ly: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = lx * TILE_WIDTH + sx
	var scy = ly * TILE_HEIGHT + sy
	return Vector2(scx,scy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
