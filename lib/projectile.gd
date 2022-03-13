extends Sprite

class_name Projectile

var elapsed: float = 0.0
var _delay: float = 0.0
var _sprite: Sprite = null
var duration: float
var source: Vector2
var target: Vector2

var SCREEN = preload("res://lib/screen.gd").new()

func _init(speed: float, from: Vector2, to: Vector2, sprite: Sprite, delay: float = 0.0):
	var distance = from.distance_to(to)
	if distance <= 0:
		queue_free()
		return
	source = SCREEN.dungeon_to_screen(from.x, from.y)
	target = SCREEN.dungeon_to_screen(to.x, to.y)		
	duration = distance / speed
	sprite.z_index = 20
	add_child(sprite)
	_delay = delay
	_sprite = sprite
	if _delay > 0:
		sprite.visible = false

func _process(delta):
	if _delay > 0:
		_delay -= delta
		if _delay <= 0:
			_sprite.visible = true
	else:
		elapsed += delta
		if duration <= 0.001:
			queue_free()
			return
		var c: float = elapsed / duration
		position = (1 - c) * source + c * target
		if elapsed >= duration:
			queue_free()
