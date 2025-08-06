extends PanelContainer


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _vslider_master: VSlider = %VSLIDER_Master
@onready var _vslider_music: VSlider = %VSLIDER_Music
@onready var _vslider_sfx: VSlider = %VSLIDER_SFX


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	AudioBoard.volume_changed.connect(_on_audio_board_volume_changed)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _AudioBoardToVolumeSlider(bus : StringName, slider : VSlider) -> void:
	var vol : float = AudioBoard.get_volume_linear(bus) * slider.max_value
	slider.set_value_no_signal(vol)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_audio_board_volume_changed(bus : StringName) -> void:
	match bus:
		AudioBoard.BUS_MASTER:
			_AudioBoardToVolumeSlider(bus, _vslider_master)
		AudioBoard.BUS_MUSIC:
			_AudioBoardToVolumeSlider(bus, _vslider_music)
		AudioBoard.BUS_SFX:
			_AudioBoardToVolumeSlider(bus, _vslider_sfx)

func _on_vslider_master_value_changed(value: float) -> void:
	var p : float = value / _vslider_master.max_value
	AudioBoard.set_volume(AudioBoard.BUS_MASTER, p, true)

func _on_vslider_music_value_changed(value: float) -> void:
	var p : float = value / _vslider_music.max_value
	AudioBoard.set_volume(AudioBoard.BUS_MUSIC, p, true)

func _on_vslider_sfx_value_changed(value: float) -> void:
	var p : float = value / _vslider_sfx.max_value
	AudioBoard.set_volume(AudioBoard.BUS_SFX, p, true)
