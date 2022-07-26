extends OffsetSprite

class_name Ragdoll

var ragdoll: Sprite = preload("res://sprites/ragdoll.tscn").instance()
var terrain: Terrain
var bloodbag: bool
var pos: Vector2
var dir: Vector2
var undead: float = -1
var lifetime = 0

var SCREEN = preload("res://lib/screen.gd").new()

func _init(
	_texture: Texture,
	_modulate: Color,
	_self_modulate: Color,
	_bloodbag: bool,
	_anim_screen_offsets: Array,
	_terrain: Terrain,
	_pos: Vector2,
	_dir: Vector2,
	parent: Node
	):
	ragdoll.texture = _texture
	ragdoll.modulate = _modulate
	ragdoll.self_modulate = _self_modulate
	bloodbag = _bloodbag
	anim_screen_offsets = _anim_screen_offsets
	terrain = _terrain
	pos = _pos
	dir = _dir
	add_child(ragdoll)
	parent.add_child(self)

func _process(delta):
	if undead >= 2:
		queue_free()
	if undead >= 0:
		undead += delta
	else:
		if anim_screen_offsets.size() > 10: # failsafe for stuff piling up
			die()
		var did_animation_step = self.animations_step(delta)
		if !did_animation_step:
			die()
		lifetime += delta
		if lifetime >= 3.0:
			die()

func _draw() -> void:
	var p = SCREEN.dungeon_to_screen(pos)
	for v in anim_screen_offsets:
		p += Vector2(v.x,v.y)
	self.position = p

func die():
	if bloodbag:
		terrain.splatter_blood(pos, dir)
		ragdoll.get_child(0).play()
	visible = false
	undead = 0
