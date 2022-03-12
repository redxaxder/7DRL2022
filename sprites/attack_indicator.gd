extends AnimatedSprite

var lifetime = 0.15

func _ready():
	self.play("flash")

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
