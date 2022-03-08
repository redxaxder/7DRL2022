class_name Screen

const TILE_WIDTH: int = 8
const TILE_HEIGHT: int = 12

const VIEWPORT_WIDTH: int = 42 * 3
const VIEWPORT_HEIGHT: int = 14 * 3

const CENTER := Vector2(VIEWPORT_WIDTH / 2, VIEWPORT_HEIGHT / 2)
const CENTER_X: int = VIEWPORT_WIDTH / 2
const CENTER_Y: int = VIEWPORT_HEIGHT / 2

func dungeon_to_screen(lx: int, ly: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = lx * TILE_WIDTH + sx + 20
	var scy = ly * TILE_HEIGHT + sy+ 20
	return Vector2(scx,scy)
