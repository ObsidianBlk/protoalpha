extends UIControl

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_play: Button = %BTN_Play

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _id : int = -1

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	_btn_play.grab_focus()
	if _id == -1:
		swap_back.call_deferred()
	super._on_reveal()

func set_options(options : Dictionary) -> void:
	super.set_options(options)
	_id = _GetOptionValue(options, &"id", -1)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_play_pressed() -> void:
	request(Game.UI_ACTION_LOAD_LEVEL, [_id])

func _on_btn_cancel_pressed() -> void:
	swap_back()
