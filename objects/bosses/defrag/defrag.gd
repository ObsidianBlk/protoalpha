extends CharacterActor2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal toggle_room_shift()


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TOGGLE_TIME : float = 15.0
const PULSE_SEGMENT_DURATION : float = 0.2
const PULSE_IDLE_DURATION : float = 0.05
const MODULATE_DEFAULT : Color = Color.WHITE
const MODULATE_PULSE : Color = Color.RED

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tween : Tween = null
var _toggle_timer : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: Sprite2D = $Sprite2D

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _toggle_timer > 0.0:
		_toggle_timer -= delta
	else:
		_toggle_timer = TOGGLE_TIME - wrapf(_toggle_timer, 0.0, delta)
		toggle_room_shift.emit()
		_Pulse(3, PULSE_SEGMENT_DURATION)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func _Pulse(segments : int, seg_duration : float) -> void:
	if _tween != null or _sprite == null: return
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_LINEAR)
	_tween.set_parallel(false)
	for seg : int in range(segments):
		_tween.tween_property(_sprite, "modulate", MODULATE_PULSE, seg_duration)
		_tween.tween_property(_sprite, "modulate", MODULATE_DEFAULT, 0.0)
		_tween.tween_interval(PULSE_IDLE_DURATION)
	await _tween.finished
	_tween = null
