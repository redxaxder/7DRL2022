extends Node

class_name Pickup

var t: int
var sprite: Sprite

var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var is_weapon = false
var label: String = ""

var locationService: LocationService

const apple_sprite: PackedScene = preload("res://pickups/apple.tscn")
const turkey_sprite: PackedScene = preload("res://pickups/turkey.tscn")
const brandy_sprite: PackedScene = preload("res://pickups/brandy.tscn")
const water_sprite: PackedScene = preload("res://pickups/water.tscn")

enum ITEM_TYPE{ APPLE, TURKEY, WATER, BRANDY }

func _ready():
	randomize()
	add_to_group(constants.PICKUPS)

func init(item_type: int):
	t = item_type
	match t:
		ITEM_TYPE.APPLE:
			sprite = apple_sprite.instance()
			label = "apple"
		ITEM_TYPE.TURKEY:
			sprite = turkey_sprite.instance()
			label = "turkey"
		ITEM_TYPE.WATER:
			sprite = water_sprite.instance()
			label = "water"
		ITEM_TYPE.BRANDY:
			sprite = apple_sprite.instance()
			label = "brandy"
	add_child(sprite)

func take():
	sprite.visible = false
	locationService.delete_node(self)

func drop(p: Vector2):
	sprite.position = SCREEN.dungeon_to_screen(p.x,p.y)
	sprite.visible = true
	locationService.insert(self, p)

func random_consumable():
	init(randi() % 4)


