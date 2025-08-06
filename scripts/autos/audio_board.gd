extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal volume_changed(bus_name : StringName)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CONFIG_SECTION : String = "Audio"
const BUS_MASTER : StringName = &"Master"
const BUS_MUSIC : StringName = &"Music"
const BUS_SFX : StringName = &"SFX"

const MIN_VOLUME_DB : float = -80.0
const MAX_VOLUME_DB : float = 24.0

const VOLUME_DEFAULT : float = 1.0
const VOLUME_DEFAULT_MUSIC : float = 0.6


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _music_asp : AudioPlayerPolyphonic = null
var _sfx_asp : AudioPlayerPolyphonic = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.loaded.connect(_on_settings_loaded)
	Settings.reset.connect(_on_settings_reset)
	
	_music_asp = AudioPlayerPolyphonic.new()
	_music_asp.bus = BUS_MUSIC
	_music_asp.polyphony = 2
	add_child(_music_asp)
	
	_sfx_asp = AudioPlayerPolyphonic.new()
	_sfx_asp.bus = BUS_SFX
	add_child(_sfx_asp)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SetVolume(bus_name : StringName, volume_db : float) -> bool:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx < 0: return false
	volume_db = clampf(volume_db, MIN_VOLUME_DB, MAX_VOLUME_DB)
	
	AudioServer.set_bus_volume_db(busidx, volume_db)
	Settings.set_value(CONFIG_SECTION, bus_name, db_to_linear(volume_db))
	volume_changed.emit(bus_name)
	return true

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_volume(bus_name : StringName, volume : float, volume_linear : bool = false) -> void:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx < 0: return
	
	var volume_db = volume
	if volume_linear:
		volume_db = linear_to_db(clampf(volume, 0.0, 1.0))
		if volume_db <= -INF:
			volume_db = MIN_VOLUME_DB
		else: volume_db = clampf(volume_db, MIN_VOLUME_DB, MAX_VOLUME_DB)
	
	_SetVolume(bus_name, volume_db)

func get_volume_db(bus_name : StringName) -> float:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx >= 0:
		return AudioServer.get_bus_volume_db(busidx)
	return 0.0

func get_volume_linear(bus_name : StringName) -> float:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx >= 0:
		return AudioServer.get_bus_volume_linear(busidx)
	return 0.0

func get_sfx_player() -> AudioPlayerPolyphonic:
	return _sfx_asp

func get_music_player() -> AudioPlayerPolyphonic:
	return _music_asp

# ------------------------------------------------------------------------------
# HANDLER Methods
# ------------------------------------------------------------------------------
func _on_settings_reset() -> void:
	set_volume(BUS_MASTER, VOLUME_DEFAULT, true)
	set_volume(BUS_MUSIC, VOLUME_DEFAULT_MUSIC, true)
	set_volume(BUS_SFX, VOLUME_DEFAULT, true)

func _on_settings_loaded() -> void:
	set_volume(BUS_MASTER, Settings.load_value(CONFIG_SECTION, BUS_MASTER, VOLUME_DEFAULT), true)
	set_volume(BUS_MUSIC, Settings.load_value(CONFIG_SECTION, BUS_MUSIC, VOLUME_DEFAULT_MUSIC), true)
	set_volume(BUS_SFX, Settings.load_value(CONFIG_SECTION, BUS_SFX, VOLUME_DEFAULT), true)
