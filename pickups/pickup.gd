extends Node2D

class_name Pickup

var type: int
var sprite: Sprite

var SCREEN = preload("res://lib/screen.gd").new()
var constants = preload("res://lib/const.gd").new()
var is_weapon = false
var label: String = ""
var pickup_text: String = ""
var read_text: String = ""
const player: bool = false
const snooty_array = ["This was better in the original Orcish.", "Ugh, human \"poetry\".", "You call this a sonnet? Human languages aren't capable of iambic pentameter.", "In the Orcish kingdoms, we keep a stockpile of human \"literature\" for use as toilet paper.", "I've read better prose on a restaurant menu!", "This is a combat manual. Doesn't seem to be doing them much good.", "The Orcish kingdoms are actually much more peaceful than this book makes them seem.", "Oh, it's the king's biography. After this is over, I'll be writing the final chapter.", "A human cookbook. Wait, they do WHAT with potatoes?", "Propaganda. The lies they tell about my people.", "A spellbook. Human magic is embarrassingly flashy."]

var locationService: LocationService

const apple_sprite: PackedScene = preload("res://pickups/apple.tscn")
const turkey_sprite: PackedScene = preload("res://pickups/turkey.tscn")
const brandy_sprite: PackedScene = preload("res://pickups/brandy.tscn")
const water_sprite: PackedScene = preload("res://pickups/water.tscn")
const shards_sprite: PackedScene = preload("res://pickups/shards.tscn")
const hot_coal_sprite: PackedScene = preload("res://pickups/hot_coal.tscn")
const book_sprite: PackedScene = preload("res://pickups/book.tscn")

enum ITEM_TYPE{ APPLE, TURKEY, WATER, BRANDY, SHARDS, HOT_COAL, BOOK }

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
		ITEM_TYPE.HOT_COAL:
			sprite = hot_coal_sprite.instance()
			label = "hot coal"
			pickup_text = "You pick up the red-hot coal."
		ITEM_TYPE.BOOK:
			sprite = book_sprite.instance()
			label = "book"
			pickup_text = "You pick up a book."
			read_text = snooty_array[randi() % snooty_array.size()]

	sprite.modulate = Color(0.767029, 1, 0.672304)
	add_child(sprite)

func take():
	sprite.visible = false
	locationService.delete_node(self)

func place(p: Vector2):
	sprite.position = SCREEN.dungeon_to_screen(p)
	sprite.visible = true
	locationService.insert(self, p)

func random_consumable():
	init(randi() % 4)


