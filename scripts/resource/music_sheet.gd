@tool
extends Resource
class_name MusicSheet


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const META_VOLUME : StringName = &"volume"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var music_list : Dictionary[StringName, SoundEntry] = {}:		set=set_music_list


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _streams : Dictionary[StringName, int] = {}
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
func set_music_list(ml : Dictionary[StringName, SoundEntry]) -> void:
	_DisconnectSoundEntries()
	for music_name : StringName in ml.keys():
		if ml[music_name] == null:
			ml.erase(music_name)
	music_list = ml
	_ConnectSoundEntries()
	changed.emit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSoundEntries() -> void:
	for mn : StringName in music_list.keys():
		var entry : SoundEntry = music_list[mn]
		if not entry.changed.is_connected(_on_sound_entry_changed.bind(entry)):
			entry.changed.connect(_on_sound_entry_changed.bind(entry))

func _DisconnectSoundEntries() -> void:
	for mn : StringName in music_list.keys():
		var entry : SoundEntry = music_list[mn]
		if entry.changed.is_connected(_on_sound_entry_changed.bind(entry)):
			entry.changed.disconnect(_on_sound_entry_changed.bind(entry))

func _GetCurrentVolume(entry : SoundEntry) -> float:
	if entry != null:
		if entry.has_meta(META_VOLUME):
			var volume : Variant = entry.get_meta(META_VOLUME, db_to_linear(entry.volume_db))
			if typeof(volume) == TYPE_FLOAT:
				return volume
		else: return db_to_linear(entry.volume_db)
	return 0.0

func _SetCurrentVolume(entry : SoundEntry, volume : float) -> void:
	if entry == null: return
	entry.set_meta(META_VOLUME, volume)

func _FadeIn(player : AudioPlayerPolyphonic, music_name : StringName, duration : float) -> void:
	if _tween != null: return
	if music_name in _streams:
		var id : int = _streams[music_name]
		var target_volume : float = db_to_linear(music_list[music_name].volume_db)
		_tween = player.create_tween()
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.set_trans(Tween.TRANS_LINEAR)
		_tween.tween_method(_on_tweened_volume.bind(player, music_name, id), 0.0, target_volume, duration)
		_tween.finished.connect(_on_tweened_volume_finished, CONNECT_ONE_SHOT)

func _CrossFade(player : AudioPlayerPolyphonic, from_music_name : StringName, to_music_name : StringName, duration : float) -> void:
	if _tween != null: return
	var from_volume : float = _GetCurrentVolume(music_list[from_music_name])
	var to_volume : float = _GetCurrentVolume(music_list[to_music_name])
	var to_target_volume : float = db_to_linear(music_list[to_music_name].volume_db)
	var from_id : int = _streams[from_music_name]
	var to_id : int = _streams[to_music_name]
	_tween = player.create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_LINEAR)
	_tween.set_parallel(true)
	_tween.tween_method(_on_tweened_volume.bind(player, from_music_name, from_id), from_volume, 0.0, duration)
	_tween.tween_method(_on_tweened_volume.bind(player, to_music_name, to_id), to_volume, to_target_volume, duration)
	_tween.finished.connect(_on_tweened_volume_finished.bind(from_music_name), CONNECT_ONE_SHOT)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_playing(music_name : StringName) -> bool:
	if music_name in _streams:
		var musicplayer : AudioPlayerPolyphonic = AudioBoard.get_music_player()
		if musicplayer != null:
			var id : int = _streams[music_name]
			var playing : bool = musicplayer.is_playing(id)
			if not playing : _streams.erase(music_name)
			return playing
		else: _streams.erase(music_name)
	return false

func currently_playing() -> StringName:
	if _streams.is_empty(): return &""
	if _streams.size() == 1:
		return _streams.keys()[0]
	return _streams.keys().reduce(
		(func(accum : String, val : StringName): return accum + ("" if accum.is_empty() else " <X> ") + val),
		""
	)

func play(music_name : StringName, crossfade_duration : float = 0.0) -> void:
	var musicplayer : AudioPlayerPolyphonic = AudioBoard.get_music_player()
	if musicplayer != null and music_name in music_list and music_list[music_name].stream != null:
		var music_playing : bool = is_playing(music_name)
		var entry : SoundEntry = music_list[music_name]
		
		if _streams.is_empty():
			var volume_db : float = entry.volume_db
			if crossfade_duration > 0.0:
				volume_db = linear_to_db(0.0)
			var id : int = musicplayer.play(entry.stream, 0.0, volume_db, entry.get_pitch())
			if id >= 0:
				_streams[music_name] = id
				if crossfade_duration > 0.0:
					_FadeIn(musicplayer, music_name, crossfade_duration)
		
		elif _streams.size() == 1:
			if music_name in _streams: return # Already playing
			var volume_db : float = linear_to_db(0.0)
			if crossfade_duration <= 0.0:
				stop_all()
				volume_db = entry.volume_db
			var id : int = musicplayer.play(entry.stream, 0.0, volume_db, entry.get_pitch())
			_SetCurrentVolume(music_list[music_name], db_to_linear(volume_db))
			if id >= 0:
				var from_music_name : StringName = &""
				if crossfade_duration > 0.0:
					from_music_name = _streams.keys()[0]
				_streams[music_name] = id
				if crossfade_duration > 0.0:
					_CrossFade(musicplayer, from_music_name, music_name, crossfade_duration)
		
		else:
			if music_name in _streams:
				var from_music_name : StringName = &""
				for mname : StringName in _streams.keys():
					if mname != music_name:
						from_music_name = mname
						break
				
				_tween.kill()
				_tween = null
				
				_CrossFade(musicplayer, from_music_name, music_name, crossfade_duration)
			else:
				stop_all()
				var volume_db = entry.volume_db
				if crossfade_duration > 0.0:
					volume_db = linear_to_db(0.0)
				var id : int = musicplayer.play(entry.stream, 0.0, volume_db, entry.get_pitch())
				if id >= 0:
					_streams[music_name] = id
					if crossfade_duration > 0.0:
						_FadeIn(musicplayer, music_name, crossfade_duration)


func stop(music_name : StringName) -> void:
	if music_name in _streams:
		var musicplayer : AudioPlayerPolyphonic = AudioBoard.get_music_player()
		if musicplayer != null:
			musicplayer.stop(_streams[music_name])
		_streams.erase(music_name)

func stop_all() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	for music_name : StringName in _streams.keys():
		stop(music_name)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_tweened_volume(volume : float, player : AudioPlayerPolyphonic, music_name : StringName, id : int) -> void:
	if player != null:
		player.set_volume_linear(id, volume)
		if music_name in music_list:
			music_list[music_name].set_meta(META_VOLUME, volume)

func _on_tweened_volume_finished(stop_music_name : StringName = &"") -> void:
	_tween = null
	if stop_music_name in _streams:
		stop(stop_music_name)

func _on_sound_entry_changed(entry : SoundEntry) -> void:
	# NOTE: I'm including the SoundEntry argument incase I think of something to use it for.
	changed.emit()
