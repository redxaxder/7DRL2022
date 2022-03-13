extends Node

class_name Pickup

var type: int
var sprite: Sprite

var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var is_weapon = false
var label: String = ""
var pickup_text: String = ""
const player: bool = false

var locationService: LocationService

const apple_sprite: PackedScene = preload("res://pickups/apple.tscn")
const turkey_sprite: PackedScene = preload("res://pickups/turkey.tscn")
const brandy_sprite: PackedScene = preload("res://pickups/brandy.tscn")
const water_sprite: PackedScene = preload("res://pickups/water.tscn")
const shards_sprite: PackedScene = preload("res://pickups/shards.tscn")

enum ITEM_TYPE{ APPLE, TURKEY, WATER, BRANDY, SHARDS }

func _ready():
	randomize()
	add_to_group(constants.PICKUPS)

func init(item_type: int):
	type = item_type
	match type:
		ITEM_TYPE.APPLE:
			sprite = apple_sprite.instance()
			label = "apple"
			pickup_text = "You pick up an apple."
		ITEM_TYPE.TURKEY:
			sprite = turkey_sprite.instance()
			label = "turkey"
			pickup_text = "You pick up a turkey."
		ITEM_TYPE.WATER:
			sprite = water_sprite.instance()
			label = "water"
			pickup_text = "You pick up a bottle of water."
		ITEM_TYPE.BRANDY:
			sprite = brandy_sprite.instance()
			label = "brandy"
			pickup_text = "You pick up a bottle of brandy."
		ITEM_TYPE.SHARDS:
			sprite = shards_sprite.instance()
			label = "glass shards"
			pickup_text = "You pick up a handful of glass shards."
	sprite.modulate = Color(1, 0.984314, 0.639216)
	add_child(sprite)

func take():
	sprite.visible = false
	locationService.delete_node(self)

func place(p: Vector2):
	sprite.position = SCREEN.dungeon_to_screen(p.x,p.y)
	sprite.visible = true
	locationService.insert(self, p)

func random_consumable():
	init(randi() % 4)


