extends Node
class_name ComponentEnergy

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal energy_changed(energy : int, max_energy : int)
signal hit()
signal recharged()
signal depleted()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## If [code]true[/code] the [property max_energy] and [property energy] values
## will reflect those of the player's currently selected Special. Otherwise
## the values will be those tied to this instance of [ComponentEnergy]
@export var player : bool = false
## The component's max energy value.
@export var max_energy : int = 100:		set=set_max_energy, get=get_max_energy
## The component's current energy value.
@export var energy : int = 100:			set=set_energy, get=get_energy


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _max_energy : int = 100
var _energy : int = 100

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_player(p : bool) -> void:
	if p != player:
		player = p
		# NOTE: not the underscored variables!!
		energy_changed.emit(energy, max_energy)

func set_max_energy(me : int) -> void:
	if player: return # Can't change player's max energy value.
	if me > 0 and me != _max_energy:
		_max_energy = me
		if _max_energy < _energy:
			energy = _max_energy
		else: energy_changed.emit(_energy, _max_energy)

func get_max_energy() -> int:
	if player:
		return Game.State.MAX_ENERGY
	return _max_energy

func set_energy(e : int) -> void:
	if e > 0 and e <= _max_energy and e != _energy:
		if player:
			Game.State.set_energy_level(Game.State.get_special(), e)
		else: _energy = e
		energy_changed.emit(_energy, _max_energy)

func get_energy() -> int:
	if player:
		return Game.State.get_energy_level(
			Game.State.get_special()
		)
	return _energy

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	energy_changed.emit(energy, max_energy)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func hurt(amount : int) -> void:
	if amount <= 0: return
	energy = max(energy - amount, 0)
	if energy <= 0:
		depleted.emit()
	else: hit.emit()

func recharge(amount : int) -> void:
	if amount <= 0: return
	energy += amount
	recharged.emit()
