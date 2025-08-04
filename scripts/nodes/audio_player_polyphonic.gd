@tool
extends Node
class_name AudioPlayerPolyphonic


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var bus : StringName = &"Master":			set=set_bus
@export var polyphony : int = 32:					set=set_polyphony

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _asp : AudioStreamPlayer = null
var _poly : AudioStreamPolyphonic = null
var _playback : AudioStreamPlaybackPolyphonic = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_bus(b : StringName) -> void:
	if not b.is_empty() and b != bus:
		var busidx : int = AudioServer.get_bus_index(b)
		if busidx >= 0:
			bus = b
			if _asp != null:
				_asp.bus = bus

func set_polyphony(p : int) -> void:
	if p >= 0 and p != polyphony:
		polyphony = p
		if _poly != null:
			_poly.polyphony = polyphony

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_Build()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Build() -> void:
	if _asp != null: return
	_poly = AudioStreamPolyphonic.new()
	_poly.polyphony = polyphony
	
	_asp = AudioStreamPlayer.new()
	_asp.stream = _poly
	_asp.bus  = bus
	add_child(_asp)
	_asp.play()
	
	_playback = _asp.get_stream_playback()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_playing(id : int) -> bool:
	if _playback != null:
		return _playback.is_stream_playing(id)
	return false

func play(stream : AudioStream, offset : float = 0.0, volume_db : float = 0.0, pitch : float = 1.0) -> int:
	if _playback == null or stream == null: return -1
	return _playback.play_stream(
		stream, offset, volume_db, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, bus
	)

func stop(id : int) -> void:
	if _playback != null:
		_playback.stop_stream(id)
