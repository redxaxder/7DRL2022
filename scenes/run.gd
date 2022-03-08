extends Node2D


var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()

onready var pc: PC = $pc
onready var terrain: Terrain = $terrain
onready var combatLog = $hud/CombatLog

signal end_player_turn()

const knight_scene: PackedScene = preload("res://sprites/knight.tscn")

func _ready():
	terrain.load_random_map()
	connect(constants.END_PLAYER_TURN, $Scheduler, "_end_player_turn")
	pc.connect(constants.PLAYER_DIED, self, "_handle_death")
	pc.position = SCREEN.dungeon_to_screen(pc.pos.x,pc.pos.y)
	pc.terrain = terrain
	pc.combatLog = combatLog
	$Scheduler.register_actor(pc)
	spawn_mob(knight_scene, Vector2(10,10))

func spawn_mob(prefab: PackedScene, pos: Vector2): 
	var mob = prefab.instance() as Mob
	mob.pos = pos
	mob.pc = pc
	mob.terrain = terrain
	mob.combatLog = combatLog
	add_child(mob)
	$Scheduler.register_actor(mob)
	mob.connect(constants.DESCHEDULE, $Scheduler, "unregister_actor")

var pan  = Vector2(0,0)

var tick = 0

enum DIR{ UP, DOWN, LEFT, RIGHT}

func _unhandled_input(event):
	if $Scheduler.player_turn:
		var acted: bool = false
		var moved: bool = false
		var dir: int = DIR.UP
		if event.is_action_pressed("left"):
			acted = pc.try_move(pc.pos.x-1,pc.pos.y)
			if acted: 
				update_pan(DIR.LEFT)
				moved = true
				dir = DIR.LEFT
		elif event.is_action_pressed("right"):
			acted = pc.try_move(pc.pos.x+1,pc.pos.y)
			if acted: 
				update_pan(DIR.RIGHT)
				moved = true
				dir = DIR.RIGHT
		elif event.is_action_pressed("up"):
			acted = pc.try_move(pc.pos.x,pc.pos.y-1)
			if acted: 
				update_pan(DIR.UP)
				moved = true
				dir = DIR.UP
		elif event.is_action_pressed("down"):
			acted = pc.try_move(pc.pos.x,pc.pos.y+1)
			if acted: 
				update_pan(DIR.DOWN)
				moved = true
				dir = DIR.DOWN
		elif event.is_action_pressed("pass"):
			acted = true
		elif event.is_action_pressed("action"):
			acted = true

		if acted:
			tick += 1
			pc.tick()
			var status_text = ""
			if pc.rage > 0:
				status_text += "rage {0} [-{1}]\n".format([pc.rage, pc.rage_decay])
				status_text += "fatigue {0}\n".format([pc.fatigue])
			elif pc.fatigue > 0:
				status_text += "recovery {0}\n".format([pc.recovery])
				status_text += "fatigue {0}\n".format([pc.fatigue])
			$hud/status_panel/status.text = status_text
			get_tree().call_group(constants.MOBS, "is_hit", dir_to_vec(dir))
			emit_signal(constants.END_PLAYER_TURN)


const look_distance_h: int = 6
const look_distance_v: int = 3

func dir_to_vec(dir: int) -> Vector2:
	match dir:
		DIR.UP:
			return Vector2(0, -1)
		DIR.DOWN:
			return Vector2(0,1)
		DIR.LEFT:
			return Vector2(-1,0)
		DIR.RIGHT:
			return Vector2(1,0)
	return Vector2(0,0)

func scale(v: Vector2, s: float) -> Vector2:
	return Vector2(v.x * s, v.y*s)

func update_pan(dir) -> void:
	var pan := dir_to_vec(dir)

	if abs(pan.x) > 0: # vary pan dist based on tile dimension
		pan = scale(pan, SCREEN.TILE_WIDTH)
	else:
		pan = scale(pan, SCREEN.TILE_HEIGHT)
	$camera.position = SCREEN.dungeon_to_screen(pc.pos.x, pc.pos.y) + SCREEN.CENTER + pan

func _handle_death():
	combatLog.say("ouch")
	print("oof")
#	set_process_unhandled_input(false)
#	get_parent().set_process_unhandled_input(true)
#	queue_free()
