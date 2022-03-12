extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var DIR: Dir = preload("res://lib/dir.gd").new()
var debuffs = preload("res://lib/debuffs.gd").new()

onready var pc: PC = $pc
onready var terrain = $terrain
onready var combatLog: CombatLog = $hud/CombatLog
onready var locationService = $LocationService
onready var level_up_modal = $hud/level_up_modal
onready var scheduler = $Scheduler
var director: Director
var pc_dijkstra: Dijkstra
var wander_dijkstra: Dijkstra

signal end_player_turn()

const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const samurai_scene: PackedScene = preload("res://sprites/Samurai.tscn")
const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")
const door_scene = preload("res://sprites/door.tscn")

var block_input = 0

# for tempo perk
var tempo_chance: int = 0
var did_tempo: bool = false

func _ready():
	randomize()
	pc.terrain = terrain
	pc.combatLog = combatLog
	pc.locationService = locationService
	pc_dijkstra = Dijkstra.new(terrain, locationService)
	wander_dijkstra = Dijkstra.new(terrain, locationService)
	director = Director.new(pc, terrain, locationService, combatLog, self, scheduler, pc_dijkstra, wander_dijkstra)
	scheduler.register_actor(pc)
	director.load_next_map()
	connect(constants.END_PLAYER_TURN, scheduler, "_end_player_turn")
	pc.connect(constants.PLAYER_DIED, self, "_handle_death")
	pc.connect(constants.PLAYER_DIED, scheduler, "_on_player_death")
	pc.connect(constants.PLAYER_STATUS_CHANGED, self, "update_status")
	level_up_modal.connect("exit_level_up",self,"_on_exit_level_up")
	level_up_modal.connect("pick_perk",pc,"_on_pick_perk")
	level_up_modal.connect("pick_perk",self,"_on_pick_perk")
	pc.connect(constants.PLAYER_LEVEL_UP,self,"_on_level_up")
	pc.connect(constants.EXIT_LEVEL,director,"_on_exit_level")
	pc.connect(constants.RAGE_LIGHTING, $camera, "rage_lighting")	
	update_status()
	update_pan(-1)

var tick = 0

func _unhandled_input(event):
	if block_input > 0:
		return
	if $Scheduler.player_turn:
		var acted: bool = false
		var did_attack: bool = false
		var did_kick: bool = false
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
			#if pc.experience >= pc.experience_needed && pc.rage <= 0:
				do_level_up()
		if dir >= 0 && !acted:
			did_attack = pc.try_attack(dir)
			acted = did_attack
			if did_attack:
				pc.run_speed = 1
		if dir >= 0 && !acted:
			acted = pc.try_kick_furniture(dir)
		if acted: # stop running after attack or kick
			pc.stop_run()
		if dir >= 0 && !acted:
			var run_multiplier: int = 1
			if dir == pc.run_dir:
				pc.run_speed = min(pc.max_run_speed, pc.run_speed + 1)
				run_multiplier = pc.run_speed
			else:
				pc.stop_run()
			var p = pc.get_pos() + DIR.dir_to_vec(dir)
			pc.run_dir = dir
			for _i in range(run_multiplier):
				did_attack = pc.try_attack(dir, true)
				acted = did_attack
				acted = pc.try_kick_furniture(dir) || acted
				var did_move = pc.try_move(dir, run_multiplier)
				acted = did_move || acted
				if did_move:
					var items = locationService.lookup(p, constants.PICKUPS)
					if items.size() > 0:
						pc.pick_up(items[0],p)
					update_pan(dir)
				else:
					pc.stop_run()
					break
			if not acted:
				pc.run_speed = 1
		if acted:
			if did_attack && (randi()%100 < tempo_chance) && !did_tempo:
				print("tempo")
				did_tempo = true
				return
			tick += 1
			pc.tick()
			pc_dijkstra.update([pc.get_pos()])
			pc_dijkstra.tick()
#			print("scheduler: {0}".format([scheduler.actors.keys().size()]))
#			print("ls: {0}".format([locationService.__forward.keys().size()]))
			update_status()
			emit_signal(constants.END_PLAYER_TURN)
			did_tempo = false

func update_status():
	var status_text = ""
	status_text += "exp: {0} / {1}\n".format([pc.experience, pc.experience_needed])
	if pc.experience >= pc.experience_needed && pc.rage == 0:
		status_text += "Press enter to level up\n"
	if pc.run_dir >= 0 and pc.run_speed >= 1:
		status_text += "running speed: {0}\n".format([min(pc.run_speed + 1, pc.max_run_speed)])
	else:
		status_text += "running speed: 1\n"
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
	var effects = pc.debuffs
	for name in effects.keys():
		if effects[name] > 0:
			status_text += "{0} {1}\n".format([name, effects[name]])
	if pc.rage > 0:
		$hud/fatigue_mask.visible = false
	elif pc.fatigue > 0:
		$hud/fatigue_mask.visible = true
	else:
		$hud/fatigue_mask.visible = false
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
	
var WinModal: PackedScene = preload("res://scenes/WinModal.tscn")
func _handle_win():
	combatLog.say("You win!")
	combatLog.say("Press space to return to main menu.")
	var d = WinModal.instance()
	add_child(d)
	set_process_unhandled_input(false)

func do_level_up():
	set_process_unhandled_input(false)
	level_up_modal.visible = true
	level_up_modal.focus()

func _on_pick_perk(p):
	match p.perk_type:
		p.PERK_TYPE.TEMPO:
			tempo_chance += p.bonus
		_:
			pass

func _on_exit_level_up():
	level_up_modal.visible = false
	set_process_unhandled_input(true)
	block_input = 0.2

func _on_level_up():
	#if we can still level up, go back to the level up screen
	if pc.experience > pc.experience_needed:
		do_level_up()

func _process(delta):
	if block_input > 0:
		block_input = max(block_input - delta, 0)
