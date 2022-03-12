extends AnimatedSprite

func _ready():
	self.play("blink")
	$target_back.play("blink")
