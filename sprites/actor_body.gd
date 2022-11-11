extends OffsetSprite

class_name ActorBody

var terrain: Terrain
var pos: Vector2 = Vector2.ZERO

var on_fire: int
var dying: bool = false
var splat_direction: Vector2 = Vector2.ZERO
var bloodbag: bool

func _ready():
	._ready()

func _draw() -> void:
	_update_pos()
	self.position = Screen.dungeon_to_screen(pos)
	for v in anim_screen_offsets:
		 self.position += Vector2(v.x,v.y)

func _update_pos():
	var parent = self.get_parent()
	if parent.has_method("get_pos"):
		var ppos = parent.call("get_pos")
		if ppos:
			pos = ppos

var fire_colors = [Color(1, 0, 0), Color(1, 1, 0)]
func _process(delta):
# warning-ignore:return_value_discarded
	animations_step(delta)
	if on_fire > 0:
		if self_modulate == fire_colors[0]:
			set_color(fire_colors[1])
		else:
			set_color(fire_colors[0])
	if dying && !has_pending_animation():
		die()

func queue_death(dir):
	_update_pos()
	bloodbag = get_parent().is_in_group(Const.BLOODBAG)
	splat_direction = dir
	dying = true

func die():
	if bloodbag:
		terrain.splatter_blood(pos, splat_direction)
	visible = false
	queue_free()
