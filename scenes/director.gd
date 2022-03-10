class_name Director


var constants: Const = preload("res://lib/const.gd").new()

var pc: PC
var terrain: Terrain
var locationService: LocationService
var combatLog: CombatLog
var parent: Node
var scheduler: Scheduler

############templates###################
const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const samurai_scene: PackedScene = preload("res://sprites/Samurai.tscn")
const enemies: Array = [knight_scene, monk_scene, samurai_scene]

const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")

const door_scene: PackedScene = preload("res://sprites/door.tscn")
#########################################

#to use for map selection later
var area_seen: int = 0

func _init(p: PC, t: Terrain, ls: LocationService, cl: CombatLog, n: Node, s: Scheduler):
	pc = p
	terrain = t
	locationService = ls
	combatLog = cl
	parent = n
	scheduler = s
	randomize()


func load_next_map():
	terrain.load_random_map()
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
	activate_room(starting_room)
	# fill the rooms!
	for room in terrain.map.rooms:
		populate_room(room)

func activate_room(room: Vector3):
	terrain.active_rooms[room] = 0 # add it to the dict. the 0 is meaningless.
	for cell in terrain.map.room_cells(room, 1):
		for node in locationService.lookup(cell):
			node.visible = true
			if node.is_in_group(constants.MOBS):
				scheduler.register_actor(node)
				node.connect(constants.DESCHEDULE, scheduler, "unregister_actor")
	terrain.update()

func populate_room(room: Vector3):
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
		if c: spawn_random_enemy(c)
	# add some weapons
	var max_weapons: int = max(sz/2,1)
	for _i in randi() % max_weapons:
		var c = cells.pop_back()
		if c: spawn_random_weapon(c)
	# add some consumables
	var max_consumables: int = max(sz/4,1)
	for _i in randi() % max_consumables:
		var c = cells.pop_back()
		if c: spawn_random_consumable(c)

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
	return door

func spawn_dynamic_mob(prefab: PackedScene, pos: Vector2): 
	if terrain.atv(pos) != '#' && locationService.lookup(pos).size() == 0:
		var mob = spawn_mob(prefab, pos)
		mob.visible = false
		mob.connect(constants.KILLED_BY_PC, pc, "_on_enemy_killed")

func spawn_mob(prefab: PackedScene, pos: Vector2):
	if terrain.atv(pos) != '#' && locationService.lookup(pos).size() == 0:
		var mob = prefab.instance() as Mob
		mob.pc = pc
		mob.terrain = terrain
		mob.combatLog = combatLog
		mob.locationService = locationService
		mob.set_pos(pos)
		parent.add_child(mob)
		return mob

func spawn_random_consumable(p: Vector2):
	if terrain.atv(p) != '#' && locationService.lookup(p).size() == 0:
		var item = pickup_scene.instance() as Pickup
		item.locationService = locationService
		item.random_consumable()
		parent.add_child(item)
		item.place(p)
		item.visible = false

func spawn_random_weapon(p: Vector2):
	if terrain.atv(p) != '#' && locationService.lookup(p).size() == 0:
		var item = weapon_scene.instance()
		item.locationService = locationService
		item.random_weapon(pc.southpaw)
		parent.add_child(item)
		item.place(p)
		item.visible = false

func _on_door_opened(pos: Vector2):
	for room in terrain.map.get_rooms(pos,1):
		activate_room(room)
