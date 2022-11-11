extends Actor

class_name Bookcase

const pickup_scene = preload("res://pickups/pickup.tscn")
var fallen: bool = false
var fallen_idx = 28
var num_books = 1 + randi() % 5

func _ready():
	self.label = "bookcase"
	add_to_group(Const.FURNITURE)
	add_to_group(Const.BLOCKER)
	add_to_group(Const.PATHING_BLOCKER)
	self.flammability = 0.9
	self.color = Const.WOOD_COLOR

func kick(dir: int, extra_knockback = 0) -> bool:
	if combatLog != null:
		combatLog.say("The bookcase goes flying!")
	knockback(DIR.dir_to_vec(dir), 1000, 1 + extra_knockback)
	return true

func die(dir):
	if combatLog != null:
		combatLog.say("The bookcase is smashed to pieces!")
	for i in num_books:
		deposit_books(get_pos())
	.die(dir)

func deposit_books(pos):
	var book = pickup_scene.instance()
	book.init(book.ITEM_TYPE.BOOK)
	book.locationService = locationService
	get_parent().add_child(book)
	book.place(pos)

func nudge(dir: int, player_did_it: bool = true) -> bool:
	if player_did_it == false:
		return false
	if num_books > 0:
		var item = Pickup.new()
		item.init(Pickup.ITEM_TYPE.BOOK)
		item.locationService = locationService
		get_parent().add_child(item)
		pc.pick_up(item, pc.get_pos())
		num_books -= 1
		return true
	else:
		combatLog.say("The bookcase is empty.")
		return false
