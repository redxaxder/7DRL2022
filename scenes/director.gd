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


func _init(p: PC, t: Terrain, ls: LocationService, cl: CombatLog, n: Node, s: Scheduler):
	pc = p
	terrain = t
	locationService = ls
	combatLog = cl
	parent = n
	scheduler = s

func spawn_door(pos: Vector2):
	spawn_mob(door_scene, pos)

func spawn_dynamic_mob(prefab: PackedScene, pos: Vector2): 
	if terrain.atv(pos) != '#' && locationService.lookup(pos, constants.BLOCKER).size() == 0:
		var mob = spawn_mob(prefab, pos)
		scheduler.register_actor(mob)
		mob.connect(constants.DESCHEDULE, scheduler, "unregister_actor")
		mob.connect(constants.KILLED_BY_PC, pc, "_on_enemy_killed")

func spawn_mob(prefab: PackedScene, pos: Vector2):
	if terrain.atv(pos) != '#' && locationService.lookup(pos, constants.BLOCKER).size() == 0:
		var mob = prefab.instance() as Mob
		mob.pc = pc
		mob.terrain = terrain
		mob.combatLog = combatLog
		mob.locationService = locationService
		mob.set_pos(pos)
		parent.add_child(mob)
		return mob

func spawn_random_consumable(p: Vector2):
	if terrain.atv(p) != '#' && locationService.lookup(p, constants.BLOCKER).size() == 0:
		var item = pickup_scene.instance() as Pickup
		item.locationService = locationService
		item.random_consumable()
		parent.add_child(item)
		item.place(p)

func spawn_random_weapon(p: Vector2):
	if terrain.atv(p) != '#' && locationService.lookup(p, constants.BLOCKER).size() == 0:
		var item = weapon_scene.instance()
		item.locationService = locationService
		item.random_weapon(pc.southpaw)
		parent.add_child(item)
		item.place(p)
