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

## A simple Facing enum for horizontally aligned Mobs.
## [br][code]LEFT=-1[/code] and [code]RIGHT=1[/code]
enum MobFacingH {LEFT=-1, RIGHT=1}

## A simple Facing enum for vertically aligned Mobs.
## [br][code]UP=-1[/code] and [code]DOWN=1[/code]
enum MobFacingV {UP=-1, DOWN=1}

## A Level Development State enum mostly used during active game development.
## [br]Identifies if a level is ready, in active development, or not yet available.
enum LevelDevState {NOT_AVAILABLE=-1, ACTIVE_DEV=0, READY=1}

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
## UI Action - Load Level
const UI_ACTION_LOAD_LEVEL : StringName = &"load_level"
## UI Action - Quit Level
const UI_ACTION_QUIT_LEVEL : StringName = &"quit_level"
## UI Action - Quit Application
const UI_ACTION_QUIT_APPLICATION : StringName = &"quit_app"
## UI Action - Quit Game (return to Main Menu)
const UI_ACTION_QUIT_GAME : StringName = &"quit_game"
## UI Action - Pause Game (show Pause Menu)
const UI_ACTION_PAUSE : StringName = &"pause"
## UI Action - Resume Game (close menus and returns to game)
const UI_ACTION_RESUME : StringName = &"unpause"
## UI Action - Play sound effect
const UI_ACTION_SOUND : StringName = &"sound"

## Guide color for matching axis (used primarily by in-editor guides)
const GUIDE_COLOR_MATCHING_AXIS : Color = Color.AQUAMARINE
## Guide color for apposing axis (used primarily by in-editor guides)
const GUIDE_COLOR_APPOSING_AXIS : Color = Color.BROWN

## The "Player" Group
const GROUP_PLAYER : StringName = &"player"
## The "Boss" Group
const GROUP_BOSS : StringName = &"boss"

## The "Player"'s primary collision layer
const COLLISION_LAYER_PLAYER : int = 0x0002 # 2
## The "Player"'s hitbox collision layer
const COLLISION_LAYER_PLAYER_HITBOX : int = 0x0100 #256

const _LEVEL_PATH : StringName = &"path"
const _LEVEL_ICON : StringName = &"icon"
const _LEVEL_STATE : StringName = &"state"
const LEVELS : Dictionary[int, Dictionary] = {
	GameState.LEVEL_1: {
		_LEVEL_PATH:"res://scenes/levels/level_01/level_01.tscn",
		_LEVEL_ICON:"res://assets/graphics/bosses/seg_fault/Seg_Fault_Portrait.png",
		_LEVEL_STATE: LevelDevState.READY
	},
	GameState.LEVEL_2: {
		_LEVEL_PATH:"res://scenes/levels/level_02/level_02.tscn",
		_LEVEL_ICON:"res://assets/graphics/bosses/defrag/Defrag_Portrait.png",
		_LEVEL_STATE: LevelDevState.ACTIVE_DEV
	},
	GameState.LEVEL_3: {
		_LEVEL_PATH:"",
		_LEVEL_ICON:"",
		_LEVEL_STATE: LevelDevState.NOT_AVAILABLE
	},
	GameState.LEVEL_4: {
		_LEVEL_PATH:"",
		_LEVEL_ICON:"",
		_LEVEL_STATE: LevelDevState.NOT_AVAILABLE
	},
	GameState.LEVEL_5: {
		_LEVEL_PATH:"",
		_LEVEL_ICON:"",
		_LEVEL_STATE: LevelDevState.NOT_AVAILABLE
	},
	GameState.LEVEL_6: {
		_LEVEL_PATH:"",
		_LEVEL_ICON:"",
		_LEVEL_STATE: LevelDevState.NOT_AVAILABLE
	},
	GameState.LEVEL_7: {
		_LEVEL_PATH:"",
		_LEVEL_ICON:"",
		_LEVEL_STATE: LevelDevState.NOT_AVAILABLE
	},
	GameState.LEVEL_8: {
		_LEVEL_PATH:"",
		_LEVEL_ICON:"",
		_LEVEL_STATE: LevelDevState.NOT_AVAILABLE
	},
}

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
## Identifies if the game is actively running. If true, then either the initial
## level loads or the Level Select menu displays by default.
#static var Game_Running : bool = false

## Current number of player lives.
#static var Player_Lives : int = INITIAL_PLAYER_LIVES

## The GameState object
static var State : GameState = GameState.new()

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

static func Get_Level_Icon(level_id : int) -> Texture2D:
	if level_id in LEVELS:
		if not LEVELS[level_id][_LEVEL_ICON].is_empty():
			var ico : Texture2D = load(LEVELS[level_id][_LEVEL_ICON])
			if ico != null:
				return ico
	return null

static func Get_Level_Path(level_id : int) -> String:
	if level_id in LEVELS:
		return LEVELS[level_id][_LEVEL_PATH]
	return ""

static func Get_Level_State(level_id : int) -> LevelDevState:
	if level_id in LEVELS:
		return LEVELS[level_id][_LEVEL_STATE]
	return LevelDevState.NOT_AVAILABLE


static func Node_Has_Properties(n : Node, properties : Array[String]) -> bool:
	for property : String in properties:
		if not property in n: return false
	return true

static func Send_Action(action_name : StringName, pressed : bool = true) -> void:
	var event : InputEventAction = InputEventAction.new()
	event.action = action_name
	event.pressed = pressed
	Input.parse_input_event(event)

#static func Create_Level_Instance(level_id : int) -> Level:
	#if level_id in LEVELS:
		#if not LEVELS[level_id][_LEVEL_PATH].is_empty():
			#var scene : PackedScene = load(LEVELS[level_id][_LEVEL_PATH])
			#if scene != null:
				#var lvl : Node = scene.instantiate()
				#if lvl is Level:
					#return lvl
				#lvl.queue_free()
	#return null
