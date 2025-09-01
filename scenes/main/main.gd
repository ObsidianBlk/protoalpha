extends Node


signal start_game()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SETTINGS_SECTION : String = "General"
const SETTINGS_KEY_FULLSCREEN : String = "fullscreen"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.loaded.connect(_on_settings_loaded)
	Settings.reset.connect(_on_settings_reset)
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()
	start_game.emit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _QuitApplication() -> void:
	Settings.save()
	get_tree().quit()

func _IsFullscreen() -> bool:
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _ToggleFullscreen() -> bool:
	var mode : DisplayServer.WindowMode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return true
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	return false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_settings_reset() -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_FULLSCREEN, false)
	if _IsFullscreen():
		_ToggleFullscreen()

func _on_settings_loaded() -> void:
	var fs : Variant = Settings.load_value(SETTINGS_SECTION, SETTINGS_KEY_FULLSCREEN, false)
	if _IsFullscreen() != fs:
		_ToggleFullscreen()

func _on_tv_control_box_quit_application() -> void:
	_QuitApplication()

func _on_tv_control_box_fullscreen_toggled() -> void:
	var fullscreen : bool = _ToggleFullscreen()
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_FULLSCREEN, fullscreen)
