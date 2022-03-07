extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()

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
		$pc.position = SCREEN.dungeon_to_screen(x,y)
		tick += 1
		$gui/status_panel/text.text = "tick {0}\n x {1}\n y {2}".format([tick,x,y])

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
