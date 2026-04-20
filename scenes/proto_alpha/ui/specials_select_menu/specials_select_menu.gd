extends UIControl


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MODULATION_SPECIAL_ACTIVE : Color = Color.WHITE
const MODULATION_SPECIAL_INACTIVE : Color = Color.TRANSPARENT

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _button_lut : Dictionary[GameState.Special, Button] = {}

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
	for special : GameState.Special in _button_lut.keys():
		if Game.State.is_special_unlocked(special):
			_button_lut[special].modulate = MODULATION_SPECIAL_ACTIVE
			_button_lut[special].focus_mode = Control.FOCUS_ALL
		else:
			_button_lut[special].modulate = MODULATION_SPECIAL_INACTIVE
			_button_lut[special].focus_mode = Control.FOCUS_NONE
		
		if special == Game.State.get_special():
			_button_lut[special].grab_focus()
			_button_lut[special].set_pressed_no_signal(true)
	super._on_reveal()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_special_button_pressed(special : GameState.Special) -> void:
	if special != Game.State.get_special():
		Relay.special_selected.emit(special)
	request(Game.UI_ACTION_RESUME)
