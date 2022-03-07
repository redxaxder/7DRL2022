const TILE_WIDTH: int = 24
const TILE_HEIGHT: int = 36

func dungeon_to_screen(lx: int, ly: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = lx * TILE_WIDTH + sx + 20
	var scy = ly * TILE_HEIGHT + sy+ 20
	return Vector2(scx,scy)
