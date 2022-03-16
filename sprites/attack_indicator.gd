extends Sprite

class_name AttackIndicator


const scene: PackedScene = preload("res://sprites/attack_indicator.tscn")

var SCREEN: Screen = preload("res://lib/screen.gd").new()
var sprite: Sprite = null

var _lifetime = 0.15
var _delay = 0.0

func _init(node: Node, pos: Vector2, delay: float = 0.0, lifetime: float = 0.15):
	sprite = scene.instance()
	add_child(sprite)
	node.add_child(self)
	_delay = delay
	_lifetime = lifetime
	position = SCREEN.dungeon_to_screen(pos)
	if _delay > 0:
		sprite.visible = false

func _process(delta):
	if _delay > 0:
		_delay -= delta
		if _delay <= 0:
			sprite.visible = true
	else:
		_lifetime -= delta
		if _lifetime <= 0:
			sprite.visible = false
			queue_free()
