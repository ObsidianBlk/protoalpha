extends UIControl


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_resume: Button = %BTN_Resume

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	#_btn_resume.grab_focus()
	refocus_input(_btn_resume)
	super._on_reveal()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_btn_resume_pressed() -> void:
	request(Game.UI_ACTION_RESUME)

func _on_btn_password_pressed() -> void:
	print("I don't do anything yet. Sorry.")

func _on_btn_quit_pressed() -> void:
	request(Game.UI_ACTION_QUIT_GAME)

func _on_btn_level_select_pressed() -> void:
	request(Game.UI_ACTION_QUIT_LEVEL)
