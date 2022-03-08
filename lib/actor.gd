extends Sprite

class_name Actor

var constants = preload("res://lib/const.gd").new()
var SCREEN = preload("res://lib/screen.gd").new()

var terrain: Terrain
var combatLog: CombatLog

var pos: Vector2
var player: bool = false
var speed: int = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
