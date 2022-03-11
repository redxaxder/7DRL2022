class_name Director


var constants = preload("res://lib/const.gd").new()

var pc: Actor
var terrain: Terrain
var locationService: LocationService
var combatLog: CombatLog
var parent: Node
var scheduler
var pc_dijkstra
var wander_dijkstra
var exits: Array = []

############templates###################
const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const samurai_scene: PackedScene = preload("res://sprites/Samurai.tscn")
const ranger_scene: PackedScene = preload("res://sprites/ranger.tscn")
const archaeologist_scene: PackedScene = preload("res://sprites/archaeologist.tscn")
const enemies: Array = [
	knight_scene, 
	monk_scene, 
	samurai_scene, 
	ranger_scene, 
	archaeologist_scene
	]

const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")
const target_scene: PackedScene = preload("res://sprites/Target.tscn")

const door_scene: PackedScene = preload("res://sprites/door.tscn")
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
wd: Dijkstra):
	pc = p
	terrain = t
	locationService = ls
	combatLog = cl
	parent = n
	scheduler = s
	pc_dijkstra = pcd
	wander_dijkstra = wd
	randomize()

const area_targets = [2000,3000,4000,6000,10000,18000]
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
		selector = selector - (selector % 100)
	return selector
	
func load_next_map():
	populated_rooms = {}
	exits = []
	var map_id = decide_map(level)
	terrain.load_map(map_id)
	pc_dijkstra.refresh()
	area_seen += terrain.width * terrain.height
	print("map id: {0} \n area: {1}".format([map_id, terrain.width * terrain.height]))
	print(area_seen)
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
	activate_room(starting_room)
	populated_rooms[starting_room] = 0
	wander_dijkstra.refresh()
	wander_dijkstra.update(exits)

func activate_room(room: Vector3):
	terrain.active_rooms[room] = 0 # add it to the dict. the 0 is meaningless.
	for cell in terrain.map.room_cells(room, 1):
		for node in locationService.lookup(cell):
			node.visible = true
			if node.is_in_group(constants.MOBS):
				scheduler.register_actor(node)
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
	var max_enemies: int = max(area / 3, 1)
	var cells = terrain.map.room_cells(room)
	cells.shuffle()
	for _i in 1 + (randi() % max_enemies):
		var c = cells.pop_back()
		if c && terrain.is_floor(c): spawn_random_enemy(c)
	# add some weapons
	var max_weapons: int = max(sz/2,1)
	for _i in randi() % max_weapons:
		var c = cells.pop_back()
		if c && terrain.is_floor(c): spawn_random_weapon(c)
	# add some consumables
	var max_consumables: int = max(sz/4,1)
	for _i in randi() % max_consumables:
		var c = cells.pop_back()
		if c && terrain.is_floor(c): spawn_random_consumable(c)

func spawn_random_enemy(pos: Vector2):
	var enemy = enemies[randi() % enemies.size()]
	spawn_dynamic_mob(enemy, pos)

func room_doors(room: Vector3):
	for cell in terrain.map.room_outline(room):
		if terrain.atv(cell) == '.':
			spawn_door(cell)

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
	exits.push_back(pos)
	exits.push_back(pos + Vector2(1, 0))
	exits.push_back(pos + Vector2(-1, 0))
	exits.push_back(pos + Vector2(0, 1))
	exits.push_back(pos + Vector2(0, -1))
	return door

func spawn_dynamic_mob(prefab: PackedScene, pos: Vector2): 
	if !terrain.is_wall(pos) && locationService.lookup(pos).size() == 0:
		var mob = spawn_mob(prefab, pos)
		mob.visible = false
		mob.connect(constants.KILLED_BY_PC, pc, "_on_enemy_killed")
		if mob.label == "ranger":
			mob.connect(constants.REMOVE_TARGET, self, "_on_remove_target")
			mob.connect(constants.TELEGRAPH, self, "_on_telegraph")

func spawn_mob(prefab: PackedScene, pos: Vector2):
	if !terrain.is_wall(pos) && locationService.lookup(pos).size() == 0:
		var mob = prefab.instance() as Mob
		mob.pc = pc
		mob.terrain = terrain
		mob.combatLog = combatLog
		mob.locationService = locationService
		mob.pc_dijkstra = pc_dijkstra
		mob.wander_dijkstra = wander_dijkstra
		mob.set_pos(pos)
		parent.add_child(mob)
		return mob

func spawn_random_consumable(p: Vector2):
	if !terrain.is_wall(p) && locationService.lookup(p).size() == 0:
		var item = pickup_scene.instance() as Pickup
		item.locationService = locationService
		item.random_consumable()
		parent.add_child(item)
		item.place(p)
		item.visible = false

func spawn_random_weapon(p: Vector2):
	if !terrain.is_wall(p) && locationService.lookup(p).size() == 0:
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
