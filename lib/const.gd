class_name Const

#signals
const END_PLAYER_TURN = "end_player_turn"
const PLAYER_DIED = "player_died"
const PLAYER_STATUS_CHANGED = "status_changed"
const PLAYER_LEVEL_UP = "level_up"
const ENEMY_HIT = "enemy_hit"
const KILLED_BY_PC = "killed_by_pc"
const INJURE_PC = "injure_pc"
const DOOR_OPENED = "door_opened"
const RAGE_LIGHTING = "rage_lighting"
const EXIT_LEVEL = "exit_level"
const TELEGRAPH = "telegraph"
const REMOVE_TARGET = "remove_target"

#groups
const PLAYER = "player"
const MOBS = "mobs"
const PICKUPS = "pickups"
const BLOCKER = "blocker"
const BLOODBAG = "bloodbag"
const PROJECTILE_BLOCKER = "projectile_blocker"
const PATHING_BLOCKER = "pathing_blocker"
const STOPS_ATTACK = "stops_attack"
const FURNITURE = "furniture"
const ON_FIRE = "on_fire"

#debuffs
const THRESH = "threshold"
const DIV = "divisor"
const START_AT = "start_at"
const FUMBLE = "shaky grip"
const LIMP = "limping"
const IMMOBILIZED = "immobilized"

# colors
const PROTECTED_COLOR = Color(0, 0.976471, 1)
const WINDUP_COLOR = Color(0.898039, 0, 1)
const READY_COLOR = Color(0.909804, 0.854902, 0)
const READY_AND_PROTECTED_COLOR = Color(0.454902, 0.913725, 0.501961)
const WINDUP_AND_PROTECTED_COLOR = Color(0.45098, 0.490196, 1)

# misc
const THE_HIDEOUT: Vector2 = Vector2(-1000,-1000)
