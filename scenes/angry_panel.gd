tool
extends Control


var gragient: StyleBoxTexture = preload("res://gragient.tres")
export var alpha: float = 0.3 setget set_alpha


var target_alpha: float
var delay: float

func _ready():
	for c in get_children():
		c.add_stylebox_override("panel", gragient)
	target_alpha = alpha
	delay = 0

func update_gragient():
	var t: GradientTexture = gragient.texture
	var g: Gradient = t.gradient
	var end: Color = g.colors[1]
	end.a = alpha
	g.colors[1] = end
	

func set_alpha(_alpha):
	alpha = _alpha
	update_gragient()

func set_visibility(vis):
	if vis:
		approach_rage_level(0.3, 1)
	else:
		approach_rage_level(0.0, 1)

func approach_rage_level(target, _delay = 1.0):
	set_process(true)
	target_alpha = target
	delay = _delay

func _process(delta):
	if delay <= 0:
		set_alpha(target_alpha)
		set_process(false)
	else:
		var proportion = min(1,delta / delay)
		delay -= delta
		var next = (1 - proportion) * alpha + proportion * target_alpha
		set_alpha(next)
#		if target_aalpha, " ", proportion, " ", delta, " ", delay)
