@tool
extends RefCounted
class_name Game


# ------------------------------------------------------------------------------
# ENUMs
# ------------------------------------------------------------------------------
enum ScrollAxis {HORIZONTAL=0, VERTICAL=1}

# ------------------------------------------------------------------------------
# Classes
# ------------------------------------------------------------------------------
class SigDef extends RefCounted:
	var signal_name : StringName = &""
	var cb : Callable = func(): pass
	
	func _init(sig_name : StringName, callback : Callable) -> void:
		signal_name = sig_name
		cb = callback
	
	func connect_to(n : Node) -> void:
		if n == null: return
		if n.has_signal(signal_name) or n.has_user_signal(signal_name):
			if not n.is_connected(signal_name, cb):
				n.connect(signal_name, cb)
	
	func disconnect_from(n : Node) -> void:
		if n == null: return
		if n.has_signal(signal_name) or n.has_user_signal(signal_name):
			if n.is_connected(signal_name, cb):
				n.disconnect(signal_name, cb)

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

static func Event_One_Of(event : InputEvent, actions : Array[StringName], allow_echo : bool = false) -> bool:
	if not event.is_echo() or allow_echo:
		for action : StringName in actions:
			if event.is_action(action): return true
	return false

static func Dict_Key_Of_Type(d : Dictionary, key : Variant, type : int) -> bool:
	if key in d:
		return typeof(d[key]) == type
	return false

static func Connect_Signals(n : Node, sigs : Array[SigDef]) -> void:
	for sig : SigDef in sigs:
		sig.connect_to(n)

static func Disconnect_Signals(n : Node, sigs : Array[SigDef]) -> void:
	for sig : SigDef in sigs:
		sig.disconnect_from(n)
