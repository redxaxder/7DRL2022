extends OffsetSprite

class_name ActorBody

var terrain: Terrain
var pos: Vector2 = Vector2.ZERO

var on_fire: int

func _ready():
	._ready()

func _draw() -> void:
	var parent = self.get_parent()
	if parent.has_method("get_pos"):
		var ppos = parent.call("get_pos")
		if ppos:
			pos = ppos
	self.position = Screen.dungeon_to_screen(pos)
	for v in anim_screen_offsets:
		 self.position += Vector2(v.x,v.y)

var fire_colors = [Color(1, 0, 0), Color(1, 1, 0)]
func _process(delta):
# warning-ignore:return_value_discarded
	animations_step(delta)
	if on_fire > 0:
		if self_modulate == fire_colors[0]:
			set_color(fire_colors[1])
		else:
			set_color(fire_colors[0])
