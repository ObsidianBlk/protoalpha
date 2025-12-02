extends UIControl

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var music_list : MusicSheet = null
@export var fade_duration : float = 0.5

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_start: Button = %BTN_Start

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	#_btn_start.grab_focus()
	refocus_input(_btn_start)
	if music_list != null:
		music_list.stop_non_local()
		music_list.play_default(fade_duration)
	super._on_reveal()

#func _on_hide() -> void:
	#super._on_hide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_btn_start_pressed() -> void:
	request(Game.UI_ACTION_START_GAME)

func _on_btn_quit_pressed() -> void:
	request(Game.UI_ACTION_QUIT_APPLICATION)
