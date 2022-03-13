extends Sprite

const anim_frames: int = 7
var anim_frame: int = 0
var red: bool = true

func _ready() -> void:
	$sound.play()

func _process(delta: float) -> void:
	update()

func _draw() -> void:
	if red:
		self.modulate = Color(1, 0, 0)
	else:
		self.modulate = Color(1, 1, 0)
	anim_frame = min(anim_frames, anim_frame + 1)
	if anim_frame == anim_frames:
		anim_frame = 0
		red = !red

