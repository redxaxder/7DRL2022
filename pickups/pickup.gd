extends Node

class_name Pickup

var t: int
var sprite: Sprite

var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var is_weapon = false

const apple_sprite: PackedScene = preload("res://pickups/apple.tscn")
const turkey_sprite: PackedScene = preload("res://pickups/turkey.tscn")
const brandy_sprite: PackedScene = preload("res://pickups/brandy.tscn")
const water_sprite: PackedScene = preload("res://pickups/water.tscn")
const weapon_sprite: PackedScene = preload("res://pickups/weapon.tscn")

enum ITEM_TYPE{ APPLE, TURKEY, WATER, BRANDY }

func _ready():
	randomize()
	add_to_group(constants.PICKUPS)

func init(item_type: int):
	t = item_type
	match t:
		ITEM_TYPE.APPLE:
			sprite = apple_sprite.instance()
		ITEM_TYPE.TURKEY:
			sprite = turkey_sprite.instance()
		ITEM_TYPE.WATER:
			sprite = water_sprite.instance()
		ITEM_TYPE.BRANDY:
			sprite = apple_sprite.instance()
	add_child(sprite)

func take():
	sprite.visible = false

func drop(p: Vector2):
	sprite.position = SCREEN.dungeon_to_screen(p.x,p.y)
	sprite.visible = true

func random_consumable():
	init(randi() % 4)


