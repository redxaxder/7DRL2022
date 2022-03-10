var constants = preload("res://lib/const.gd").new()

var debuffs: Dictionary = {
	constants.FUMBLE: {
		constants.THRESH: 10,
		constants.DIV: 2,
	}
}

func get_fatigue_effects(fatigue: int):
	var result: Dictionary = {}
	for d in debuffs.keys():
		var name = d
		var debuff = debuffs[d]
		var threshold = debuff[constants.THRESH]
		var divisor = debuff[constants.DIV]
		var duration = int(clamp((fatigue - threshold)/divisor, 0, 100))
		result[name] = duration
	return result
