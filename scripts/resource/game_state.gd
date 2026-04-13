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

const _TOP_BIT : int = 0b10000_00000_00000_00000
const _LEVEL_PASSWORD_BINARY : Dictionary[int, Array] = {
	LEVEL_1: [0b01000_00000_00000_00000, 0b00000_00000_00000_00010],
	LEVEL_2: [0b00010_00000_00000_00000, 0b00000_00000_00000_01000],
	LEVEL_3: [0b00000_01000_00000_00000, 0b00000_00000_01000_00000],
	LEVEL_4: [0b00000_00100_00000_00000, 0b00000_00000_10000_00000],
	LEVEL_5: [0b00000_00000_00100_00000, 0b00000_00001_00000_00000],
	LEVEL_6: [0b00000_00000_00010_00000, 0b00000_10000_00000_00000],
	LEVEL_7: [0b00000_00000_00000_00100, 0b00001_00000_00000_00000],
	LEVEL_8: [0b00000_00000_00000_00001, 0b10000_00000_00000_00000]
}

const _LIFE_CODE : Dictionary[int, int] = {
	0b10000 : 0,
	0b01000 : 1,
	0b00100 : 2,
	0b00010 : 3,
	0b00001 : 4
}

enum Special {
	CHARGED_BLASTER=0,
	FAULT_DASH=1
}
const _SPECIAL_KEY_NAME : StringName = &"name"
const _SPECIAL_KEY_LEVEL : StringName = &"level"
const _SPECIAL_KEY_INF_ENERGY : StringName = &"inf_energy"
const _SPECIAL_KEY_IS_ACTION : StringName = &"is_action"
const _SPECIAL_KEY_ENERGY_REQ : StringName = &"energy_req"
const _SPECIAL_KEY_WEPDEF_PATH : StringName = &"wepdef_path"
const _SPECIAL_LUT : Dictionary[Special, Dictionary] = {
	Special.CHARGED_BLASTER : {
		_SPECIAL_KEY_NAME: "Charged Blaster",
		_SPECIAL_KEY_LEVEL: 0,
		_SPECIAL_KEY_INF_ENERGY: true,
		_SPECIAL_KEY_IS_ACTION: false,
		_SPECIAL_KEY_ENERGY_REQ: 0
	},
	Special.FAULT_DASH : {
		_SPECIAL_KEY_NAME: "Fault Dash",
		_SPECIAL_KEY_LEVEL: LEVEL_1,
		_SPECIAL_KEY_INF_ENERGY: false,
		_SPECIAL_KEY_IS_ACTION: true,
		_SPECIAL_KEY_ENERGY_REQ: 100
	}
}


const MAX_ENERGY : int = 255
const INITIAL_PLAYER_LIVES : int = 3
const MAX_PLAYER_LIVES : int = 5

const CHEAT_INFINITE_LIVES : StringName = &"move_up_move_up_move_down_move_down_move_left_move_right_move_left_move_right_select_start"
const CHEAT_CAN_DIE : StringName = &"select_select_select_start"
const CHEAT_ADD_LIVES : StringName = &"move_up_move_up_shoot_shoot_select"
const CHEAT_DEBUG_POSITION : StringName = &"move_up_move_left_move_down_move_right_select_select"
const CHEAT_KEYBOARD_SPECIALS : StringName = &"move_up_move_up_move_up_select_select"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## If [code]true[/code] [property lives] will be unchangable, effectively giving
## the player unlimited lives
@export var unlimited : bool = false:				set=set_unlimited

## The number of lives the player currently has.
@export_range(0, MAX_PLAYER_LIVES, 1) var lives : int = INITIAL_PLAYER_LIVES:
	set=set_lives

## Determines which levels are "unlocked" and available for the player to play
@export var unlocked_levels : int = ALL_LEVELS:		set=set_unlocked_levels

## The energy levels for each of the player's special abilities/weapons
@export var energy : Dictionary[Special, int]:		set=set_energy, get=get_energy

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _lock_change_emit : int = 0
var _energy : Dictionary[Special, int] = {
	Special.CHARGED_BLASTER : MAX_ENERGY,
	Special.FAULT_DASH : MAX_ENERGY
}
var _allow_specials_from_keyboard : bool = false

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
	if l >= 0 and l <= MAX_PLAYER_LIVES and l != lives:
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

func set_energy(e : Dictionary[Special, int]) -> void:
	var echanged : bool = false
	for key : Special in e:
		if key in energy and energy[key] != e[key]:
			energy[key] = e[key]
			echanged = true
	if echanged and _lock_change_emit <= 0:
		changed.emit()

func get_energy() -> Dictionary[Special, int]:
	return _energy.duplicate()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _BitShiftFromLives(l : int) -> int:
	# I'm just brute forcing this shiz!
	l = clampi(l, 1, 32) - 1
	if l > 0:
		if l & 0x10 > 0: return 5
		if l & 0x08 > 0: return 4
		if l & 0x04 > 0: return 3
		if l & 0x02 > 0: return 2
		return 1
	return 0

func _RotateIntLeft(i : int, bits : int) -> int:
	for _i : int in range(bits):
		var v : int = i & 0x1
		i = i >> 1
		if v > 0:
			i = i | _TOP_BIT
	return i

func _RotateIntRight(i : int, bits : int) -> int:
	for _i : int in range(bits):
		var v : int = i & _TOP_BIT
		i = (i << 1) & 0x1FF
		if v != 0:
			i = i | 0x1
	return i

func _IsLevelCodeValid(pw : int, level : int) -> int:
	if level in _LEVEL_PASSWORD_BINARY:
		var locked : bool = (pw & _LEVEL_PASSWORD_BINARY[level][0]) > 0
		var unlocked : bool = (pw & _LEVEL_PASSWORD_BINARY[level][1]) > 0
		if locked != unlocked:
			return 1 if locked else 0
	return -1

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	_lock_change_emit += 1
	unlimited = false
	lives = INITIAL_PLAYER_LIVES
	unlocked_levels = ALL_LEVELS
	for special : Special in energy:
		energy[special] = MAX_ENERGY
	_lock_change_emit -= 1
	if _lock_change_emit <= 0:
		changed.emit()

func reset_from_password(pw : int) -> bool:
	_lock_change_emit += 1
	reset()
	_lock_change_emit -= 1
	
	var lcode : int = (pw >> 20) & 0x1F
	if not lcode in _LIFE_CODE: return false
	lives = _LIFE_CODE[lcode] + 1
	var pw_levels : int = _RotateIntRight(pw & 0x1FF, _LIFE_CODE[lcode])
	for level : int in [LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8]:
		var code : int = _IsLevelCodeValid(pw_levels, level)
		if code < 0:
			return false
		set_level_unlocked(level, code == 1)
	return true

## Returns the current energy level ([code]0 - 255[/code]) for the given
## [param Special]
func get_energy_level(special : Special) -> int:
	if special in energy:
		if _SPECIAL_LUT[special][_SPECIAL_KEY_INF_ENERGY]:
			return MAX_ENERGY
		return energy[special]
	return -1

## Sets the energy level for [param special] to [param energy_level].
## [br][br]
## [b]Note:[/b] [param energy_level] is clamped to the range [code]0 - 255[/code].
func set_energy_level(special : Special, energy_level : int) -> void:
	energy_level = clampi(energy_level, 0, 255)
	if special in _energy and _energy[special] != energy_level:
		_energy[special] = energy_level
		if _lock_change_emit <= 0:
			changed.emit()

## Changes the energy level of [param special] by [param amount], which can be
## either positive (increase energy) or negative (decrease energy).
## [br][br]
## Regardless of the value of [param amount], the resulting energy level will
## always be between the values of [code]0 - 255[/code]
func change_energy_level(special : Special, amount : int) -> void:
	if special in _energy:
		if _SPECIAL_LUT[special][_SPECIAL_KEY_INF_ENERGY]: return
		set_energy_level(special, _energy[special] + amount)

## Reduces the energy level of [param special] by the amount of energy required to
## use [param special], if and only if the current energy level is greater than or
## equal to the energy required by [param special]. If successful [code]true[/code]
## is returned, otherwise [code]false[/code] is returned.
func use_special(special : Special) -> bool:
	if special in energy:
		if _energy[special] >= _SPECIAL_LUT[special][_SPECIAL_KEY_ENERGY_REQ]:
			change_energy_level(special, -_SPECIAL_LUT[special][_SPECIAL_KEY_ENERGY_REQ])
			return true
	return false

## Returns [code]true[/code] is the energy level of [param special] is greater than
## or equal to the amount of energy required to use [param special]. Otherwise
## [code]false[/code] is returned.
func can_use_special(special : Special) -> bool:
	if special in _energy:
		return _energy[special] >= _SPECIAL_LUT[special][_SPECIAL_KEY_ENERGY_REQ]
	return false

## Sets the given [param level] to the [param unlock] state.
## [br][br]
## [b]Note:[/b] An [i]unlocked[/i] level is available for the player to play.
func set_level_unlocked(level : int, unlock : bool = true) -> void:
	if level in [LEVEL_1,LEVEL_2,LEVEL_3,LEVEL_4,LEVEL_5,LEVEL_6,LEVEL_7,LEVEL_8]:
		if unlock:
			unlocked_levels = unlocked_levels | level
		else:
			unlocked_levels = unlocked_levels & (~level)

## Returns [code]true[/code] is [param level] id is marked as unlocked.
## Otherwise [code]false[/code] is returned.
func is_level_unlocked(level : int) -> bool:
	if level in [LEVEL_1,LEVEL_2,LEVEL_3,LEVEL_4,LEVEL_5,LEVEL_6,LEVEL_7,LEVEL_8]:
		return (level & unlocked_levels) > 0
	return false

## Returns [code]true[/code] is the given [param special] is unlocked and
## available for the player to use. Otherwise [code]false[/code] is returned.
func is_special_unlocked(special : Special) -> bool:
	if special in _SPECIAL_LUT:
		var level : int = _SPECIAL_LUT[special][_SPECIAL_KEY_LEVEL]
		if level == 0: return true
		# A "Locked" level is a defeated level...
		return not is_level_unlocked(level)
	return false

func get_password() -> int:
	var password : int = 0
	for level : int in [LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8]:
		var id : int = 0 if is_level_unlocked(level) else 1
		password = password | _LEVEL_PASSWORD_BINARY[level][id]
	
	var shift = lives - 1
	password = _RotateIntLeft(password, shift)
	
	var lcode : int = _LIFE_CODE.find_key(shift) << 20
	password = lcode | password
	return password

func are_specials_from_keyboard_allowed() -> bool:
	return _allow_specials_from_keyboard

func activate_cheat(code : StringName) -> bool:
	match code:
		CHEAT_INFINITE_LIVES:
			unlimited = true
			print("Unlimited Lives Cheat")
		CHEAT_ADD_LIVES:
			lives += 3
			print("Add Lives Cheat")
		CHEAT_CAN_DIE:
			unlimited = false
			print("Clear Unlimited Lives")
		CHEAT_DEBUG_POSITION:
			print("Teleport to debug position")
		CHEAT_KEYBOARD_SPECIALS:
			_allow_specials_from_keyboard = not _allow_specials_from_keyboard
			print("Keyboard specials toggled: ", _allow_specials_from_keyboard)
		_:
			return false
	cheat_activated.emit(code)
	return true
