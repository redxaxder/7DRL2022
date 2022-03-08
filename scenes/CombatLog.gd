extends Node

class_name Log

var messages = []
var label: Label

const history:int = 50

func say(message):
	messages.push_front(message)
	if messages.size() > history:
		messages.resize(history)
	label.text = ""
	for m in messages:
		label.text += m + "\n"
