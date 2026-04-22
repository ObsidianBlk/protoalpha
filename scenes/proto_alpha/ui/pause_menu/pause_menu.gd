extends UIControl


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var password_menu : StringName = &""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_resume: Button = %BTN_Resume

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	request(ComponentUISoundHandler.UI_ACTION_BLOCK_NEXT_SOUND)
	refocus_input(_btn_resume)
	super._on_reveal()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_btn_resume_pressed() -> void:
	request(Game.UI_ACTION_RESUME)

func _on_btn_password_pressed() -> void:
	if not password_menu.is_empty():
		swap_to(password_menu, false, {
			&"password": Game.State.get_password(),
			UIControl.OPTION_PREVIOUS_UI: self.name
		})

func _on_btn_quit_pressed() -> void:
	request(Game.UI_ACTION_QUIT_GAME)

func _on_btn_level_select_pressed() -> void:
	request(Game.UI_ACTION_QUIT_LEVEL)
