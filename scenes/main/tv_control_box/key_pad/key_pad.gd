extends PanelContainer
class_name KeyPad

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal coded(value : int)
signal close_game()
signal quit_application()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFAULT_CODE : int = 3
const SUBMIT_DELAY : float = 1.0
const POWER_OFF_DURATION : float = 0.5

const COLOR_POWER_ON : Color = Color.LIME
const COLOR_POWER_OFF : Color = Color.DARK_RED

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _code : String = ""
var _active_code : int = DEFAULT_CODE
var _submit_delay : float = 0.0

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

func _PowerOff() -> void:
	if _tween != null: return
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_crect_power_light, "color", COLOR_POWER_OFF, POWER_OFF_DURATION)
	await _tween.finished
	quit_application.emit()

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
	_active_code = DEFAULT_CODE
	_UpdateReadout()
	coded.emit(_active_code)
	close_game.emit()
	_PowerOff()
