tool

extends Sprite

class_name Glyph


const cell_width: int = 64
const cell_height: int = 96
const scale_factor: float = 1.0/8.0
const cell_size: Vector2 = Vector2(cell_width,cell_height)

export var index: int = -1 setget set_index
export var opaque: bool = true setget set_opaque

const opaque_atlas: Texture = preload("res://resources/curses_8_12_scaled_x8.png")
const transparent_atlas: Texture = preload("res://resources/curses_8_12_scaled_x8.png") #FIXME: use an actual transparent atlas

func _ready():
	self.scale = Vector2(scale_factor, scale_factor)
	_refresh()

func set_index(_index: int):
	index = _index
	_refresh()

func set_opaque(_opaque: bool):
	opaque = _opaque
	_refresh()

static func from(s: String) -> int:
	var i = -1
	if s.length() > 0:
		i =  s.to_ascii()[0]
	return i

func _refresh():
	texture = AtlasTexture.new()
	if opaque:
		texture.atlas = opaque_atlas
	else:
		texture.atlas = transparent_atlas

	if index < 0 || index > 255:
#		push_warning("glyph index out of bounds")
		texture.region =  Rect2(0,0,cell_width,cell_height)
	else:
		var nx = (index % 16) * cell_width
# warning-ignore:integer_division
		var ny = (int(index) / int(16)) * cell_height
		texture.region = Rect2(nx, ny, cell_width, cell_height)
