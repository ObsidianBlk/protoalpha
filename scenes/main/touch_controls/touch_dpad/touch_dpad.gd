@tool
extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal pressed()
signal released()
signal direction_pressed(dir : int)
signal direction_released(dir : int)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DIRECTION_NORTH : int = 0
const DIRECTION_EAST : int = 1
const DIRECTION_SOUTH : int = 2
const DIRECTION_WEST : int = 3

const _PROJSETTINGS_PROP_INPUT_PREFIX : String = "input/"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_custom(PROPERTY_HINT_ENUM, "", PROPERTY_USAGE_DEFAULT) var north_action : String = "":
	set=set_north_action
@export_custom(PROPERTY_HINT_ENUM, "", PROPERTY_USAGE_DEFAULT) var south_action : String = "":
	set=set_south_action
@export_custom(PROPERTY_HINT_ENUM, "", PROPERTY_USAGE_DEFAULT) var east_action : String = "":
	set=set_east_action
@export_custom(PROPERTY_HINT_ENUM, "", PROPERTY_USAGE_DEFAULT) var west_action : String = "":
	set=set_west_action
@export var passby_press : bool = false:
	set=set_passby_press
@export var spread : float = 24.0:
	set=set_spread


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_north: TouchScreenButton = %BTN_North
@onready var _btn_south: TouchScreenButton = %BTN_South
@onready var _btn_east: TouchScreenButton = %BTN_East
@onready var _btn_west: TouchScreenButton = %BTN_West


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_north_action(a : String) -> void:
	if a != north_action:
		north_action = a
		if _btn_north != null:
			_btn_north.action = north_action

func set_south_action(a : String) -> void:
	if a != south_action:
		south_action = a
		if _btn_south != null:
			_btn_south.action = south_action

func set_east_action(a : String) -> void:
	if a != east_action:
		east_action = a
		if _btn_east != null:
			_btn_east.action = east_action

func set_west_action(a : String) -> void:
	if a != west_action:
		west_action = a
		if _btn_west != null:
			_btn_west.action = west_action

func set_passby_press(pbp : bool) -> void:
	passby_press = pbp
	if _btn_north != null:
		_btn_north.passby_press = passby_press
	if _btn_east != null:
		_btn_east.passby_press = passby_press
	if _btn_south != null:
		_btn_south.passby_press = passby_press
	if _btn_west != null:
		_btn_west.passby_press = passby_press

func set_spread(s : float) -> void:
	if s >= 0.0 and not is_equal_approx(spread, s):
		spread = s
		_UpdateButtonSpread()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectButton(_btn_north, north_action, DIRECTION_NORTH)
	_ConnectButton(_btn_south, south_action, DIRECTION_SOUTH)
	_ConnectButton(_btn_east, east_action, DIRECTION_EAST)
	_ConnectButton(_btn_west, west_action, DIRECTION_WEST)
	_UpdateButtonSpread()

func _validate_property(property: Dictionary) -> void:
	if property.name in ["north_action", "south_action", "west_action", "east_action"]:
		var options : String = ""
		for prop : Dictionary in ProjectSettings.get_property_list():
			if not prop.name.begins_with(_PROJSETTINGS_PROP_INPUT_PREFIX): continue
			var split : PackedStringArray = prop.name.split("/")
			if split.size() != 2: continue
			
			if options.is_empty():
				options = split[1]
			else: options = "%s,%s"%[options, split[1]]
		property.hint_string = options

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectButton(btn : TouchScreenButton, action : String, direction : int) -> void:
	if btn == null: return
	btn.action = action
	btn.passby_press = passby_press
	btn.pressed.connect(_on_touch_button_pressed.bind(direction))
	btn.released.connect(_on_touch_button_released.bind(direction))

func _UpdateButtonSpread() -> void:
	if _btn_north != null and _btn_north.texture_normal != null:
		var tsize : Vector2 = _btn_north.texture_normal.get_size()
		_btn_north.position = (Vector2.UP * (tsize.y + spread)) + (Vector2.LEFT * tsize.x * 0.5)
	
	if _btn_south != null and _btn_south.texture_normal != null:
		var tsize : Vector2 = _btn_south.texture_normal.get_size()
		_btn_south.position = (Vector2.DOWN * spread) + (Vector2.LEFT * tsize.x * 0.5)
	
	if _btn_east != null and _btn_east.texture_normal != null:
		var tsize : Vector2 = _btn_east.texture_normal.get_size()
		_btn_east.position = (Vector2.UP * tsize.y * 0.5) + (Vector2.RIGHT * spread)

	if _btn_west != null and _btn_west.texture_normal != null:
		var tsize : Vector2 = _btn_west.texture_normal.get_size()
		_btn_west.position = (Vector2.UP * tsize.y * 0.5) + (Vector2.LEFT * (tsize.x + spread))

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_touch_button_pressed(direction : int) -> void:
	pressed.emit.call_deferred()
	direction_pressed.emit.call_deferred(direction)

func _on_touch_button_released(direction : int) -> void:
	released.emit.call_deferred()
	direction_released.emit.call_deferred(direction)
