extends "res://lib/mob.gd"


func _ready():
	name = "knight"
	._ready()

func on_turn():
	var d_map = terrain.dijkstra_map
	if pc_adjacent():
		attack()
	else:
		var next = seek_to_player()
		self.pos = next

func attack():
	combatLog.say("the knight stabs you!")
	pc.injure()

func draw(pan: Vector2) -> void:
	var t_pos = SCREEN.dungeon_to_screen(self.pos.x - pan.x,self.pos.y - pan.y)
	self.transform.origin.x = float(t_pos.x)
	self.transform.origin.y = float(t_pos.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
