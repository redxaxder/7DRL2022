class_name Perk

var title: String
var level: int = 0
var next_level: bool = false
var perk_type: int
var description: String

enum PERK_TYPE{ SHORT_TEMPERED, BLOODLUST, VENGEANCE, ENDURANCE, POWER_ATTACK, SECOND_WIND }

func evolve_perk() -> bool:
	return false
