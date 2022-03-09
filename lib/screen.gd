class_name Screen

const TILE_WIDTH: int = 8
const TILE_HEIGHT: int = 12

func dungeon_to_screen(lx: int, ly: int
		 , sx: int = 0, sy: int = 0) -> Vector2:
	var scx = lx * TILE_WIDTH + sx
	var scy = ly * TILE_HEIGHT + sy
	return Vector2(scx,scy)
