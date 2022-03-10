extends Resource
export(int) var width
export(int) var height
export(int) var size
export(Array) var rooms

class_name Map

func is_in_room(p: Vector2, room: Vector3, fudge: int = 0) -> bool:
	var inside = true
	inside = inside && (p.x + fudge > room.x)
	inside = inside && (p.x - fudge < room.x + room.z)
	inside = inside && (p.y + fudge > room.y)
	inside = inside && (p.y - fudge < room.y + room.z)
	return inside

func room_cells(room: Vector3, fudge: int = 0) -> Array:
	var cells = []
	for i in range(room.x + 1 - fudge, room.x + room.z + fudge):
		for j in range(room.y + 1 - fudge, room.y + room.z + fudge):
			cells.append(Vector2(i,j))
	return cells

func count_rooms(p: Vector2, fudge: int = 0) -> int:
	var n = 0
	for r in rooms:
		if is_in_room(p, r, fudge):
			n += 1
	return n

func get_rooms(p: Vector2, fudge: int = 0) -> Array:
	var results = []
	for r in rooms:
		if is_in_room(p, r, fudge):
			results.append(r)
	return results

func flip_v():
	var rooms2: Array
	for r in rooms:
		var r2 = r
		r2.y = height - r.z - r.y
		rooms2.append(r2)
	rooms = rooms2

func flip_h():
	var rooms2: Array
	for r in rooms:
		var r2 = r
		r2.x = width - r.z - r.x
		rooms2.append(r2)
	rooms = rooms2
