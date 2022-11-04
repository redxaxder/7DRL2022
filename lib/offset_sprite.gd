extends Node2D

class_name OffsetSprite

var anim_screen_offsets: Array
var anim_speed: float = 7
var die_on_complete: bool = false

var _glyph: Glyph = null
export var glyph_index: int = -1 setget set_index
export var glyph_opaque: bool = false setget set_opaque

func set_index(i):
	glyph_index = i
	_refresh()

func set_opaque(i):
	glyph_opaque = i
	_refresh()

func _ready():
	_refresh()

func animation_delay(duration: float):
	var av = Vector3(0,0,duration)
	anim_screen_offsets.push_back(av)

func pending_animation() -> float:
	var total = 0
	for v in self.anim_screen_offsets:
		total += v.z
	return total / anim_speed

func animations_step(delta) -> bool:
	if anim_screen_offsets.size() > 0:
		if is_zero_approx(anim_screen_offsets[0].z):
			anim_screen_offsets.pop_front()
		else:
			var speed_mult = max(1,anim_screen_offsets.size() - 2)
			var v: Vector3 = anim_screen_offsets[0]
			var dz = anim_speed * delta * speed_mult
			var z1 = max(0,v.z - dz)
			var c = z1 / v.z
			v *= Vector3(c, c, 1)
			v.z = z1
			anim_screen_offsets[0] = v
		update()
		return true
	else:
		return false

func init_glyph():
	if _glyph != null && _glyph.get_parent() == self:
		return
	if _glyph == null:
		for c in get_children():
			if c is Glyph:
				_glyph = c
				return
		_glyph = Glyph.new()
	if _glyph.get_parent() != self:
		add_child(_glyph)

func set_color(color):
	if color != self_modulate:
		self_modulate = color
		_glyph.self_modulate = self_modulate
		_glyph.update()

func _refresh():
	init_glyph()
	_glyph.index = glyph_index
	_glyph.opaque = glyph_opaque
	_glyph.self_modulate = self_modulate
	_glyph.update()
