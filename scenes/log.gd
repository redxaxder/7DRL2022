extends PanelContainer

class_name CombatLog

var messages = []

func _ready():
	say("welcome to the dungeon")

func say(message):
	messages.push_back(message)
	update_label()
	while ($log.get_line_count() > $log.get_visible_line_count()):
		messages.pop_front()
		update_label()

func update_label():
	$log.text = ""
	for m in messages:
		$log.text += m + "\n"
	
