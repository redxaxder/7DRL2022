const TILE_WIDTH: int = 24
const TILE_HEIGHT: int = 36

const VIEWPORT_WIDTH: int = 42
const VIEWPORT_HEIGHT: int = 14

const CENTER_X: int = VIEWPORT_WIDTH / 2
const CENTER_Y: int = VIEWPORT_HEIGHT / 2

func dungeon_to_screen(lx: int, ly: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = lx * TILE_WIDTH + sx + 20
	var scy = ly * TILE_HEIGHT + sy+ 20
	return Vector2(scx,scy)
