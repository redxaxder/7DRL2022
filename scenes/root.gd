extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()

onready var pc = $pc
onready var terrain = $terrain

signal end_player_turn(pan)

export(PackedScene) var knight_scene

func _ready():
	terrain.load_random_map()
	connect(constants.END_PLAYER_TURN, $Scheduler, "_end_player_turn")
	pc.position = SCREEN.dungeon_to_screen(pc.pos.x - pan.x,pc.pos.y - pan.y)
	pc.terrain = terrain
	pc.combatLog = $CombatLog
	$Scheduler.register_actor(pc)
	$CombatLog.label = $hud/log_panel/log
	$CombatLog.say("welcome to the dungeon")
	spawn_mob(knight_scene, Vector2(10,10))

func spawn_mob(prefab: PackedScene, pos: Vector2): 
	var mob = prefab.instance() as Mob
	mob.pos = pos
	mob.pc = pc
	mob.terrain = terrain
	mob.combatLog = $CombatLog
	add_child(mob)
	$Scheduler.register_actor(mob)

var pan  = Vector2(0,0)

var tick = 0

enum DIR{ UP, DOWN, LEFT, RIGHT}

func _unhandled_input(event):
	if $Scheduler.player_turn:
		var acted = false
		if event.is_action_pressed("left"):
			acted = try_move(pc.pos.x-1,pc.pos.y)
			if acted: update_pan(DIR.LEFT)
		elif event.is_action_pressed("right"):
			acted = try_move(pc.pos.x+1,pc.pos.y)
			if acted: update_pan(DIR.RIGHT)
		elif event.is_action_pressed("up"):
			acted = try_move(pc.pos.x,pc.pos.y-1)
			if acted: update_pan(DIR.UP)
		elif event.is_action_pressed("down"):
			acted = try_move(pc.pos.x,pc.pos.y+1)
			if acted: update_pan(DIR.DOWN)
		elif event.is_action_pressed("pass"):
			acted = true
		elif event.is_action_pressed("action"):
			acted = true
		
		if acted:
			pc.position = SCREEN.dungeon_to_screen(pc.pos.x - pan.x,pc.pos.y - pan.y)
			tick += 1
			pc.tick()
			$hud/status_panel/text.text = "rage {0}\nfatigue {1}\nrecovery {2}".format([pc.rage, pc.fatigue, pc.recovery])
			terrain.update_dijkstra_map([pc.pos])
			emit_signal(constants.END_PLAYER_TURN, pan, pc.pos, terrain)


const look_distance_h: int = 6
const look_distance_v: int = 3

func update_pan(dir) -> void:
	match dir:
		DIR.UP:
			pan = Vector2(pc.pos.x-SCREEN.CENTER_X, pc.pos.y-look_distance_v-SCREEN.CENTER_Y)
		DIR.DOWN:
			pan = Vector2(pc.pos.x-SCREEN.CENTER_X,pc.pos.y+look_distance_v-SCREEN.CENTER_Y)
		DIR.LEFT:
			pan = Vector2(pc.pos.x-SCREEN.CENTER_X-look_distance_h,pc.pos.y-SCREEN.CENTER_Y)
		DIR.RIGHT:
			pan = Vector2(pc.pos.x-SCREEN.CENTER_X+look_distance_h,pc.pos.y-SCREEN.CENTER_Y)
	terrain.pan = pan
	terrain.update()
	

func try_move(i,j) -> bool:
	if terrain.at(i,j) == '#':
		return false
	else:
		pc.pos.x = i
		pc.pos.y = j
		return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
