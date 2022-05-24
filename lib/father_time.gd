extends Actor
class_name FatherTime

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func _ready():
	label = "father_time"
	tiebreaker = 101
	speed = 3

func on_turn():
	get_tree().call_group(Const.ON_FIRE, "on_fire")
