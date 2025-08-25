@tool
extends Resource
class_name GameState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MAX_ENERGY : int = 255
const INITIAL_PLAYER_LIVES : int = 3

const LEVEL_1 : int = 0x01
const LEVEL_2 : int = 0x02
const LEVEL_3 : int = 0x04
const LEVEL_4 : int = 0x08
const LEVEL_5 : int = 0x10
const LEVEL_6 : int = 0x20
const LEVEL_7 : int = 0x40
const LEVEL_8 : int = 0x80

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var unlimited : bool = false:				set=set_unlimited
@export var lives : int = INITIAL_PLAYER_LIVES:		set=set_lives
@export var unlocked_levels : int = 0:				set=set_unlocked_levels
@export var energy : Dictionary[int, int] = {
	LEVEL_1: MAX_ENERGY,
	LEVEL_2: MAX_ENERGY,
	LEVEL_3: MAX_ENERGY,
	LEVEL_4: MAX_ENERGY,
	LEVEL_5: MAX_ENERGY,
	LEVEL_6: MAX_ENERGY,
	LEVEL_7: MAX_ENERGY,
	LEVEL_8: MAX_ENERGY
}:													set=set_energy

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _lock_change_emit : int = 0

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
	if l > 0 and l != lives:
		lives = l
		if _lock_change_emit <= 0:
			changed.emit()

func set_unlocked_levels(ul : int) -> void:
	ul = clampi(ul, 0, 255)
	if ul != unlocked_levels:
		unlocked_levels = ul
		if _lock_change_emit <= 0:
			changed.emit()

func set_energy(e : Dictionary[int, int]) -> void:
	var echanged : bool = false
	for l : int in [LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8]:
		if l in e and e[l] != energy[l]:
			echanged = true
			energy[l] = e[l]
	if echanged and _lock_change_emit <= 0:
		changed.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	_lock_change_emit += 1
	unlimited = false
	lives = INITIAL_PLAYER_LIVES
	unlocked_levels = 0
	energy = {
		LEVEL_1: MAX_ENERGY,
		LEVEL_2: MAX_ENERGY,
		LEVEL_3: MAX_ENERGY,
		LEVEL_4: MAX_ENERGY,
		LEVEL_5: MAX_ENERGY,
		LEVEL_6: MAX_ENERGY,
		LEVEL_7: MAX_ENERGY,
		LEVEL_8: MAX_ENERGY
	}
	_lock_change_emit -= 1
	if _lock_change_emit <= 0:
		changed.emit()


func get_energy_level(l : int) -> int:
	if l in energy:
		return energy[l]
	return -1

func set_energy_level(l : int, level : int) -> void:
	level = clampi(level, 0, 255)
	if l in energy and energy[l] != level:
		energy[l] = level
		if _lock_change_emit <= 0:
			changed.emit()
