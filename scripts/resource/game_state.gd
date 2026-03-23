@tool
extends Resource
class_name GameState

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal cheat_activated(cheat_code : StringName)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
## Level 1 ID
const LEVEL_1 : int = 0x01
## Level 2 ID
const LEVEL_2 : int = 0x02
## Level 3 ID
const LEVEL_3 : int = 0x04
## Level 4 ID
const LEVEL_4 : int = 0x08
## Level 5 ID
const LEVEL_5 : int = 0x10
## Level 6 ID
const LEVEL_6 : int = 0x20
## Level 7 ID
const LEVEL_7 : int = 0x40
## Level 8 ID
const LEVEL_8 : int = 0x80

const ALL_LEVELS : int = LEVEL_1 | LEVEL_2 | LEVEL_3 | LEVEL_4 | LEVEL_5 | LEVEL_6 | LEVEL_7 | LEVEL_8

const WEAPON_BOLT : StringName = &"blaster"
const WEAPON_CHARGED_BOLT : StringName = &"charged_blaster"

# A stupid lookup table that takes the weapon name as key and the value is the
# LEVEL_* that unlocks that weapon.
# NOTE: A value of 0 is always unlocked.
const _WEAPON_LUT : Dictionary[StringName, int] = {
	WEAPON_BOLT: 0,
	WEAPON_CHARGED_BOLT: 0
}

const MAX_ENERGY : int = 255
const INITIAL_PLAYER_LIVES : int = 3

const CHEAT_INFINITE_LIVES : StringName = &"move_up_move_up_move_down_move_down_move_left_move_right_move_left_move_right_select_start"
const CHEAT_CAN_DIE : StringName = &"select_select_select_start"
const CHEAT_ADD_LIVES : StringName = &"move_up_move_up_shoot_shoot_select"
const CHEAT_DEBUG_POSITION : StringName = &"move_up_move_left_move_down_move_right_select_select"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var unlimited : bool = false:				set=set_unlimited
@export var lives : int = INITIAL_PLAYER_LIVES:		set=set_lives
## Determines which levels are "unlocked" and available for the player to play
@export var unlocked_levels : int = ALL_LEVELS:		set=set_unlocked_levels
@export var energy : Dictionary[StringName, int] = {
	WEAPON_BOLT: MAX_ENERGY,
	WEAPON_CHARGED_BOLT: MAX_ENERGY,
}:													set=set_energy

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _lock_change_emit : int = 0
var _energy : Dictionary[StringName, int] = {
	WEAPON_BOLT: MAX_ENERGY,
	WEAPON_CHARGED_BOLT: MAX_ENERGY,
}

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_unlimited(u : bool) -> void:
	if u != unlimited:
		unlimited = u
		_lock_change_emit += 1
		lives = INITIAL_PLAYER_LIVES
		_lock_change_emit -= 1
		if _lock_change_emit <= 0:
			changed.emit()

func set_lives(l : int) -> void:
	if l >= 0 and l != lives:
		if not unlimited:
			lives = l
		if _lock_change_emit <= 0:
			changed.emit()

func set_unlocked_levels(ul : int) -> void:
	ul = clampi(ul, 0, 255)
	if ul != unlocked_levels:
		unlocked_levels = ul
		if _lock_change_emit <= 0:
			changed.emit()

func set_energy(e : Dictionary[StringName, int]) -> void:
	var echanged : bool = false
	for key : StringName in e:
		if key in energy and energy[key] != e[key]:
			energy[key] = e[key]
			echanged = true
	if echanged and _lock_change_emit <= 0:
		changed.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	_lock_change_emit += 1
	unlimited = false
	lives = INITIAL_PLAYER_LIVES
	unlocked_levels = ALL_LEVELS
	for weapon : StringName in energy:
		energy[weapon] = MAX_ENERGY
	_lock_change_emit -= 1
	if _lock_change_emit <= 0:
		changed.emit()


func get_energy_level(weapon : StringName) -> int:
	if weapon in energy:
		return energy[weapon]
	return -1

func set_energy_level(weapon : StringName, energy_level : int) -> void:
	energy_level = clampi(energy_level, 0, 255)
	if weapon in energy and energy[weapon] != energy_level:
		energy[weapon] = energy_level
		if _lock_change_emit <= 0:
			changed.emit()

func set_level_unlocked(level : int, unlock : bool = true) -> void:
	if level in [LEVEL_1,LEVEL_2,LEVEL_3,LEVEL_4,LEVEL_5,LEVEL_6,LEVEL_7,LEVEL_8]:
		if unlock:
			unlocked_levels = unlocked_levels | level
		else:
			unlocked_levels = unlocked_levels & (~level)

## Returns [code]true[/code] is [param level] id is marked as unlocked.
## Otherwise [code]false[/code] is returned.
## [br][br]
## [b]Note:[/b] Special level id [code]0[/code] always returns [code]true[/code]
func is_level_unlocked(level : int) -> bool:
	if level in [LEVEL_1,LEVEL_2,LEVEL_3,LEVEL_4,LEVEL_5,LEVEL_6,LEVEL_7,LEVEL_8]:
		return (level & unlocked_levels) > 0
	return level == 0

func activate_cheat(code : StringName) -> bool:
	match code:
		CHEAT_INFINITE_LIVES:
			unlimited = true
			print("Unlimited Lives Cheat")
		CHEAT_ADD_LIVES:
			lives += 3
			print("Add Lived Cheat")
		CHEAT_CAN_DIE:
			unlimited = false
			print("Clear Unlimited Lives")
		CHEAT_DEBUG_POSITION:
			print("Teleport to debug position")
		_:
			return false
	cheat_activated.emit(code)
	return true
