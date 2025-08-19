extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal volume_changed(bus_name : StringName)
signal muted(bus_name : StringName)
signal unmuted(bus_name : StringName)

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
#var _music_asp : AudioPlayerPolyphonic = null
#var _sfx_asp : AudioPlayerPolyphonic = null
var _music_asps : Dictionary[StringName, AudioPlayerPolyphonic] = {}
var _sfx_asps : Dictionary[StringName, AudioPlayerPolyphonic] = {}

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.loaded.connect(_on_settings_loaded)
	Settings.reset.connect(_on_settings_reset)
	
	_CreatePolyphonics(_music_asps, &"Master", BUS_MUSIC, 2)
	_CreatePolyphonics(_music_asps, &"Game", &"GameMusic", 2)
	
	_CreatePolyphonics(_sfx_asps, &"Master", BUS_SFX)
	_CreatePolyphonics(_sfx_asps, &"Game", &"GameSFX")

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CreatePolyphonics(asps : Dictionary[StringName, AudioPlayerPolyphonic], key : StringName, bus : StringName, polyphony : int = 0) -> void:
	var busidx : int = AudioServer.get_bus_index(bus)
	if busidx < 0:
		print_debug("WARNING: Audio bus '", bus, "' does not exist! Cannot create associated audio player.")
		return
	if key in asps:
		print_debug("WARNING: ASP key '", key, "' already defined.")
		return
	asps[key] = AudioPlayerPolyphonic.new()
	asps[key].bus = bus
	if polyphony > 0:
		asps[key].polyphony = polyphony
	add_child(asps[key])

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

func mute(bus_name : StringName, enable : bool) -> void:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx < 0: return
	AudioServer.set_bus_mute(busidx, enable)
	if enable:
		muted.emit(bus_name)
	else:
		unmuted.emit(bus_name)

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

func is_mute(bus_name : StringName) -> bool:
	var busidx : int = AudioServer.get_bus_index(bus_name)
	if busidx >= 0:
		return AudioServer.is_bus_mute(busidx)
	return false

func get_sfx_player(asp_name : StringName = &"Master") -> AudioPlayerPolyphonic:
	if asp_name in _sfx_asps:
		return _sfx_asps[asp_name]
	return null

func get_music_player(asp_name : StringName = &"Master") -> AudioPlayerPolyphonic:
	if asp_name in _music_asps:
		return _music_asps[asp_name]
	return null

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
