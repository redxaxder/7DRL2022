class_name Screen

const TILE_WIDTH: int = 8
const TILE_HEIGHT: int = 12

static func dungeon_to_screen(l: Vector2) -> Vector2:
	var scx = l.x * TILE_WIDTH
	var scy = l.y * TILE_HEIGHT
	return Vector2(scx,scy)
