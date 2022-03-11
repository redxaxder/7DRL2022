extends Pickup

class_name Weapon

var weapon_type
var attack: Attack
var knockback_bonus: int = 0

var sword_attack: Attack = preload("res://lib/attacks/sword.gd").new()
var spear_attack: Attack = preload("res://lib/attacks/spear.gd").new()
var broadsword_attack: Attack = preload("res://lib/attacks/broadsword.gd").new()
var axe_attack: Attack = preload("res://lib/attacks/axe.gd").new()
var hammer_attack: Attack = preload("res://lib/attacks/hammer.gd").new()

enum WEAPON_TYPE{ SWORD, SPEAR, BROADSWORD, AXE, HAMMER }

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
			pickup_text = "You pick up a sword."
		WEAPON_TYPE.SPEAR:
			attack = spear_attack
			label = "spear"
			pickup_text = "You pick up a spear."
		WEAPON_TYPE.BROADSWORD:
			attack = broadsword_attack
			label = "broadsword"
			pickup_text = "You pick up a broadsword."
		WEAPON_TYPE.AXE:
			attack = axe_attack
			label = "axe"
			pickup_text = "You pick up an axe."
		WEAPON_TYPE.HAMMER:
			attack = hammer_attack
			label = "hammer"
			pickup_text = "You pick up a hammer."
	attack.southpaw = southpaw

func random_weapon(southpaw: bool = false):
	init(randi() % 5, southpaw)
#	init(WEAPON_TYPE.HAMMER, true)
