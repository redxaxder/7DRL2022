extends PanelContainer

class_name CombatLog

var messages = []
var counts = []
var message_limits = {}
const message_fusing_range: int = 4

func say(message, limit:int = -1):
	if limit > 0:
		if message_limits.has(message):
			if message_limits[message] > limit:
				return
			message_limits[message] += 1
		else:
			message_limits[message] = 1
	var did_fuse = false
	for i in message_fusing_range:
		var ix = messages.size() - i - 1
		if ix > 0 && messages[ix] == message:
			did_fuse = true
			counts[ix] += 1
	if !did_fuse:
		messages.push_back(message)
		counts.push_back(1)
	update_label()
	while ($log.get_line_count() > $log.get_visible_line_count()):
		messages.pop_front()
		counts.pop_front()
		update_label()

func update_label():
	$log.text = ""
	for ix in messages.size():
		var m = messages[ix]
		var n = counts[ix]
		if n <= 1:
			$log.text += m + "\n"
		else:
			$log.text += "{0} \n    [x{1}]\n".format([m,n])

