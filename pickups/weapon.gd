extends Pickup

class_name Weapon

var weapon_type
var attack: Attack
var knockback_bonus: int = 0

var sword_attack: Attack = preload("res://lib/attacks/sword.gd").new()
const sword_sprite: PackedScene = preload("res://pickups/weapons/sword.tscn")

var spear_attack: Attack = preload("res://lib/attacks/spear.gd").new()
const spear_sprite: PackedScene = preload("res://pickups/weapons/spear.tscn")

var broadsword_attack: Attack = preload("res://lib/attacks/broadsword.gd").new()
const broadsword_sprite: PackedScene = preload("res://pickups/weapons/broadsword.tscn")

var axe_attack: Attack = preload("res://lib/attacks/axe.gd").new()
const axe_sprite: PackedScene = preload("res://pickups/weapons/axe.tscn")

var hammer_attack: Attack = preload("res://lib/attacks/hammer.gd").new()
const hammer_sprite: PackedScene = preload("res://pickups/weapons/hammer.tscn")

var whip_attack: Attack = preload("res://lib/attacks/whip.gd").new()
const whip_sprite: PackedScene = preload("res://pickups/weapons/whip.tscn")

var torch_attack: Attack = preload("res://lib/attacks/torch.gd").new()
const torch_sprite: PackedScene = preload("res://pickups/weapons/torch.tscn")

enum WEAPON_TYPE{ SWORD, SPEAR, BROADSWORD, AXE, HAMMER, WHIP, TORCH }

func _ready():
	._ready()
	is_weapon = true

func init(type: int, southpaw: bool = false):
	weapon_type = type
	match weapon_type:
		WEAPON_TYPE.SWORD:
			attack = sword_attack
			label = "longsword"
			pickup_text = "You pick up a longsword."
			sprite = sword_sprite.instance()
		WEAPON_TYPE.SPEAR:
			attack = spear_attack
			label = "spear"
			pickup_text = "You pick up a spear."
			sprite = spear_sprite.instance()
		WEAPON_TYPE.BROADSWORD:
			attack = broadsword_attack
			label = "broadsword"
			pickup_text = "You pick up a broadsword."
			sprite = broadsword_sprite.instance()
		WEAPON_TYPE.AXE:
			attack = axe_attack
			label = "axe"
			pickup_text = "You pick up an axe."
			sprite = axe_sprite.instance()
		WEAPON_TYPE.HAMMER:
			attack = hammer_attack
			label = "hammer"
			pickup_text = "You pick up a hammer."
			sprite = hammer_sprite.instance()
		WEAPON_TYPE.WHIP:
			attack = whip_attack
			label = "whip"
			pickup_text = "You pick up a whip."
			sprite = whip_sprite.instance()
		WEAPON_TYPE.TORCH:
			attack = torch_attack
			label = "torch"
			pickup_text = "You pick up a torch."
			sprite = torch_sprite.instance()
	sprite.modulate = Color(0.956643, 0.778013, 1)
	add_child(sprite)
	attack.southpaw = southpaw

func random_weapon(southpaw: bool = false):
	init(randi() % WEAPON_TYPE.TORCH, southpaw)
#	init(WEAPON_TYPE.HAMMER, true)
