extends Node2D

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
	var ix = width * y + x
	return contents[ix]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
