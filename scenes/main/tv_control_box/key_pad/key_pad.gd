extends PanelContainer
class_name KeyPad

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal coded(value : int)

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _code : String = ""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _digi_readout: Label = %DigiReadout


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateReadout() -> void:
	if _digi_readout == null: return
	_digi_readout.text = _code.lpad(3, "0")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_number_pressed(num : String) -> void:
	if _code.length() < 3:
		_code = "%s%s"%[_code, num]
		_UpdateReadout()

func _on_btn_enter_pressed() -> void:
	if _code.length() > 0 and _code.is_valid_int():
		coded.emit(_code.to_int())
		_code = ""
		_UpdateReadout()

func _on_btn_del() -> void:
	var len : int = _code.length()
	match len:
		0, 1:
			_code = ""
		_:
			_code = _code.substr(0, _code.length() - 1)
	_UpdateReadout()

func _on_btn_clear_pressed() -> void:
	_code = ""
	_UpdateReadout()

func _on_btn_cancel_pressed() -> void:
	_on_btn_cancel_pressed() # Just in case I think of something to do with this button
