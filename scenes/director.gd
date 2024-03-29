class_name Director


var constants = preload("res://lib/const.gd").new()

var pc: Actor
var terrain
var locationService: LocationService
var combatLog: CombatLog
var parent: Node
var scheduler
var pc_dijkstra
var wander_dijkstra
var ortho_dijkstra
var enemy_dijkstra
var exits: Array = []
var king_spawned: bool = false
var __

############templates###################
const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const samurai_scene: PackedScene = preload("res://sprites/Samurai.tscn")
const ranger_scene: PackedScene = preload("res://sprites/ranger.tscn")
const archaeologist_scene: PackedScene = preload("res://sprites/archaeologist.tscn")
const king_scene: PackedScene = preload("res://sprites/king.tscn")
const wizard_scene: PackedScene = preload("res://sprites/wizard.tscn")
const rogue_scene: PackedScene = preload("res://sprites/rogue.tscn")
const tourist_scene: PackedScene = preload("res://sprites/tourist.tscn")
const healer_scene: PackedScene = preload("res://sprites/healer.tscn")
const priest_scene: PackedScene = preload("res://sprites/priest.tscn")
const valkyrie_scene: PackedScene = preload("res://sprites/valkyrie.tscn")
const caveman_scene: PackedScene = preload("res://sprites/caveman.tscn")
const enemies: Array = [
		{ "scene": caveman_scene, "min_depth": 1, "weight": 1, "max_depth": 1 },
		{ "scene": knight_scene, "min_depth": 1,"weight": 6, "max_depth": 4 },
		{ "scene": wizard_scene, "min_depth": 1, "weight": 9, "max_depth": 5 },
		{ "scene": monk_scene, "min_depth": 1,"weight": 6, "max_depth": 5 },
		{ "scene": samurai_scene, "min_depth": 2,"weight": 6, "max_depth": 6 },
		{ "scene": rogue_scene, "min_depth": 2, "weight": 9, "max_depth": 6 },
		{ "scene": ranger_scene, "min_depth": 2,"weight": 6, "max_depth": 6 },
		{ "scene": tourist_scene, "min_depth": 3,"weight": 1, "max_depth": 3 },
		{ "scene": healer_scene, "min_depth": 3,"weight": 4, "max_depth": 6 },
		{ "scene": priest_scene, "min_depth": 3,"weight": 3, "max_depth": 6 },
		{ "scene": archaeologist_scene, "min_depth": 4,"weight": 1, "max_depth": 6},
		{ "scene": valkyrie_scene, "min_depth": 4,"weight": 6, "max_depth": 6 },
	]

const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")
const target_scene: PackedScene = preload("res://sprites/Target.tscn")

const door_scene: PackedScene = preload("res://sprites/door.tscn")
const table_scene: PackedScene = preload("res://sprites/furniture/table.tscn")
const chair_scene: PackedScene = preload("res://sprites/furniture/chair.tscn")
const brazier_scene: PackedScene = preload("res://sprites/furniture/brazier.tscn")
const bookcase_scene: PackedScene = preload("res://sprites/furniture/bookcase.tscn")
var furniture: Array = [
	table_scene,
	brazier_scene
]
var wall_furniture: Array = [
	bookcase_scene
]
#########################################

#to use for map selection later
var area_seen: int = 0
var level = 1

var populated_rooms = {}

func _init(p,
		t,
		ls: LocationService,
		cl: CombatLog,
		n: Node,
		s,
		pcd: Dijkstra,
		wd: Dijkstra,
		od: Dijkstra,
		ed: Dijkstra):
	pc = p
	terrain = t
	locationService = ls
	combatLog = cl
	parent = n
	scheduler = s
	pc_dijkstra = pcd
	wander_dijkstra = wd
	ortho_dijkstra = od
	enemy_dijkstra = ed
	randomize()

const area_targets = [2000,2500,3000,3500,4000,4000]
func decide_map(lvl: int) -> int:
	var base_area = 0
	for i in lvl:
		if i < area_targets.size():
			base_area += area_targets[i]
	var target_area = base_area - area_seen
	var small_area = target_area / 2.0
	var big_area = target_area * 1.5
	var selector: int = int(randf() * (big_area - small_area) + small_area)
	selector = int(0.66 * (selector - 1000))
	if true: # TODO: remove this when adding rest of maps
		selector -= (selector % 100)
	selector = int(max(selector, 100))
	return selector

func refresh_pc_dijkstras():
	pc_dijkstra.refresh()
	ortho_dijkstra.refresh()

func load_next_map():
	populated_rooms = {}
	exits = []
	for torch_pos in terrain.torch_map.keys():
		terrain.remove_light_at(torch_pos)
	var map_id = decide_map(level)
	terrain.load_map(map_id, level)
	refresh_pc_dijkstras()
	enemy_dijkstra.refresh()
	area_seen += terrain.width * terrain.height
	var starting_room: Vector3 = Vector3(10000,10000,100000)
	for room in terrain.map.rooms:
		if room.z > 1:
			room_doors(room)
			if room.z < starting_room.z:
				starting_room = room
	#put pc in starting room
	var candidates = terrain.map.room_cells(starting_room)
	var start = candidates[randi() % candidates.size()]
	pc.set_pos(start)
	populated_rooms[starting_room] = 0
	activate_room(starting_room)
	wander_dijkstra.refresh()
	wander_dijkstra.update(exits)

func activate_room(room: Vector3):
#	if !populated_rooms.has(room):
#		populate_room(room)
#	if terrain.active_rooms.has(room):
#		return
	terrain.active_rooms[room] = 0 # add it to the dict. the 0 is meaningless.
	for cell in terrain.map.room_cells(room, 1):
		for node in locationService.lookup(cell):
			node.visible = true
			if node.is_in_group(constants.MOBS):
				scheduler.register_actor(node)
	for cell in terrain.map.room_outline(room):
		if terrain.atv(cell) == 'W':
			terrain.add_light_at(cell)
	terrain.update()
	for neighbor in terrain.map.adjacent_rooms(room):
		populate_room(neighbor)
	wander_dijkstra.update(exits)

func populate_room(room: Vector3):
	if populated_rooms.has(room):
		return
	populated_rooms[room] = 0
	#place doors as needed
	room_doors(room)
	var sz = int(room.z)
	#fill with enemies
	var area = sz * sz
	var spawn_denom = 9 - level
	var max_enemies = int(max(area / spawn_denom, 1))
	var min_enemies = max_enemies / 3
	var min_furniture: int = int(sz / 2)
# warning-ignore:integer_division
	var max_furniture: int = int(max((int(area) / int(20)) - 1, 1))
	var cells = terrain.map.room_cells(room)
	cells.shuffle()
		# spawn the king if on level 6
	if level == 6:
		var chance: float = 1.0/(terrain.map.rooms.size() - populated_rooms.size() + 1)
		if rand_range(0, 1) < chance and not king_spawned:
			var c = cells.pop_back()
			spawn_dynamic_mob(king_scene, c)
			king_spawned = true
	for _i in min_enemies + (randi() % int(max(max_enemies - min_enemies,1))):
		var c = cells.pop_back()
		if c && terrain.is_floor(c): spawn_random_enemy(c)
	for _i in min_furniture + (randi() % int(max(max_furniture - min_furniture,1))):
		var c = cells.pop_back()
		spawn_random_furniture(c, room)
	# add some weapons
	var max_weapons := int(max(sz/2,1))
	for _i in randi() % max_weapons:
		var c = cells.pop_back()
		if c && terrain.is_floor(c): spawn_random_weapon(c)
	# add some consumables
	var max_consumables := int(max(sz/4,1))
	for _i in randi() % max_consumables:
		var c = cells.pop_back()
		if c && terrain.is_floor(c): spawn_random_consumable(c)

func spawn_random_enemy(pos: Vector2):
	var enemy_pool = []
	for e in enemies:
		if e.min_depth <= level and e.max_depth >= level:
			for _ix in e.weight:
				enemy_pool.push_back(e.scene)
	var enemy = enemy_pool[randi() % enemy_pool.size()]
	return spawn_dynamic_mob(enemy, pos)

func room_doors(room: Vector3):
	for cell in terrain.map.room_outline(room):
		if terrain.is_door(cell):
			__ = spawn_door(cell)

func spawn_door(pos: Vector2) -> Actor:
	if locationService.lookup(pos).size() > 0:
		return null
	var door = door_scene.instance() as Actor
	door.locationService = locationService
	door.combatLog = combatLog
	door.terrain = terrain
	door.pc = pc
	door.set_pos(pos)
	parent.add_child(door)
	door.visible = false
	door.connect(constants.DOOR_OPENED,self,"_on_door_opened")
	door.connect("thump",pc,"_on_thump")
	exits.push_back(pos)
	exits.push_back(pos + Vector2(1, 0))
	exits.push_back(pos + Vector2(-1, 0))
	exits.push_back(pos + Vector2(0, 1))
	exits.push_back(pos + Vector2(0, -1))
	return door

func spawn_dynamic_mob(prefab: PackedScene, pos: Vector2):
	if terrain.is_floor(pos) && locationService.lookup(pos).size() == 0:
		var mob = spawn_mob(prefab, pos)
		mob.visible = false
		mob.connect(constants.KILLED_BY_PC, pc, "_on_enemy_killed")
		if mob.label == "ranger":
			mob.connect(constants.REMOVE_TARGET, self, "_on_remove_target")
			mob.connect(constants.TELEGRAPH, self, "_on_telegraph")
		if mob.label == "His Highness":
			mob.connect("you_win", parent, "_handle_win")
		if mob.label == "valkyrie":
			mob.connect("valkyrie_summon", self, "_on_valkyrie_summon")
		return mob

func spawn_mob(prefab: PackedScene, pos: Vector2):
	if terrain.is_floor(pos) && locationService.lookup(pos).size() == 0:
		var mob = prefab.instance() as Mob
		mob.pc = pc
		mob.connect("thump",pc,"_on_thump")
		mob.terrain = terrain
		mob.combatLog = combatLog
		mob.locationService = locationService
		mob.pc_dijkstra = pc_dijkstra
		mob.wander_dijkstra = wander_dijkstra
		mob.ortho_dijkstra = ortho_dijkstra
		mob.enemy_dijkstra = enemy_dijkstra
		mob.set_pos(pos)
		parent.add_child(mob)
		mob.update()
		return mob

func spawn_random_consumable(p: Vector2):
	if terrain.is_floor(p) && locationService.lookup(p).size() == 0:
		var item = pickup_scene.instance() as Pickup
		item.locationService = locationService
		item.random_consumable()
		parent.add_child(item)
		item.place(p)
		item.visible = false

func spawn_random_furniture(p: Vector2, room: Vector3):
	if not (p && terrain.is_floor(p) && locationService.lookup(p).size() == 0):
		return
	var draw_from
	if terrain.map.is_in_room(p, room, -1):
		draw_from = furniture
	elif terrain.map.is_in_room(p, room, 0):
		draw_from = wall_furniture
		for i in range(0, 3):
			for j in range(0, 3):
				var pp = p + Vector2(i-1, j-1)
				if terrain.is_door(pp):
					return
	else:
		return
	draw_from.shuffle()
	var item = draw_from[0].instance()
	item.connect("thump",pc,"_on_thump")
	item.locationService = locationService
	item.visible = false
	item.combatLog = combatLog
	item.terrain = terrain
	item.pc = pc
	parent.add_child(item)
	if item.label == "table":
		for _i in range(4):
			if rand_range(0, 1) < 0.25:
				# spawn a chair next to the table
				var candidates = [p + Vector2(1, 0), p + Vector2(-1, 0), p + Vector2(0, 1), p + Vector2(0, -1)]
				var fc = []
				for c in candidates:
					if terrain.is_floor(c) && locationService.lookup(c).size() == 0:
						fc.push_back(c)
				if fc.size() > 0:
					fc.shuffle()
					var chair = chair_scene.instance()
					chair.connect("thump",pc,"_on_thump")
					chair.locationService = locationService
					chair.visible = false
					chair.combatLog = combatLog
					chair.terrain = terrain
					parent.add_child(chair)
					chair.set_pos(fc[0])
	item.set_pos(p)


func spawn_random_weapon(p: Vector2):
	if terrain.is_floor(p) && locationService.lookup(p).size() == 0:
		var item = weapon_scene.instance()
		item.locationService = locationService
		item.random_weapon(pc.southpaw)
		parent.add_child(item)
		item.place(p)
		item.visible = false

func _on_remove_target(target: Target):
	if target != null:
		locationService.delete_node(target)
		target.queue_free()

func _on_telegraph(pos: Vector2, ranger: Mob):
	var target = target_scene.instance()
	target.locationService = locationService
	target.set_pos(pos)
	parent.add_child(target)
	ranger.target_obj = target

func _on_door_opened(pos: Vector2):
	exits.erase(pos)
	for room in terrain.map.get_rooms(pos,1):
		activate_room(room)

func _on_exit_level():
	for b in locationService.__backward.keys():
		locationService.delete_node(b)
		if b is Actor:
			if !b.player:
				b.queue_free()
		else:
			b.queue_free()
	scheduler.clear()
	level += 1
	load_next_map()
	terrain.update()
	scheduler.register_actor(pc)
	pc.update()

func _on_valkyrie_summon(targets: Array):
	for target in targets:
		var stuff_at = locationService.lookup(target, constants.BLOCKER)
		if not terrain.is_wall(target) and stuff_at.size() == 0 and terrain.in_active_room(target):
			var nmes = []
			for e in enemies:
				nmes.push_back(e.scene)
			var nme = nmes[randi() % nmes.size()]
			var mob = spawn_dynamic_mob(nme, target)
			if mob != null:
				mob.visible = true
				scheduler.register_actor(mob)
				if mob.label == "valkyrie":
					mob.end_ready()
