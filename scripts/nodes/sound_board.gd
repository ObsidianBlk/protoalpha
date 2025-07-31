extends Node
class_name SoundBoard


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var polyphony = 32:											set=set_polyphony
@export var bus : StringName = &"Master":							set=set_bus
@export var streams : Dictionary[StringName, AudioStream] = {}


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _asp : AudioStreamPlayer = null
var _playback : AudioStreamPlaybackPolyphonic = null

# ------------------------------------------------------------------------------
# Static Private Variables
# ------------------------------------------------------------------------------
static var _instance : SoundBoard = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_polyphony(p : int) -> void:
	if p > 0 and p != polyphony:
		polyphony = p
		_UpdateASP()

func set_bus(b : StringName) -> void:
	if b != bus and AudioServer.get_bus_index(b) >= 0:
		bus = b
		_UpdateASP()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_asp = AudioStreamPlayer.new()
	add_child(_asp)
	_asp.stream = AudioStreamPolyphonic.new()
	_UpdateASP()
	_asp.play()
	_playback = _asp.get_stream_playback()
	if _playback == null:
		print("Failed to obtain polyphonic stream playback")

func _enter_tree() -> void:
	if _instance == null:
		_instance = self

func _exit_tree() -> void:
	if _instance == self:
		_instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateASP() -> void:
	if _asp == null: return
	_asp.bus = bus
	_asp.stream.polyphony = polyphony

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get() -> SoundBoard:
	return _instance

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_playing(stream_id : int) -> bool:
	if _playback != null:
		return _playback.is_stream_playing(stream_id)
	return false

func play(stream : AudioStream, offset : float = 0.0, volume_db : float = 0.0, pitch : float = 1.0) -> int:
	if _playback == null or stream == null: return -1
	return _playback.play_stream(
		stream, offset, volume_db, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, bus
	)

func stop(stream_id : int) -> void:
	if _playback != null:
		_playback.stop_stream(stream_id)
