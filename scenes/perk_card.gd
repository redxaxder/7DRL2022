extends PanelContainer

class_name PerkCard

signal pick_perk(perk)

var index: int
var perk: Perk = null

func _ready():
	$perk/button.connect("button_down",self,"_select")
	pass # Replace with function body.

func init(i: int):
	index = i

func set_perk(p: Perk):
	perk = p
	$perk/title.text = p.title
	$perk/button/description.text = p.description

func _select():
	if self.perk != null:
		emit_signal("pick_perk",perk)
