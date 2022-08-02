extends Actor

class_name Brazier

const pickup_scene = preload("res://pickups/pickup.tscn")
var fallen: bool = false
var fallen_idx = 28

func _ready():
	self.label = "brazier"
	add_to_group(Const.FURNITURE)
	add_to_group(Const.BLOCKER)
	add_to_group(Const.PATHING_BLOCKER)
	self.flammability = 0.0

func kick(dir: int, extra_knockback = 0) -> bool:
	ignite()
	if combatLog != null:
		combatLog.say("The brazier goes flying!")
	knockback(DIR.dir_to_vec(dir), 1000, 1 + extra_knockback)
	return true

func die(dir):
	if combatLog != null:
		combatLog.say("The brazier is smashed to pieces!")
	try_ignite_neighbors(get_pos())
	deposit_coals(get_pos())
	deposit_coals(get_pos())
	deposit_coals(get_pos())
	.die(dir)

func deposit_coals(pos):
	var coal = pickup_scene.instance()
	coal.init(coal.ITEM_TYPE.HOT_COAL)
	coal.locationService = locationService
	get_parent().add_child(coal)
	coal.place(pos)

func nudge(dir: int, player_did_it: bool = true) -> bool:
	if combatLog != null:
		if not fallen:
			if player_did_it:
				combatLog.say("You knock over the brazier.")
			self.glyph_index = fallen_idx
			self._refresh()
			fallen = true
			emit_signal("thump")
			var pos = get_pos()
			var target = get_pos() + DIR.dir_to_vec(dir)
			var coal_target = target + DIR.dir_to_vec(dir)
			if locationService.lookup(target).size() == 0 and not terrain.is_wall(target):
				animated_move_to(target)
				if not terrain.is_wall(coal_target):
					deposit_coals(coal_target)
			update()
		else:
			var pos = get_pos()
			var target = get_pos() + DIR.dir_to_vec(dir)
			if locationService.lookup(target).size() == 0 and not terrain.is_wall(target):
				animated_move_to(target)
			else:
				combatLog.say("The brazier is stuck.")
				return false
			update()
	return true
