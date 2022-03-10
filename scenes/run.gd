extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()

onready var pc: PC = $pc
onready var terrain: Terrain = $terrain
onready var combatLog: CombatLog = $hud/CombatLog
onready var locationService: LocationService = $LocationService
onready var level_up_modal = $hud/level_up_modal
onready var scheduler = $Scheduler
var director: Director

signal end_player_turn()

const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const samurai_scene: PackedScene = preload("res://sprites/Samurai.tscn")
const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")
const door_scene = preload("res://sprites/door.tscn")


func _ready():
	randomize()
#	terrain.load_random_map()
#	terrain.blood_map[terrain.to_linear(13, 9)] = 31
#	terrain.blood_map[terrain.to_linear(13, 10)] = 21
#	terrain.blood_map[terrain.to_linear(13, 11)] = 11
#	terrain.blood_map[terrain.to_linear(13, 12)] = 1
	connect(constants.END_PLAYER_TURN, scheduler, "_end_player_turn")
	pc.connect(constants.PLAYER_DIED, self, "_handle_death")
	pc.connect(constants.PLAYER_STATUS_CHANGED, self, "update_status")
	level_up_modal.connect("exit_level_up",self,"_on_exit_level_up")
	level_up_modal.connect("pick_perk",pc,"_on_pick_perk")
	var pcpos = Vector2(30,30)
	pc.position = SCREEN.dungeon_to_screen(pcpos.x,pcpos.y)
	pc.terrain = terrain
	pc.combatLog = combatLog
	pc.locationService = locationService
	director = Director.new(pc, terrain, locationService, combatLog, self, scheduler)
	director.load_next_map()
	pc.set_pos(pcpos)
	scheduler.register_actor(pc)
	director.spawn_dynamic_mob(knight_scene, Vector2(10,10))
	director.spawn_dynamic_mob(monk_scene, Vector2(5, 5))
	director.spawn_dynamic_mob(samurai_scene, Vector2(15, 15))
	director.spawn_random_consumable(Vector2(15,15))
	director.spawn_random_consumable(Vector2(16,15))
	director.spawn_random_consumable(Vector2(17,15))
	director.spawn_random_consumable(Vector2(18,15))
	director.spawn_random_consumable(Vector2(19,15))
	director.spawn_random_consumable(Vector2(20,15))
	director.spawn_random_weapon(Vector2(20,20))
	director.spawn_random_weapon(Vector2(20,21))
	director.spawn_random_weapon(Vector2(20,22))
	director.spawn_random_weapon(Vector2(20,23))
	director.spawn_random_weapon(Vector2(20,24))
	director.spawn_random_weapon(Vector2(20,25))
	director.spawn_random_weapon(Vector2(20,26))
	update_status()
	update_pan(-1)

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
			acted = pc.consume()
		elif event.is_action_pressed("level_up"):
#			if pc.experience >= pc.experience_needed:
				do_level_up()
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
			update_status()
			emit_signal(constants.END_PLAYER_TURN)

func update_status():
	var status_text = ""
	status_text += "exp: {0} / {1}\n".format([pc.experience, pc.experience_needed])
	if pc.experience >= pc.experience_needed && pc.rage == 0:
		status_text += "Press enter to level up\n"
	if pc.pickup != null || pc.weapon != null:
		status_text += "holding:\n"
		if pc.pickup != null && !pc.southpaw:
			status_text += "  {0}\n".format([pc.pickup.label]) 
		if pc.weapon != null:
			status_text += "  {0}\n".format([pc.weapon.label]) 
		if pc.pickup != null && pc.southpaw:
			status_text += "  {0}\n".format([pc.pickup.label]) 
	if pc.rage > 0:
		status_text += "rage {0} [-{1}]\n".format([pc.rage, pc.rage_decay])
		status_text += "fatigue {0}\n".format([pc.fatigue])
	elif pc.fatigue > 0:
		status_text += "recovery {0}\n".format([pc.recovery])
		status_text += "fatigue {0}\n".format([pc.fatigue])
	$hud/status_panel/status.text = status_text


func scale(v: Vector2, s: float) -> Vector2:
	return Vector2(v.x * s, v.y*s)

func update_pan(dir) -> void:
	var pan := DIR.dir_to_vec(dir)

	if abs(pan.x) > 0: # vary pan dist based on tile dimension
		pan = scale(pan, SCREEN.TILE_WIDTH)
	else:
		pan = scale(pan, SCREEN.TILE_HEIGHT)
	var ppos = pc.get_pos()
	$camera.position = SCREEN.dungeon_to_screen(ppos.x, ppos.y) + pan

var DeathModal: PackedScene = preload("res://scenes/DeathModal.tscn")
func _handle_death():
	combatLog.say("You have died.")
	combatLog.say("Press space to return to main menu.")
	var d = DeathModal.instance()
	add_child(d)
	set_process_unhandled_input(false)

func do_level_up():
	set_process_unhandled_input(false)
	level_up_modal.visible = true
	level_up_modal.set_process_unhandled_input(true)
	level_up_modal.focus()

func _on_exit_level_up():
	level_up_modal.set_process_unhandled_input(false)
	level_up_modal.visible = false
	set_process_unhandled_input(true)
