@tool
extends RefCounted
class_name Game
## A static class containing constants, enums, and utility methods.
##
## A global static class for use anywhere in the application.
## Contains all ENUM definitions, Constant variables, and utility methods that
## either did not best anywhere else.
## [color=yellow][b]WARNING:[/b][/color] This class is NOT intended to be instanced.

# ------------------------------------------------------------------------------
# ENUMs
# ------------------------------------------------------------------------------
## Scroll Axis used primarily for defining the axis a camera can scroll.
enum ScrollAxis {HORIZONTAL=0, VERTICAL=1}

# ------------------------------------------------------------------------------
# Classes
# ------------------------------------------------------------------------------
## A class for dis/connecting predefined signals/callbacks to  nodes.
##
## Primarily useful for defining a signal name and a callback for later connection
## to an (at time of definition) unknown node. For instance dis/connecting to
## user defined signals created by components.
##
## [b]Example:[/b]
## [codeblock]
## var sig : SigDef = SigDef.new(&"my_signal", my_signal_handler)
## sig.connect(my_node) # Where my_node can be any Node type.
## [/codeblock]
class SigDef extends RefCounted:
	## The name of the signal to attempt to dis/connect to.
	var signal_name : StringName = &""
	## The callback method to dis/connect with.
	var cb : Callable = func(): pass
	
	func _init(sig_name : StringName, callback : Callable) -> void:
		signal_name = sig_name
		cb = callback
	
	func connect_to(n : Node, flags : int = 0) -> int:
		if n == null: return ERR_INVALID_DATA
		if n.has_signal(signal_name) or n.has_user_signal(signal_name):
			if not n.is_connected(signal_name, cb):
				return n.connect(signal_name, cb, flags)
			return ERR_ALREADY_IN_USE
		return ERR_DOES_NOT_EXIST
	
	func disconnect_from(n : Node) -> void:
		if n == null: return
		if n.has_signal(signal_name) or n.has_user_signal(signal_name):
			if n.is_connected(signal_name, cb):
				n.disconnect(signal_name, cb)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
## The "screen resolution" assumed by all direct game elements.
const SCREEN_RESOLUTION : Vector2 = Vector2(320, 240)

## UI Action - Start Game
const UI_ACTION_START_GAME : StringName = &"start_game"
## UI Action - Quit Application
const UI_ACTION_QUIT_APPLICATION : StringName = &"quit_app"
## UI Action - Play sound effect
const UI_ACTION_SOUND : StringName = &"sound"

## Guide color for matching axis (used primarily by in-editor guides)
const GUIDE_COLOR_MATCHING_AXIS : Color = Color.AQUAMARINE
## Guide color for apposing axis (used primarily by in-editor guides)
const GUIDE_COLOR_APPOSING_AXIS : Color = Color.BROWN

## The "Player" Group
const GROUP_PLAYER : StringName = &"player"

## Number of initial lives players should start the game with.
const INITIAL_PLAYER_LIVES : int = 3

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
## Current number of player lives.
static var Player_Lives : int = INITIAL_PLAYER_LIVES

# ------------------------------------------------------------------------------
# Helper Methods
# ------------------------------------------------------------------------------

## Returns a color depending on the values of the two given ScrollAxis parameters.[br]
## If [param axis] and [param target_axis] match, then [constant GUIDE_COLOR_MATCHING_AXIS] is returned.
## Otherwise [constant GUIDE_COLOR_APPOSING_AXIS] is returned.
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

static func Sync_Play_Animated_Sprite(asprite : AnimatedSprite2D, anim_name : StringName) -> void:
	if asprite == null: return
	if asprite.sprite_frames == null: return
	
	var cur_anim : StringName = asprite.animation
	if cur_anim == anim_name: return
	
	if asprite.sprite_frames.get_frame_count(cur_anim) == asprite.sprite_frames.get_frame_count(anim_name):
		var cur_frame : int = asprite.frame
		var cur_progress : float = asprite.frame_progress
		asprite.play(anim_name)
		asprite.set_frame_and_progress(cur_frame, cur_progress)
	else:
		asprite.play(anim_name)
