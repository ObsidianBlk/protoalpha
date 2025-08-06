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

var _streams : Dictionary[int, bool] = {}

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
	if id in _streams:
		if _playback != null:
			if _playback.is_stream_playing(id):
				return true
		_streams.erase(id)
	return false

func get_active_stream_ids() -> Array[int]:
	var arr : Array[int] = []
	for id : int in _streams.keys():
		if is_playing(id):
			arr.append(id)
	return arr

func play(stream : AudioStream, offset : float = 0.0, volume_db : float = 0.0, pitch : float = 1.0) -> int:
	if _playback == null or stream == null: return -1
	var id : int = _playback.play_stream(
		stream, offset, volume_db, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, bus
	)
	if id >= 0:
		_streams[id] = true
	return id

func set_volume_db(id : int, volume_db : float) -> void:
	if is_playing(id):
		_playback.set_stream_volume(id, volume_db)

func set_volume_linear(id : int, volume : float) -> void:
	if is_playing(id):
		_playback.set_stream_volume(id, linear_to_db(clampf(volume, 0.0, 1.0)))

func stop(id : int) -> void:
	if is_playing(id):
		_playback.stop_stream(id)
		_streams.erase(id)

func stop_all() -> void:
	for id : int in _streams.keys():
		stop(id)
