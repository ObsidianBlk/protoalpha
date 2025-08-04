@tool
extends Resource
class_name SoundSheet


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var sound_list : Dictionary[StringName, SoundEntry] = {}:	set=set_sound_list


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_sound_list(sl : Dictionary[StringName, SoundEntry]) -> void:
	_DisconnectSoundEntries()
	for sound_name : StringName in sl.keys():
		if sl[sound_name] == null:
			sl.erase(sound_name)
	sound_list = sl
	_ConnectSoundEntries()
	changed.emit()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSoundEntries() -> void:
	for sn : StringName in sound_list.keys():
		var entry : SoundEntry = sound_list[sn]
		if not entry.changed.is_connected(_on_sound_entry_changed.bind(entry)):
			entry.changed.connect(_on_sound_entry_changed.bind(entry))

func _DisconnectSoundEntries() -> void:
	for sn : StringName in sound_list.keys():
		var entry : SoundEntry = sound_list[sn]
		if entry.changed.is_connected(_on_sound_entry_changed.bind(entry)):
			entry.changed.disconnect(_on_sound_entry_changed.bind(entry))

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func play(sound_name : StringName) -> int:
	if sound_name in sound_list and sound_list[sound_name].stream != null:
		var entry : SoundEntry = sound_list[sound_name]
		return AudioBoard.play_sfx(entry.stream, 0.0, entry.volume_db, entry.get_pitch())
	return -1

func stop(id : int) -> void:
	AudioBoard.stop_sfx(id)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_sound_entry_changed(entry : SoundEntry) -> void:
	# NOTE: I'm including the SoundEntry argument incase I think of something to use it for.
	changed.emit()
