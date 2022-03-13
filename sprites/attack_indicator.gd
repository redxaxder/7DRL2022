extends AnimatedSprite

class_name AttackIndicator


const scene: PackedScene = preload("res://sprites/attack_indicator.tscn")

var SCREEN: Screen = preload("res://lib/screen.gd").new()
var sprite: AnimatedSprite = null

var _lifetime = 0.15
var _delay = 0.0

func _init(node: Node, pos: Vector2, delay: float = 0.0, lifetime: float = 0.15):
	print("init")
	sprite = scene.instance()
	add_child(sprite)
	node.add_child(self)
	_delay = delay
	_lifetime = lifetime
	position = SCREEN.dungeon_to_screen(pos.x, pos.y)
	if _delay > 0:
		sprite.visible = false
	else:
		self.play("flash")
		print("play")

func _process(delta):
	if _delay > 0:
		_delay -= delta
		if _delay <= 0:
			sprite.play("flash")
			sprite.visible = true
	else:
		_lifetime -= delta
		if _lifetime <= 0:
			queue_free()
