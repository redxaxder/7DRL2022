class_name Dijkstra

var dijkstra_now_budget: int = 2000
var dijkstra_backlog_budget = 2000
var destination_decay: int = 1
var backlog_cliff: int
const big: int = 100000000000000000

var constants: Const = preload("res://lib/const.gd").new()
var terrain: Terrain
var locationService: LocationService

var dijkstra_map = []
var backlog = []
var destination_score: int = 0

func _init(t: Terrain, ls: LocationService, now_budget = 2000, backlog_budget = 2000, decay = 1, cliff = 15):
	terrain = t
	locationService = ls
	dijkstra_now_budget = now_budget
	dijkstra_backlog_budget = backlog_budget
	destination_decay = decay
	backlog_cliff = cliff

func refresh():
	dijkstra_map.clear()
	dijkstra_map.resize(terrain.contents.size())
	destination_score = 0
	for i in range(terrain.contents.size()):
		if terrain.contents[i] == '#':
			dijkstra_map[i] = null
		else:
			dijkstra_map[i] = big

func d_score(v: Vector2) -> int:
	var ix = terrain.to_linear(v.x,v.y)
	return _score(ix) - destination_score

func tick():
	print("tick {0} {1}".format([destination_score, backlog.size()]))
	destination_score -= destination_decay
	backlog = _propagate(backlog, dijkstra_backlog_budget, backlog_cliff)

func update(targets: Array):
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
	var remaining = _propagate(live,dijkstra_now_budget,1)
	backlog += remaining

func _score(ix: int) -> int:
	if ix >= dijkstra_map.size() || ix < 0:
		return big
	var x = dijkstra_map[ix]
	if x == null:
		return big
	return x

func _propagate(live: Array, budget: int, cliff: int) -> Array:
	var next = []
	var tmp
	var w: int = terrain.width
	while live.size() > 0 && budget > 0:
		next.clear()
		budget -= live.size()
		for ix in live:
			if ix >= 0 && ix < dijkstra_map.size() && dijkstra_map[ix] != null:
				var smallest = big
				var neighbors = []
				for t in [ix + w, ix - w, ix + 1, ix - 1]:
					var x = int(t) % int(w)
# warning-ignore:integer_division
					var y = int(t) / int(w)
					if locationService.lookup(Vector2(x,y),constants.PATHING_BLOCKER).size() == 0 && dijkstra_map[ix] != null:
						smallest = min(smallest,_score(t))
						neighbors.append(t)
				if dijkstra_map[ix] > smallest + cliff:
					dijkstra_map[ix] = smallest + 1
					for t in neighbors:
						next.push_back(t)
		tmp = live
		live = next
		next = tmp
	return live
