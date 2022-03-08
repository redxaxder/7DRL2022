extends Sprite

var ai = preload("res://lib/ai.gd").new()
var constants = preload("res://lib/const.gd").new()
var SCREEN = preload("res://lib/screen.gd").new()

# Declare member variables here. Examples:
var pos: Vector2
const player: bool = false
const speed: int = 3
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(constants.MOBS)
	
func on_turn(pc_x: int, pc_y: int, terrain):
	var d_map = terrain.dijkstra_map
	var next = ai.seek_to_player(pc_x, pc_y, self.pos.x, self.pos.y, d_map, terrain)
	self.pos = next	
	
func draw(pan: Vector2) -> void:
	var t_pos = SCREEN.dungeon_to_screen(self.pos.x - pan.x,self.pos.y - pan.y)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
