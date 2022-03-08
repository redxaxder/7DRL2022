#extends Pickup
#
#class_name Weapon
#
#
#var weapon_type
##var attack: Attack
#
#enum WEAPON_TYPE{ SWORD, SPEAR, BROADSWORD}
#
#func _ready():
#	._ready()
#	is_weapon = true
#
##func init(type: int):
##	weapon_type = type
##	match weapon_type:
##		WEAPON_TYPE.SWORD:
##			attack = sword_attack
##		WEAPON_TYPE.SPEAR:
##			attack = spear_attack
##		WEAPON_TYPE.BROADSWORD:
##			attack = broadsword_attack
#
#func random_weapon():
#	init(randi() % 3)
