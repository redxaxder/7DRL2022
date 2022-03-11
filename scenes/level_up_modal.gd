extends PanelContainer

signal exit_level_up
signal pick_perk(perk)

var perks: Array = [
	preload("res://lib/perks/short_tempered.gd").new(),
	preload("res://lib/perks/endurance.gd").new(),
	preload("res://lib/perks/vengeance.gd").new(),
	preload("res://lib/perks/bloodlust.gd").new(),
	preload("res://lib/perks/powerattack.gd").new(),
	]

func _ready():
	randomize()
	for i in 3:
		perk_card(i).init(i)
		perk_card(i).connect("pick_perk",self,"_on_perk_picked")
	prepare()
	$vbox/bottom/exit.connect("button_down",self,"exit")
	focus()

func perk_card(i:int) -> PerkCard:
	return get_node("vbox/grid/perk_card{0}".format([i])) as PerkCard

func prepare():
	perks.shuffle()
	for i in 3:
		perk_card(i).visible = false
	for i in min(3,perks.size()):
		perk_card(i).visible = true
		perk_card(i).set_perk(perks[i])
	focus()
	self.update()

func display_perk(i: int, n: Node):
	n.get_node("vbox/header").text = perks[i].title

func _on_perk_picked(p: Perk):
	exit()
	emit_signal("pick_perk", p)
	if !p.evolve_perk():
		perks.erase(p)
	prepare()

func exit():
	emit_signal("exit_level_up")

func focus():
	$vbox/bottom/exit.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		exit()
