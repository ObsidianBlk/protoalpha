@tool
extends RefCounted
class_name Game


# ------------------------------------------------------------------------------
# ENUMs
# ------------------------------------------------------------------------------
enum ScrollAxis {HORIZONTAL=0, VERTICAL=1}

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SCREEN_RESOLUTION : Vector2 = Vector2(320, 240)

const UI_ACTION_START_GAME : StringName = &"start_game"
const UI_ACTION_QUIT_APPLICATION : StringName = &"quit_app"

const GUIDE_COLOR_MATCHING_AXIS : Color = Color.AQUAMARINE
const GUIDE_COLOR_APPOSING_AXIS : Color = Color.BROWN

const GROUP_PLAYER : StringName = &"player"

const INITIAL_PLAYER_LIVES : int = 3

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var Player_Lives : int = INITIAL_PLAYER_LIVES

# ------------------------------------------------------------------------------
# Helper Methods
# ------------------------------------------------------------------------------

static func Guide_Color_From_Axis(axis : ScrollAxis, target_axis : ScrollAxis) -> Color:
	var matching : bool = axis == target_axis
	return GUIDE_COLOR_MATCHING_AXIS if matching else GUIDE_COLOR_APPOSING_AXIS
