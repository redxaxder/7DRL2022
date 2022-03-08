extends Sprite

class_name Actor
signal deschedule(actor)

var constants: Const = preload("res://lib/const.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()

var terrain: Terrain
var combatLog: CombatLog

var pos: Vector2
var player: bool = false
var speed: int = 3

func try_move(i,j) -> bool:
	if terrain.at(i,j) == '#':
		return false
	else:
		pos.x = i
		pos.y = j
		terrain.update_dijkstra_map([pos])		
		position = self.SCREEN.dungeon_to_screen(pos.x ,pos.y)
		return true

func knockback(dir: Vector2):
	var i: int = pos.x + dir.x
	var j: int = pos.y + dir.y
	var c: bool = try_move(i, j)
	while c:
		i = pos.x + dir.x
		j = pos.y + dir.y
		c = try_move(i, j)
