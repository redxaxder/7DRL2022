extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var x = 0
var y = 0

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
	

# coordinate conversion from dungeon space to display space
const TILE_WIDTH: int = 24
const TILE_HEIGHT: int = 36
func dungeon_to_screen(x: int, y: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = x * TILE_WIDTH + sx
	var scy = y * TILE_HEIGHT + sy
	return Vector2(scx,scy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
