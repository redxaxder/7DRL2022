tool
extends CPUParticles2D
export var rate: int = 0 setget set_rate

func set_rate(light_rate: int):
	rate = light_rate
	var tex = $light.texture.duplicate()
	$light.texture = tex
	$light.texture.fps = 10.0/primes[rate]
	print(primes[rate])
	print($light, $light.texture)

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const primes = [7, 8, 9, 11, 13]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	add_child($light.duplicate())
	$light.texture.fps = 10.0 / primes[randi() % 5]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
