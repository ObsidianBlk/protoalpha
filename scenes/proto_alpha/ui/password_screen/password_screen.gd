extends UIControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _ROW : Dictionary[String, int] = {
	"A": 0,
	"B": 1,
	"C": 2,
	"D": 3,
	"E": 4
}
const _INITIAL_BUTTON_NAME : StringName = &"A1"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _grid_buttons : Dictionary[StringName, Button] = {}
var _locked : bool = false
var _password : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _password_grid: GridContainer = %PasswordGrid


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	for child : Node in _password_grid.get_children():
		if child is Button and child.name.begins_with("BTN_"):
			var subname : StringName = child.name.split("_")[1]
			if subname.length() == 2:
				_grid_buttons[subname] = child
				if not child.toggled.is_connected(_on_password_button_toggled.bind(subname)):
					child.toggled.connect(_on_password_button_toggled.bind(subname))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetRowIndex(r : String) -> int:
	if r in _ROW:
		return _ROW[r]
	return -1

func _UpdateFromPassword() -> void:
	pass

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	if _INITIAL_BUTTON_NAME in _grid_buttons:
		_grid_buttons[_INITIAL_BUTTON_NAME].grab_focus()
	_UpdateFromPassword()
	super._on_reveal()

func set_options(options : Dictionary) -> void:
	super.set_options(options)
	_password = _GetOptionValue(options, &"password", 0)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_password_button_toggled(toggled_on : bool, button_name : StringName) -> void:
	if button_name in _grid_buttons:
		if _locked:
			_grid_buttons[button_name].set_pressed_no_signal(not toggled_on)
		else:
			var row : int = _GetRowIndex(button_name.substr(0, 1))
			var col : int = button_name.substr(1, 1).to_int() - 1
			if row >= 0 and col >= 0 and col < 5:
				var idx : int = 24 - ((row * 5) + col)
				var mask : int = 0x1 << idx
				if toggled_on:
					_password = _password | mask
				else:
					_password = _password & (~mask)
			print("Password: ", String.num_uint64(_password, 2).lpad(25, "0"))
