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
	# this needs to be realtime because call_group has a one-frame delay
	# that delay causes die() to be called twice for things that are on fire
	# double dying crashes the game
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, Const.ON_FIRE, "on_fire")
