class_name Dijkstra

const dijkstra_map_now_limit = 30
const dijkstra_map_later_budget = 400

var terrain: Terrain


var dijkstra_map = []
var destination_score: int = 0
const destination_decay: int = 1
const big: int = 100000000000000000

func _init(t: Terrain):
	terrain = t
	dijkstra_map.clear()
	dijkstra_map.resize(terrain.contents.size())
	for i in range(terrain.contents.size()):
		if terrain.contents[i] == '#':
			dijkstra_map[i] = null
		else:
			dijkstra_map[i] = big

func d_score(v: Vector2) -> int:
	var ix = terrain.to_linear(v.x,v.y)
	if ix >= dijkstra_map.size() || ix < 0:
		return 100000
	var x = dijkstra_map[ix]
	if x == null:
		return 100000
	return x

func update_map(targets: Array):
	var live = []
	var w: int = terrain.width
	for t in targets:
		var ix = terrain.to_linear(t.x,t.y)
		if ix >= 0 && ix < dijkstra_map.size():
			dijkstra_map[ix] = destination_score
			live.push_back(ix + w)
			live.push_back(ix - w)
			live.push_back(ix + 1)
			live.push_back(ix - 1)
	propagate(live)

func score(ix: int) -> int:
	if ix >= dijkstra_map.size() || ix < 0:
		return big
	var x = dijkstra_map[ix]
	if x == null:
		return big
	return x

func propagate(live: Array, budget = 8000, cliff = 1) -> Array:
	var next = []
	var tmp
	var w: int = terrain.width
	while live.size() > 0 && budget > 0:
		next.clear()
		budget -= live.size()
		for ix in live:
			if ix >= 0 && ix < dijkstra_map.size() && dijkstra_map[ix] != null:
				var smallest = big
				for t in [ix + w, ix - w, ix + 1, ix - 1]:
					smallest = min(smallest,score(t))
				if dijkstra_map[ix] > smallest + cliff:
					dijkstra_map[ix] = smallest + 1
					for t in [ix + w, ix - w, ix + 1, ix - 1]:
						next.push_back(t)
		tmp = live
		live = next
		next = tmp
	return live
