extends PanelContainer
class_name KeyPad

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal coded(value : int)
signal power_pressed()
signal power_cycled(power_on : bool)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFAULT_CODE : int = 3
const SUBMIT_DELAY : float = 1.0
const POWER_CYCLE_DURATION : float = 0.5

const COLOR_POWER_ON : Color = Color.LIME
const COLOR_POWER_OFF : Color = Color.DARK_RED

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _code : String = ""
var _default_code : int = DEFAULT_CODE
var _active_code : int = DEFAULT_CODE
var _submit_delay : float = 0.0

var _power_on : bool = true
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _digi_readout: Label = %DigiReadout
@onready var _crect_power_light: ColorRect = %CRECT_PowerLight


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateReadout()

func _process(delta: float) -> void:
	if _submit_delay > 0.0:
		_submit_delay -= delta
		if _submit_delay <= 0.0:
			_SubmitCode()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateReadout() -> void:
	if _digi_readout == null: return
	var val : String = _code
	if _code.is_empty():
		val = "%d"%[_active_code]
	_digi_readout.text = val.lpad(3, "0")

func _SubmitCode() -> void:
	if _code.length() > 0 and _code.is_valid_int():
		_active_code = _code.to_int()
		_code = ""
		_UpdateReadout()
		coded.emit(_active_code)

func _PowerCycle() -> void:
	if _tween != null: return
	var color : Color = COLOR_POWER_OFF if _power_on else COLOR_POWER_ON
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_crect_power_light, "color", color, POWER_CYCLE_DURATION)
	await _tween.finished
	_tween = null
	_power_on = not _power_on
	power_cycled.emit(_power_on)

#func _PowerOff() -> void:
	#if _tween != null: return
	#_tween = create_tween()
	#_tween.set_ease(Tween.EASE_IN_OUT)
	#_tween.set_trans(Tween.TRANS_SINE)
	#_tween.tween_property(_crect_power_light, "color", COLOR_POWER_OFF, POWER_CYCLE_DURATION)
	#await _tween.finished
	#quit_application.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	_active_code = _default_code
	_UpdateReadout()

func set_default_code(default_code : int) -> void:
	if default_code >= 0:
		_default_code = default_code

func get_default_code() -> int:
	return _default_code

func is_powered() -> bool:
	return _power_on

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_number_pressed(num : String) -> void:
	if _code.length() < 3:
		_code = "%s%s"%[_code, num]
		_submit_delay = SUBMIT_DELAY
		_UpdateReadout()

func _on_btn_up_pressed() -> void:
	_active_code = clampi(_active_code + 1, 1, 999)
	_UpdateReadout()
	coded.emit(_active_code)

func _on_btn_down_pressed() -> void:
	_active_code = clampi(_active_code - 1, 1, 999)
	_UpdateReadout()
	coded.emit(_active_code)

func _on_btn_power_pressed() -> void:
	if _tween != null: return
	_active_code = _default_code
	_UpdateReadout()
	coded.emit(_active_code)
	power_pressed.emit()
	_PowerCycle()
