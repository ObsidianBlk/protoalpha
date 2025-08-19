@tool
extends MarginContainer
class_name TVChannels

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CHANNEL_GAME : int = 3
const CHANNEL_GAME_DISTORTED : int = 2
const CHANNEL_CRT : int = 42

const RESERVED : Array[int] = [
	CHANNEL_GAME_DISTORTED,
	CHANNEL_GAME,
	CHANNEL_CRT
]

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var smpte_channels : Dictionary[int, SMPTEChannel] = {}

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _channels : Dictionary[int, TVChannel] = {}
var _current : int = CHANNEL_GAME

# ------------------------------------------------------------------------------
# Private Static Methods
# ------------------------------------------------------------------------------
static var _Instance : TVChannels = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _smpte_message: Label = %SMPTE_Message
@onready var _smpte: MarginContainer = %SMPTE

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered)
	child_exiting_tree.connect(_on_child_exiting)
	for child : Node in get_children():
		_RegisterChannel(child)
	hide_smpte()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _RegisterChannel(c : Node) -> void:
	if not c is TVChannel: return
	c.visible = false
	if c.channel_number in RESERVED:
		print_debug("Failed to register channel on reserved number ", c.channel_number)
		return
	if c.channel_number in _channels:
		print_debug("Channel collision on number ", c.channel_number)
		return
	_channels[c.channel_number] = c
	if not c.smpte_show_requested.is_connected(show_smpte):
		c.smpte_show_requested.connect(show_smpte)
	if not c.smpte_hide_requested.is_connected(hide_smpte):
		c.smpte_hide_requested.connect(hide_smpte)

func _DeregisterChannel(c : Node) -> void:
	if not c is TVChannel: return
	
	if c.smpte_show_requested.is_connected(show_smpte):
		c.smpte_show_requested.disconnect(show_smpte)
	if c.smpte_hide_requested.is_connected(hide_smpte):
		c.smpte_hide_requested.disconnect(hide_smpte)
	
	if c.channel_number in _channels:
		if c.channel_number == _current:
			c.exit()
			show_channel(CHANNEL_GAME)
		_channels.erase(c.channel_number)

func _ShowSMPTE(info : SMPTEChannel, clear_static : bool = false) -> void:
	if info == null:
		if clear_static:
			hide_smpte()
			StaticEffect.Set_Effect(0.0, 0.0)
		else:
			show_smpte()
			StaticEffect.Set_Effect(1.0, 0.0)
	else:
		show_smpte(info.message)
		StaticEffect.Set_Effect(info.static_intensity, info.static_bleed)
	

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
func Show_SMPTE(msg : String = "") -> void:
	if _Instance != null:
		_Instance.show_smpte(msg)

func Hide_SMPTE() -> void:
	if _Instance != null:
		_Instance.hide_smpte()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func show_smpte(msg : String = "") -> void:
	if not _smpte.visible:
		_smpte.visible = true
	_smpte_message.visible = not msg.is_empty()
	_smpte_message.text = msg

func hide_smpte() -> void:
	_smpte.visible = false

func show_channel(channel : int) -> void:
	if _current == channel: return
	
	if _current in _channels:
		_channels[_current].exit()
	
	match channel:
		CHANNEL_GAME_DISTORTED, CHANNEL_GAME:
			if channel == CHANNEL_GAME_DISTORTED:
				pass
			AudioBoard.mute(&"GameSFX", false)
			AudioBoard.mute(&"GameMusic", false)
			hide_smpte()
			StaticEffect.Set_Effect(0.0, 0.0)
		CHANNEL_CRT:
			# Override the channel. The effect for this channel is handled elsewhere.
			show_channel(CHANNEL_GAME)
			return
		_:
			AudioBoard.mute(&"GameSFX", true)
			AudioBoard.mute(&"GameMusic", true)
			if channel in _channels:
				_channels[channel].enter()
			else:
				var chn : SMPTEChannel = null
				if channel in smpte_channels:
					chn = smpte_channels[channel]
				_ShowSMPTE(chn)
	_current = channel

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered(child : Node) -> void:
	_RegisterChannel(child)

func _on_child_exiting(child : Node) -> void:
	_DeregisterChannel(child)
