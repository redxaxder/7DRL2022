extends Sprite

class_name Actor
signal deschedule(actor)

var constants: Const = preload("res://lib/const.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()

var terrain: Terrain
var combatLog: CombatLog
var locationService: LocationService

var player: bool = false
var speed: int = 3

func try_move(i,j) -> bool:
	var pos = Vector2(i,j)
	if terrain.at(i,j) == '#':
		return false
	if locationService.lookup(pos, constants.BLOCKER).size() > 0:
		return false
	else:
		set_pos(pos)
		if player:
			terrain.update_dijkstra_map([pos])
		position = self.SCREEN.dungeon_to_screen(pos.x ,pos.y)
		return true

func get_pos(default = null) -> Vector2:
	return locationService.lookup_backward(self, default)

func set_pos(p: Vector2):
	locationService.insert(self,p)

func knockback(dir: Vector2):
	var pos = get_pos()
	var i: int = pos.x + dir.x
	var j: int = pos.y + dir.y
	var c: bool = try_move(i, j)
	while c:
		i = pos.x + dir.x
		j = pos.y + dir.y
		c = try_move(i, j)
