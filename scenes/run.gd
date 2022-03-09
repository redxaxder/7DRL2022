extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()

onready var pc: PC = $pc
onready var terrain: Terrain = $terrain
onready var combatLog = $hud/CombatLog
onready var locationService = $LocationService

signal end_player_turn()

const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")
const door_scene = preload("res://sprites/door.tscn")

func _ready():
	terrain.load_random_map()
	connect(constants.END_PLAYER_TURN, $Scheduler, "_end_player_turn")
	pc.connect(constants.PLAYER_DIED, self, "_handle_death")
	var pcpos = Vector2(30,30)
	pc.position = SCREEN.dungeon_to_screen(pcpos.x,pcpos.y)
	pc.terrain = terrain
	pc.combatLog = combatLog
	pc.locationService = locationService
	pc.set_pos(pcpos)
	$Scheduler.register_actor(pc)
	spawn_dynamic_mob(knight_scene, Vector2(10,10))
	spawn_dynamic_mob(monk_scene, Vector2(5, 5))
	spawn_random_consumable(Vector2(15,15))
	spawn_random_weapon(Vector2(20,20))
	spawn_random_weapon(Vector2(20,21))
	spawn_random_weapon(Vector2(20,22))
	spawn_random_weapon(Vector2(20,23))
	spawn_random_weapon(Vector2(20,24))
	spawn_random_weapon(Vector2(20,25))
	spawn_random_weapon(Vector2(20,26))
	
func spawn_door(pos: Vector2):
	spawn_mob(door_scene, pos)

func spawn_dynamic_mob(prefab: PackedScene, pos: Vector2): 
	var mob = spawn_mob(prefab, pos)
	$Scheduler.register_actor(mob)
	mob.connect(constants.DESCHEDULE, $Scheduler, "unregister_actor")
	
func spawn_mob(prefab: PackedScene, pos: Vector2):
	var mob = prefab.instance() as Mob
	mob.pc = pc
	mob.terrain = terrain
	mob.combatLog = combatLog
	mob.locationService = locationService
	mob.set_pos(pos)
	add_child(mob)
	return mob

func spawn_random_consumable(p: Vector2):
	var item = pickup_scene.instance() as Pickup
	item.locationService = locationService
	item.random_consumable()
	add_child(item)
	item.drop(p)

func spawn_random_weapon(p: Vector2):
	var item = weapon_scene.instance() as Weapon
	item.locationService = locationService
	item.random_weapon()
	add_child(item)
	item.drop(p)

var tick = 0

func _unhandled_input(event):
	if $Scheduler.player_turn:
		var acted: bool = false
		var dir: int = -1
		var ppos = pc.get_pos()
		if event.is_action_pressed("left"):
			dir = Dir.DIR.LEFT
		elif event.is_action_pressed("right"):
			dir =  Dir.DIR.RIGHT
		elif event.is_action_pressed("up"):
			dir = Dir.DIR.UP
		elif event.is_action_pressed("down"):
			dir = Dir.DIR.DOWN
		elif event.is_action_pressed("pass"):
			acted = true
		elif event.is_action_pressed("action"):
			acted = true

		if dir >= 0 && !acted:
			acted = pc.try_attack(dir)
		
		if dir >= 0 && !acted:
			var p = pc.get_pos() + DIR.dir_to_vec(dir)
			acted = pc.try_move(p.x,p.y)
			if acted:
				var items = locationService.lookup(p, constants.PICKUPS)
				if items.size() > 0:
					pc.pick_up(items[0],p)
				update_pan(dir)
			
		if acted:
			tick += 1
			pc.tick()
			var status_text = ""
			if pc.pickup != null || pc.weapon != null:
				status_text += "holding:\n"
				if pc.pickup != null:
					status_text += "  {0}\n".format([pc.pickup.label]) 
				if pc.weapon != null:
					status_text += "  {0}\n".format([pc.weapon.label]) 
			if pc.rage > 0:
				status_text += "rage {0} [-{1}]\n".format([pc.rage, pc.rage_decay])
				status_text += "fatigue {0}\n".format([pc.fatigue])
			elif pc.fatigue > 0:
				status_text += "recovery {0}\n".format([pc.recovery])
				status_text += "fatigue {0}\n".format([pc.fatigue])
			$hud/status_panel/status.text = status_text
			emit_signal(constants.END_PLAYER_TURN)

func scale(v: Vector2, s: float) -> Vector2:
	return Vector2(v.x * s, v.y*s)

func update_pan(dir) -> void:
	var pan := DIR.dir_to_vec(dir)

	if abs(pan.x) > 0: # vary pan dist based on tile dimension
		pan = scale(pan, SCREEN.TILE_WIDTH)
	else:
		pan = scale(pan, SCREEN.TILE_HEIGHT)
	var ppos = pc.get_pos()
	$camera.position = SCREEN.dungeon_to_screen(ppos.x, ppos.y) + SCREEN.CENTER + pan

var DeathModal: PackedScene = preload("res://scenes/DeathModal.tscn")
func _handle_death():
	combatLog.say("You have died.")
	combatLog.say("Press space to return to main menu.")
	var d = DeathModal.instance()
	add_child(d)
	set_process_unhandled_input(false)
