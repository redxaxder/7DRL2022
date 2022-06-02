class_name Dir

enum DIR{ UP, LEFT, DOWN, RIGHT }

static func dir_to_vec(dir: int) -> Vector2:
	match dir:
		DIR.UP:
			return Vector2(0, -1)
		DIR.DOWN:
			return Vector2(0,1)
		DIR.LEFT:
			return Vector2(-1,0)
		DIR.RIGHT:
			return Vector2(1,0)
	return Vector2(0,0)

static func rot(dir: int, clockwise: bool = false) -> int:
	if clockwise:
		return (dir + 3) % 4
	else:
		return (dir + 1) % 4

static func invert(dir: int) -> int:
	return (dir + 2) % 4
