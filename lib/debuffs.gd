var constants = preload("res://lib/const.gd").new()

var debuffs: Dictionary = {
	constants.FUMBLE: {
		constants.THRESH: 20,
		constants.DIV: 2,
	},
	constants.LIMP: {
		constants.THRESH: 40,
		constants.DIV: 1,
	},
	constants.IMMOBILIZED: {
		constants.THRESH: 40,
		constants.DIV: 20,
	}
}

func get_fatigue_effects(fatigue: int):
	var result: Dictionary = {}
	for d in debuffs.keys():
		var name = d
		var debuff = debuffs[d]
		var threshold = debuff[constants.THRESH]
		var divisor = debuff[constants.DIV]
		var duration = int(clamp((fatigue - threshold)/divisor, 0, 1000))
		result[name] = duration
	return result
