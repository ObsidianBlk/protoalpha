extends Node


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BUS_MASTER : StringName = &"Master"
const BUS_MUSIC : StringName = &"Music"
const BUS_SFX : StringName = &"SFX"


# ------------------------------------------------------------------------------
# Public Variables
# ------------------------------------------------------------------------------
var sfx_polyphony : int = 32

# ------------------------------------------------------------------------------
# Private Variables
# ------------------------------------------------------------------------------
var _music_asp : AudioStreamPlayer = null
var _sfx_asp : AudioStreamPlayer = null
var _sfx_poly : AudioStreamPolyphonic = null
var _sfx_playback : AudioStreamPlaybackPolyphonic = null


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_sfx_polyphony(p : int) -> void:
	if p > 0 and p != sfx_polyphony:
		sfx_polyphony = p
		if _sfx_poly != null:
			_sfx_poly.polyphony = sfx_polyphony

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_BuildSFXPlayer()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _BuildSFXPlayer() -> void:
	if _sfx_asp == null:
		_sfx_poly = AudioStreamPolyphonic.new()
		_sfx_poly.polyphony = sfx_polyphony
		
		_sfx_asp = AudioStreamPlayer.new()
		_sfx_asp.bus = BUS_SFX
		_sfx_asp.stream = _sfx_poly
		add_child(_sfx_asp)
		_sfx_asp.play()
		
		_sfx_playback = _sfx_asp.get_stream_playback()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_sfx_playing(sfx_id : int) -> bool:
	if _sfx_playback != null:
		return _sfx_playback.is_stream_playing(sfx_id)
	return false

func play_sfx(stream : AudioStream, offset : float = 0.0, volume_db : float = 0.0, pitch : float = 1.0) -> int:
	if _sfx_playback == null or stream == null: return -1
	return _sfx_playback.play_stream(
		stream, offset, volume_db, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, BUS_SFX
	)

func stop_sfx(sfx_id : int) -> void:
	if _sfx_playback != null:
		_sfx_playback.stop_stream(sfx_id)
