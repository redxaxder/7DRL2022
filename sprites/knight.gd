extends Sprite

var ai = preload("res://lib/ai.gd").new()
var constants = preload("res://lib/const.gd").new()
var SCREEN = preload("res://lib/screen.gd").new()

# Declare member variables here. Examples:
var pos: Vector2
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(constants.MOBS)
	
func _on_turn(current: Sprite, pc_x: int, pc_y: int):
	var d_map = $terrain.dijkstra_map(Vector2(current.pos.x, current.pos.y), [Vector2(pc_x, pc_y)], $terrain.contents)
	var next = ai.seek_to_player(pc_x, pc_y, current.pos.x, current.pos.y, d_map)
	current.pos = next	
	
func draw(pan: Vector2) -> void:
	var t_pos = SCREEN.dungeon_to_screen(self.pos.x - pan.x,self.pos.y - pan.y)
	print(t_pos)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
