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

func room_outline(room: Vector3) -> Array:
	var results = []
	for i in room.z + 1:
		results.append(Vector2(room.x + i, room.y)) # top
		results.append(Vector2(room.x + i, room.y + room.z)) # bottom
	for i in range(1,room.z):
		results.append(Vector2(room.x, room.y + i)) # left
		results.append(Vector2(room.x + room.z, room.y + i)) # tight
	return results

func adjacent_rooms(room: Vector3) -> Array:
	var results = []
	for r in rooms:
		if room_distance(r,room) == 1:
			results.append(r)
	return results

func room_distance(r: Vector3, s: Vector3) -> int:
	var r_left = r.x
	var r_right = r.x + r.z - 1
	var s_left = s.x
	var s_right = s.x + s.z - 1
	var dx
	if r_right < s_left:
		dx = s_left - r_right
	elif s_right < r_left:
		dx = r_left - s_right
	else:
		dx = 0
	var r_top = r.y
	var r_bot = r.y + r.z - 1
	var s_top = s.y
	var s_bot = s.y + s.z - 1
	var dy
	if r_bot < s_top:
		dy = s_top - r_bot
	elif s_bot < r_top:
		dy = r_top - s_bot
	else:
		 dy = 0
	return int(max(dx,dy))


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
	var rooms2: Array = []
	for r in rooms:
		var r2 = r
		r2.y = height - r.z - r.y
		rooms2.append(r2)
	rooms = rooms2

func flip_h():
	var rooms2: Array = []
	for r in rooms:
		var r2 = r
		r2.x = width - r.z - r.x
		rooms2.append(r2)
	rooms = rooms2
