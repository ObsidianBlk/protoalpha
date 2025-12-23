extends PanelContainer


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal coded(num : int)
signal close_game()
signal open_game()
signal fullscreen_toggled()
signal quit_application()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const KEYPAD_CODE_TV_VIEW : int = 3
const KEYPAD_CODE_FULL_VIEW : int = 2
const KEYPAD_CODE_TOGGLE_CRT : int = 42
const KEYPAD_CODE_TOGGLE_FULLSCREEN : int = 0

const SETTINGS_SECTION : String = "General"
const SETTINGS_KEY : String = "default_channel"

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _vslider_master: VSlider = %VSLIDER_Master
@onready var _vslider_music: VSlider = %VSLIDER_Music
@onready var _vslider_sfx: VSlider = %VSLIDER_SFX
@onready var _key_pad: KeyPad = %KeyPad


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.loaded.connect(_on_settings_loaded)
	Settings.reset.connect(_on_settings_reset)
	Settings.value_changed.connect(_on_settings_value_changed)
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
func _on_settings_loaded() -> void:
	var c : Variant = Settings.load_value(SETTINGS_SECTION, SETTINGS_KEY, KeyPad.DEFAULT_CODE)
	if typeof(c) == TYPE_INT:
		_key_pad.set_default_code(c)

func _on_settings_reset() -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY, KeyPad.DEFAULT_CODE)
	_key_pad.set_default_code(KeyPad.DEFAULT_CODE)

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section == SETTINGS_SECTION and key == SETTINGS_KEY:
		if typeof(value) == TYPE_INT:
			_key_pad.set_default_code(value)

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

func _on_key_pad_coded(value: int) -> void:
	match value:
		KEYPAD_CODE_TV_VIEW, KEYPAD_CODE_FULL_VIEW:
			_key_pad.set_default_code(value)
			Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY, value)
			print(Settings.get_value(SETTINGS_SECTION, SETTINGS_KEY, 55))
		KEYPAD_CODE_TOGGLE_CRT:
			var crt : CRTEffect = CRTEffect.Get()
			if crt != null:
				crt.enabled = not crt.enabled
			_key_pad.reset()
			value = _key_pad.get_default_code()
		KEYPAD_CODE_TOGGLE_FULLSCREEN:
			fullscreen_toggled.emit()
			_key_pad.reset()
			value = _key_pad.get_default_code()
	coded.emit(value)

func _on_key_pad_power_cycled(power_on: bool) -> void:
	if OS.has_feature("wasm"):
		if power_on:
			open_game.emit()
	else:
		if not power_on:
			quit_application.emit()

func _on_key_pad_power_pressed() -> void:
	if OS.has_feature("wasm"):
		if _key_pad.is_powered():
			close_game.emit()
	else:
		close_game.emit()
