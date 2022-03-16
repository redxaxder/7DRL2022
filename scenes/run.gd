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
var ortho_dijkstra: Dijkstra
var enemy_dijkstra: Dijkstra

signal end_player_turn()

const knight_scene: PackedScene = preload("res://sprites/knight.tscn")
const monk_scene: PackedScene = preload("res://sprites/monk.tscn")
const samurai_scene: PackedScene = preload("res://sprites/Samurai.tscn")
const pickup_scene: PackedScene = preload("res://pickups/pickup.tscn")
const weapon_scene: PackedScene = preload("res://pickups/weapon.tscn")
const door_scene = preload("res://sprites/door.tscn")

var block_input = 0

# for perks
var tempo_chance: int = 0
var did_tempo: bool = false
var overrun_perk: bool = false

var relax_chain: int = 0

func _ready():
	randomize()
	pc.terrain = terrain
	pc.combatLog = combatLog
	pc.locationService = locationService
	pc_dijkstra = Dijkstra.new(terrain, locationService)
	wander_dijkstra = Dijkstra.new(terrain, locationService)
	ortho_dijkstra = Dijkstra.new(terrain, locationService, 1000, 1000, 1, 15)
	enemy_dijkstra = Dijkstra.new(terrain, locationService, 5, 1000, 1, 10)
	director = Director.new(pc,
		terrain,
		locationService,
		combatLog,
		self,
		scheduler,
		pc_dijkstra,
		wander_dijkstra,
		ortho_dijkstra,
		enemy_dijkstra)
	scheduler.register_actor(pc)
	director.load_next_map()
	connect(constants.END_PLAYER_TURN, scheduler, "_end_player_turn")
	connect(constants.END_PLAYER_TURN, self, "_help_director_out") # kludge
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
	combatLog.say(prologue[0])


var tick = 0

func _unhandled_input(event):
	if block_input > 0:
		return
	if $Scheduler.player_turn:
		var acted: bool = false
		var did_attack: bool = false
		var did_kick: bool = false
		var did_relax: bool = false
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
			did_relax = do_relax()
			pc.stop_run()
		elif event.is_action_pressed("action"):
			acted = pc.consume()
			if acted: pc.stop_run()
		elif event.is_action_pressed("level_up"):
			if pc.experience >= pc.experience_needed && pc.rage <= 0:
				do_level_up()
		if dir >= 0 && !acted:
			did_attack = pc.try_attack(dir)
			acted = did_attack
			if did_attack:
				pc.stop_run()
				if overrun_perk:
					pc.run_dir = dir
					update_status()
		if dir >= 0 && !acted:
			acted = pc.try_kick_furniture(dir)
			if acted: pc.stop_run()
		if dir >= 0 && !acted:
			acted = pc.try_move(dir)
			if acted:
				update_pan(dir)
		if acted:
			if did_attack && (randi()%100 < tempo_chance) && !did_tempo:
				did_tempo = true
				return
			if !did_relax:
				relax_chain = 0
			tick += 1
			if tick < prologue.size():
				combatLog.say(prologue[tick])
			pc.tick()
			update_pc_dijkstras()
			enemy_dijkstra.tick()
			update_status()
			emit_signal(constants.END_PLAYER_TURN)
			did_tempo = false
			print_stray_nodes()

const prologue: Array = [\
	"I once was a king, just and merciful,", \
	"o'er peaceful lands I ruled with love.", \
	"Yet dark and treacherous the minds of idle men,", \
	"By boredom and lies were my foundations cracked.", \
	"Yet 'til that fateful day I still clinged, to memories of glories past;", \
	"And with mine idle hands, invited the slaughter of all I loved.", \
	"Love they took for weakness,", \
	"compassion they took for gullibility,", \
	"and justice they called tyranny.", \
	"Now as I stoke my rage, and feel anew strengths millennia past, I pray:", \
	"Blood for the Blood God, Skulls for the Skull Throne!", \
	]

const relax_messages: Array = [\
	"You try to gain control of your anger.", \
	"Rage is the death of me that loves all things.", \
	"Rage is the end of me that desires aught but destruction.", \
	"Rage is the end that brings total obliteration.", \
	"I will face my rage, and turn it against itself.", \
	"I will permit it to make a battleground of my mind.", \
	"And when it has spent itself, its control shall wain,", \
	"And I will regain the eye that sees Beauty and Preservation.", \
	"Where once was rage, now exists peace, and the nothingness that allows me to be...", \
	]

const relax_bonuses: Array = [0,5,10,10,100,100,1000,1000,1000000000000]
func do_relax() -> bool:
	if pc.rage <= 0:
		return false
	combatLog.say(relax_messages[relax_chain])
	var calm = relax_bonuses[relax_chain]
	if calm > 0:
		pc.calm(calm)
	relax_chain = min(1 + relax_chain, relax_messages.size() - 1)
	return true

func update_pc_dijkstras():
	var pos = pc.get_pos()
	pc_dijkstra.update([pos])
	pc_dijkstra.tick()
	var ortho_targets = []
	for v in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		for i in range(1, 6):
			var target = pos + (i * v)
			if terrain.is_wall(target):
				break
			ortho_targets.push_back(target)
	ortho_dijkstra.update(ortho_targets)
	ortho_dijkstra.tick()

func update_status():
	var status_text = ""
	status_text += "exp: {0} / {1}\n".format([pc.experience, pc.experience_needed])
	if pc.experience >= pc.experience_needed:
		$hud/status_panel/vbox/level_up.visible = true
		if pc.rage == 0:
			$hud/status_panel/vbox/level_up.text = "PRESS ENTER TO LEVEL UP"
			$hud/status_panel/vbox/level_up.modulate = Color(0.219608, 1, 0)
		else:
			$hud/status_panel/vbox/level_up.text = "CALM DOWN TO LEVEL UP"
			$hud/status_panel/vbox/level_up.modulate = Color(1, 1, 1)
	else:
		$hud/status_panel/vbox/level_up.visible = false
	if pc.next_run_speed() > 1:
		status_text += "running speed: {0}\n".format([pc.next_run_speed()])
	if pc.pickup != null || pc.weapon != null:
		status_text += "holding:\n"
		if pc.pickup != null && !pc.southpaw:
			status_text += "  {0} [space]\n".format([pc.pickup.label])
		if pc.weapon != null:
			status_text += "  {0}\n".format([pc.weapon.label])
		if pc.pickup != null && pc.southpaw:
			status_text += "  {0} [space]\n".format([pc.pickup.label])
	if pc.rage > 0:
		status_text += "rage {0} [-{1}]\n".format([pc.rage, pc.rage_decay])
		status_text += "fatigue {0}\n".format([pc.fatigue])
	elif pc.fatigue > 0:
		status_text += "recovery {0}\n".format([pc.recovery])
		status_text += "fatigue {0}\n".format([pc.fatigue])
	if pc.is_drunk:
		status_text += "drunk\n"
	var effects = pc.debuffs
	for name in effects.keys():
		if effects[name] > 0:
			status_text += "{0} {1}\n".format([name, effects[name]])
	if pc.rage > 0:
		$hud/fatigue_mask.visible = false
		var pending_text = ""
		var pending = pc.pending_debuffs()
		for name in pending.keys():
			if pending[name] > 0:
				pending_text += "{0} {1}\n".format([name, pending[name]])
		if pending_text != "":
			pending_text = "pending debuffs\n" + pending_text
		$hud/status_panel/vbox/pending.text = pending_text
	elif pc.fatigue > 0:
		$hud/fatigue_mask.visible = true
		$hud/status_panel/vbox/pending.text = ""
	else:
		$hud/fatigue_mask.visible = false
		$hud/status_panel/vbox/pending.text = ""
	$hud/status_panel/vbox/status.text = status_text


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

func _on_pick_perk(p: Perk):
	match p.perk_type:
		p.PERK_TYPE.TEMPO:
			tempo_chance += p.bonus
		p.PERK_TYPE.OVERRUN:
			overrun_perk = true
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

var camera_offset: Vector2 = Vector2(0,0)
var camera_target: Vector2 = Vector2(0,0)
func _process(delta):
	if block_input > 0:
		block_input = max(block_input - delta, 0)
	if camera_offset.length() > 0:
		camera_offset = camera_offset * pow(0.3,delta)
		camera_offset = camera_offset.move_toward(Vector2(0,0), SCREEN.TILE_HEIGHT * delta * 2)
	$camera.position = camera_target + camera_offset
	$camera.zoom = zoom_level(pc.rage) * Vector2(1,1)

func zoom_level(x: float) -> float:
	return 0.3 + (0.7 / (1 + exp(-2.5 + (x/300))))

func scale(v: Vector2, s: float) -> Vector2:
	return Vector2(v.x * s, v.y*s)

func update_pan(dir) -> void:
	var pan := DIR.dir_to_vec(dir)
	var run = pc.next_run_speed()
	if abs(pan.x) > 0: # vary pan dist based on tile dimension
		pan = pan * (SCREEN.TILE_WIDTH * run)
	else:
		pan = pan * (SCREEN.TILE_HEIGHT * run)
	var old_target = camera_target
	var ppos = pc.get_pos()
	var new_target = SCREEN.dungeon_to_screen(ppos) + pan
	camera_offset += old_target - new_target
	camera_target = new_target
	if dir < 0:
		camera_offset = Vector2(0,0)

func _help_director_out():
	#not sure why rooms sometimes fail to activate, so..
	#pretend a door just opened at pc's current location
	director._on_door_opened(pc.get_pos())
