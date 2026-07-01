extends Node
class_name ComponentOverloadMonitor

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DISCHARGE_CHUNK : int = 32
const DISSIPATE_CHUNK : int = 8

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var health : ComponentHealth = null
@export var discharge_damage : int = 10
@export var discharge_interval : float = 0.5
@export var dissipate_interval : float = 0.5

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _current_special : GameState.Special = GameState.Special.CHARGED_BLASTER
var _discharging : bool = false
var _timer_tween : Tween = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if owner == null:
		printerr("ComponentOverloadMonitor missing Owner.")
		return
	owner.ready.connect(_on_owner_ready)

func _enter_tree() -> void:
	if owner != null and owner.is_node_ready():
		_on_owner_ready()

func _exit_tree() -> void:
	if Game.State.changed.is_connected(_on_gamestate_changed):
		Game.State.changed.disconnect(_on_gamestate_changed)
	_KillTimerTween()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _KillTimerTween() -> void:
	if _timer_tween == null: return
	_timer_tween.kill()
	_timer_tween = null

func _Delay(time : float, cb : Callable) -> void:
	_KillTimerTween()
	_timer_tween = create_tween()
	_timer_tween.tween_interval(time)
	_timer_tween.set_parallel(false)
	_timer_tween.tween_callback(cb)

func _Dissipate() -> void:
	_KillTimerTween()
	if _discharging: return
	
	var overload : int = Game.State.get_energy_overload(_current_special)
	if overload > 0:
		overload = clampi(overload - DISSIPATE_CHUNK, 0, GameState.MAX_ENERGY)
		Game.State.set_energy_overload(_current_special, overload)
		print("Overload Dissipating: ", overload)
	
	_Delay(dissipate_interval, _Dissipate)


func _Discharge() -> void:
	_KillTimerTween()
	Game.State.energy_locked = false
	if not _discharging: return

	var overload : int = Game.State.get_energy_overload(_current_special)
	var elevel : int = Game.State.get_energy_level(_current_special)
	if overload > 0:
		if overload > DISCHARGE_CHUNK:
			Game.State.set_energy_overload(_current_special, overload - DISCHARGE_CHUNK)
		else:
			Game.State.set_energy_overload(_current_special, 0)
		if health != null:
			health.hurt(discharge_damage)
	elif elevel > 0:
		if GameState.SPECIAL[_current_special].has_infinite_energy:
			_discharging = false
		else:
			if elevel > DISCHARGE_CHUNK:
				Game.State.set_energy_level(_current_special, elevel - DISCHARGE_CHUNK)
			else:
				Game.State.set_energy_level(_current_special, 0)
				_discharging = false
			if health != null:
				health.hurt(discharge_damage)
	
	if _discharging:
		Game.State.energy_locked = true
		_Delay(discharge_interval, _Discharge)
	else: _Dissipate()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_owner_ready() -> void:
	if not Game.State.changed.is_connected(_on_gamestate_changed):
		Game.State.changed.connect(_on_gamestate_changed)
	_current_special = Game.State.get_special()
	_Dissipate()

func _on_gamestate_changed() -> void:
	var special : GameState.Special = Game.State.get_special()
	if special != _current_special:
		_discharging = false
		_current_special = special
		if Game.State.get_energy_overload(special) > 0:
			_Dissipate()
	elif not _discharging:
		if Game.State.get_energy_overload(_current_special) >= GameState.MAX_ENERGY:
			_discharging = true
			_Discharge()
