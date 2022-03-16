extends AnimatedSprite

class_name Target

var constants = preload("res://lib/const.gd").new()
var SCREEN: Screen = preload("res://lib/screen.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()

var locationService: LocationService

const player: bool = false
var label: String = ""
const door: bool = false
const blocking: bool = false

func _ready():
	label = "target"
	self.play("targetting")

func get_pos(default = null) -> Vector2:
	return locationService.lookup_backward(self, default)

func set_pos(p: Vector2):
	locationService.insert(self,p)

func _process(delta):
		update()

func _draw() -> void:
	var pos = get_pos()
	if pos != null:
		self.position = self.SCREEN.dungeon_to_screen(pos)
