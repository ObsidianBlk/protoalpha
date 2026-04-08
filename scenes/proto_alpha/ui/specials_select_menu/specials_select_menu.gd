extends UIControl


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _button_lut : Dictionary[GameState.Special, Button] = {}
var _current_special : GameState.Special = GameState.Special.CHARGED_BLASTER

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_button_lut = {
		GameState.Special.CHARGED_BLASTER : %BTN_ChargedBolt,
		GameState.Special.FAULT_DASH : %BTN_FaultDash,
	}
	
	var btn_group : ButtonGroup = ButtonGroup.new()
	for special : GameState.Special in _button_lut.keys():
		if _button_lut[special] is Button:
			_button_lut[special].toggle_mode = true
			_button_lut[special].button_group = btn_group
			_button_lut[special].pressed.connect(_on_special_button_pressed.bind(special))

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	if _current_special in _button_lut:
		_button_lut[_current_special].grab_focus()
		_button_lut[_current_special].set_pressed_no_signal(true)
	super._on_reveal()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_special_button_pressed(special : GameState.Special) -> void:
	if _current_special != special:
		_current_special = special
		Relay.special_selected.emit(special)
		request(Game.UI_ACTION_RESUME)
