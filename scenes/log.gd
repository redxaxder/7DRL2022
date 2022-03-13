extends PanelContainer

class_name CombatLog

var messages = []
var message_limits = {}

func say(message, limit:int = -1):
	if limit > 0:
		if message_limits.has(message):
			if message_limits[message] > limit:
				return
			message_limits[message] += 1
		else:
			message_limits[message] = 1
	messages.push_back(message)
	update_label()
	while ($log.get_line_count() > $log.get_visible_line_count()):
		messages.pop_front()
		update_label()

func update_label():
	$log.text = ""
	for m in messages:
		$log.text += m + "\n"

