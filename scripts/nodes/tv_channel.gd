@tool
extends MarginContainer
class_name TVChannel

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal smpte_show_requested(msg : String)
signal smpte_hide_requested()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(0, 999) var channel_number : int = 0
@export var sound_sheet : SoundSheet = null

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	pass

func exit() -> void:
	pass
