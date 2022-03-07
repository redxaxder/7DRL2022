extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()

func _ready():
	$terrain.load_map(1)


var x = 3
var y = 3

var pan  = Vector2(0,0)

var tick = 0

enum DIR{ UP, DOWN, LEFT, RIGHT}

func _unhandled_input(event):
	var acted = false
	if event.is_action_pressed("left"):
		acted = try_move(x-1,y)
		if acted: update_pan(DIR.LEFT)
	elif event.is_action_pressed("right"):
		acted = try_move(x+1,y)
		if acted: update_pan(DIR.RIGHT)
	elif event.is_action_pressed("up"):
		acted = try_move(x,y-1)
		if acted: update_pan(DIR.UP)
	elif event.is_action_pressed("down"):
		acted = try_move(x,y+1)
		if acted: update_pan(DIR.DOWN)
	elif event.is_action_pressed("pass"):
		acted = true
	elif event.is_action_pressed("action"):
		acted = true
	
	if acted:
		$pc.position = SCREEN.dungeon_to_screen(x - pan.x,y - pan.y)
		tick += 1
		$hud/status_panel/text.text = "tick {0}\n x {1}\n y {2}".format([tick,x,y])


const look_distance_h: int = 6
const look_distance_v: int = 3

func update_pan(dir) -> void:
	match dir:
		DIR.UP:
			pan = Vector2(x-SCREEN.CENTER_X, y-look_distance_v-SCREEN.CENTER_Y)
		DIR.DOWN:
			pan = Vector2(x-SCREEN.CENTER_X,y+look_distance_v-SCREEN.CENTER_Y)
		DIR.LEFT:
			pan = Vector2(x-SCREEN.CENTER_X-look_distance_h,y-SCREEN.CENTER_Y)
		DIR.RIGHT:
			pan = Vector2(x-SCREEN.CENTER_X+look_distance_h,y-SCREEN.CENTER_Y)
	$terrain	.pan = pan
	$terrain._draw()
	$terrain.update()
	

func try_move(i,j) -> bool:
	if $terrain.at(i,j) == '#':
		return false
	else:
		x = i
		y = j
		return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
