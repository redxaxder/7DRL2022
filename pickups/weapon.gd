extends Pickup

class_name Weapon

var weapon_type
var attack: Attack

var sword_attack: Attack = preload("res://lib/attacks/sword.gd").new()
var spear_attack: Attack = preload("res://lib/attacks/spear.gd").new()
var broadsword_attack: Attack = preload("res://lib/attacks/broadsword.gd").new()

enum WEAPON_TYPE{ SWORD, SPEAR, BROADSWORD }

func _ready():
	._ready()
	is_weapon = true
	sprite = $sprite

func init(type: int, southpaw: bool = false):
	weapon_type = type
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
	attack.southpaw = southpaw

func random_weapon(southpaw: bool = false):
	init(randi() % 3, southpaw)
