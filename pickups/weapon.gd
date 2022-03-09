extends Pickup

class_name Weapon

var weapon_type
var attack: Attack

var sword_attack: Attack = preload("res://lib/attacks/sword.gd").new()
var spear_attack: Attack = preload("res://lib/attacks/sword.gd").new()
var broadsword_attack: Attack = preload("res://lib/attacks/sword.gd").new()

enum WEAPON_TYPE{ SWORD, SPEAR, BROADSWORD }

func _ready():
	._ready()
	is_weapon = true
	sprite = $sprite

func init(type: int, southpaw: bool = false):
	weapon_type = type
	label = "what"
	match weapon_type:
		WEAPON_TYPE.SWORD:
			attack = sword_attack
			label = "sword"
		WEAPON_TYPE.SPEAR:
			attack = spear_attack
			label = "spear"
		WEAPON_TYPE.BROADSWORD:
			attack = broadsword_attack
			label = "broadsword"
		_:
			label = "whaaaat"
			print("whaaaa {0}".format([weapon_type])) 

func random_weapon():
	init(randi() % 3)
