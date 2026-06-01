extends PanelContainer

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

const DEFAULT_LIVES : int = 3

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var channel : int = 72

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _faux_game_state : GameState = GameState.new()

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _password_grid: GridContainer = %PasswordGrid
@onready var _slider_life: HSlider = %SLIDER_Life
@onready var _checks : Array[CheckBox] = [
	%CHECK_L1,
	%CHECK_L2,
	%CHECK_L3,
	%CHECK_L4,
	%CHECK_L5,
	%CHECK_L6,
	%CHECK_L7,
	%CHECK_L8
]

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	visible = false

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetRowIndex(r : String) -> int:
	if r in _ROW:
		return _ROW[r]
	return -1

func _UpdateButton(btn : Button, password : int) -> void:
	var nlen : int = btn.name.length()
	var row : int = _GetRowIndex(btn.name.substr(nlen - 2, 1))
	var col : int = btn.name.substr(nlen - 1, 1).to_int() - 1
	if row >= 0 and col >= 0 and col < 5:
		var idx : int = 24 - ((row * 5) + col)
		var mask : int = 0x1 << idx
		btn.set_pressed_no_signal(password & mask > 0)

func _UpdatePasswordGrid() -> void:
	if _password_grid == null: return
	var password : int = _faux_game_state.get_password()
	for child : Node in _password_grid.get_children():
		if child is Button:
			_UpdateButton(child, password)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func handle_channel(code : int) -> void:
	if code == channel:
		visible = true

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_visibility_changed() -> void:
	if visible:
		_faux_game_state.reset()
		_slider_life.set_value_no_signal(DEFAULT_LIVES)
		for check : CheckBox in _checks:
			if check != null:
				check.set_pressed_no_signal(false)
		_UpdatePasswordGrid()

func _on_level_toggled(toggled_on : bool, level : int) -> void:
	_faux_game_state.set_level_unlocked_by_index(level - 1, not toggled_on)
	_UpdatePasswordGrid()

func _on_slider_life_value_changed(value: float) -> void:
	if value > 0 and value <= 6:
		_faux_game_state.set_lives(int(value))
		_UpdatePasswordGrid()

func _on_btn_close_pressed() -> void:
	visible = false
