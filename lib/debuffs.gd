var constants = preload("res://lib/const.gd").new()

var debuffs: Dictionary = {
	constants.FUMBLE: {
		constants.THRESH: 20,
		constants.DIV: 2,
		constants.START_AT: 0,
	},
	constants.LIMP: {
		constants.THRESH: 40,
		constants.DIV: 1,
		constants.START_AT: 0,
	},
	constants.IMMOBILIZED: {
		constants.THRESH: 40,
		constants.DIV: 20,
		constants.START_AT: 1,
	}
}

func get_fatigue_effects(fatigue: int):
	var result: Dictionary = {}
	for d in debuffs.keys():
		var name = d
		var debuff = debuffs[d]
		var threshold = debuff[constants.THRESH]
		var divisor = debuff[constants.DIV]
		var start_at = int(debuff[constants.START_AT])
		var duration = start_at + max(0,int((fatigue - threshold)/divisor))
		result[name] = duration
	return result
