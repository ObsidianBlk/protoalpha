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
const _MAX_TICKS : int = 9

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var level_select_menu : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _grid_buttons : Dictionary[StringName, Button] = {}
var _locked : bool = false
var _available_ticks : int = _MAX_TICKS
var _password : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _password_grid: GridContainer = %PasswordGrid

@onready var _static_controls: PanelContainer = %StaticControls
@onready var _entry_controls: VBoxContainer = %EntryControls
@onready var _lbl_available_ticks: Label = %LBL_AvailableTicks


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

func _UpdateAvailableTicks() -> void:
	if _lbl_available_ticks == null: return
	if _available_ticks == 0:
		_lbl_available_ticks.text = ""
	else: _lbl_available_ticks.text = "%d"%[_available_ticks]

func _UpdateFromPassword() -> void:
	if _password == 0:
		for btn : Button in _grid_buttons.values():
			btn.set_pressed_no_signal(false)
		_available_ticks = 9
		return
	var pass_str : String = String.num_uint64(_password, 2).lpad(25, "0")
	var plen : int = pass_str.length()
	_available_ticks = 9
	for idx : int in range(plen):
		var row : int = floor(float(idx) / float(_ROW.size()))
		var col : int = idx % _ROW.size()
		var row_key : Variant = _ROW.find_key(row)
		if not typeof(row_key) == TYPE_STRING:
			printerr("No password row key for row index ", row)
			continue
		
		var btn_name : StringName = "%s%d"%[row_key, col + 1]
		if not btn_name in _grid_buttons:
			printerr("Failed to find password button ", btn_name)
			continue
		
		var bit : String = pass_str.substr(idx, 1)
		if bit == "1":
			_grid_buttons[btn_name].set_pressed_no_signal(true)
			_available_ticks -= 1

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	if _INITIAL_BUTTON_NAME in _grid_buttons:
		_grid_buttons[_INITIAL_BUTTON_NAME].grab_focus()
	_entry_controls.visible = not _locked
	_static_controls.visible = _locked
	_UpdateFromPassword()
	_UpdateAvailableTicks()
	super._on_reveal()

func set_options(options : Dictionary) -> void:
	super.set_options(options)
	_password = _GetOptionValue(options, &"password", 0)
	_locked = _GetOptionValue(options, &"locked", false)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_password_button_toggled(toggled_on : bool, button_name : StringName) -> void:
	if button_name in _grid_buttons:
		if _locked:
			_grid_buttons[button_name].set_pressed_no_signal(not toggled_on)
		else:
			
			if toggled_on:
				if _available_ticks == 0:
					_grid_buttons[button_name].set_pressed_no_signal(false)
					return
				_available_ticks -= 1
			else:
				_available_ticks += 1
			_UpdateAvailableTicks()
			
			var row : int = _GetRowIndex(button_name.substr(0, 1))
			var col : int = button_name.substr(1, 1).to_int() - 1
			if row >= 0 and col >= 0 and col < 5:
				var idx : int = 24 - ((row * 5) + col)
				var mask : int = 0x1 << idx
				if toggled_on:
					_password = _password | mask
				else:
					_password = _password & (~mask)
			#print("Password: ", String.num_uint64(_password, 2).lpad(25, "0"))

func _on_btn_back_pressed() -> void:
	swap_back()

func _on_btn_reset_pressed() -> void:
	_password = 0
	_UpdateFromPassword()
	_UpdateAvailableTicks()

func _on_btn_accept_pressed() -> void:
	if Game.State.is_password_valid(_password):
		if _password != Game.State.get_password():
			if not level_select_menu.is_empty():
				request(Game.UI_ACTION_START_GAME, [_password])
				return
		swap_back()
	else:
		print("You done fucked up, son!")

func _on_btn_continue_pressed() -> void:
	if not level_select_menu.is_empty():
		swap_to(level_select_menu)
