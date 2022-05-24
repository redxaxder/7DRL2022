extends Sprite

class_name Projectile

var elapsed: float = 0.0
var _delay: float = 0.0
var _sprite: Sprite = null
var _particles: CPUParticles2D = null
var duration: float
var total_duration: float
var source: Vector2
var target: Vector2

var SCREEN = preload("res://lib/screen.gd").new()

func _init(speed: float, from: Vector2, to: Vector2, sprite: Sprite, delay: float = 0.0, particles: CPUParticles2D = null, particle_extra_duration = 3):
	var distance = from.distance_to(to)
	if distance <= 0:
		queue_free()
		return
	source = SCREEN.dungeon_to_screen(from)
	target = SCREEN.dungeon_to_screen(to)
	duration = distance / speed
	total_duration = duration + particle_extra_duration
	sprite.z_index = 20
	add_child(sprite)
	_delay = delay
	_sprite = sprite
	if particles:
		add_child(particles)
		_particles = particles
		particles.emitting = false
	sprite.visible = false

func _process(delta):
	if _delay > 0:
		_delay -= delta
	else:
		_sprite.visible = true
		if _particles && !_particles.emitting:
			_particles.emitting = true
		elapsed += delta
		if duration <= 0.001:
			queue_free()
			return
		var c: float = min(elapsed / duration, 1)
		position = (1 - c) * source + c * target
		if elapsed >= duration:
			_sprite.visible = false
			if _particles:
				_particles.emitting = false
		if elapsed >= total_duration:
			queue_free()
