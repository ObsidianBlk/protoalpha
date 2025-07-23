extends UIControl


# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	super._on_reveal()

func _on_hide() -> void:
	super._on_hide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_btn_start_pressed() -> void:
	request(Game.UI_ACTION_START_GAME)

func _on_btn_quit_pressed() -> void:
	request(Game.UI_ACTION_QUIT_APPLICATION)
