extends Sprite

class_name OffsetSprite

var anim_screen_offsets: Array
var anim_speed: float = 7
var die_on_complete: bool = false

func animation_delay(duration: float):
	var av = Vector3(0,0,duration)
	anim_screen_offsets.push_back(av)

func pending_animation() -> float:
	var total = 0
	for v in self.anim_screen_offsets:
		total += v.z
	return total

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
