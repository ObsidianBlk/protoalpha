extends CanvasLayer

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CODE_GAME_FULLSCREEN : int = 2


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _enabled : bool = false
var _enable_requested : bool = true

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func coded(code : int) -> void:
	match code:
		CODE_GAME_FULLSCREEN:
			_enabled = true
			enable_game_fullscreen(_enable_requested)
		_:
			_enabled = false
			enable_game_fullscreen(_enable_requested)
	print("Code: ", code, " | Enabled: ", _enabled)

func enable_game_fullscreen(enable : bool) -> void:
	visible = enable and _enabled
	_enable_requested = enable

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
