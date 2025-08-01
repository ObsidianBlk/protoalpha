extends Node
class_name ComponentUISound

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var signal_sounds : Dictionary[StringName, StringName] = {}:	set=set_signal_sounds

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_signal_sounds(s : Dictionary[StringName, StringName]) -> void:
	_DisconnectSignals()
	signal_sounds = s
	_ConnectSignals()


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectSignals()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSignals() -> void:
	var parent : Node = get_parent()
	if not parent is Control: return
	
	for signal_name : StringName in signal_sounds.keys():
		if not signal_name.is_empty() and not signal_sounds[signal_name].is_empty():
			var sound_name : StringName = signal_sounds[signal_name]
			if parent.has_signal(signal_name) or parent.has_user_signal(signal_name):
				if not parent.is_connected(signal_name, _on_signaled.bind(sound_name)):
					parent.connect(signal_name, _on_signaled.bind(sound_name))

func _DisconnectSignals() -> void:
	var parent : Node = get_parent()
	if not parent is Control: return
	
	for signal_name : StringName in signal_sounds.keys():
		if not signal_name.is_empty() and not signal_sounds[signal_name].is_empty():
			var sound_name : StringName = signal_sounds[signal_name]
			if parent.has_signal(signal_name) or parent.has_user_signal(signal_name):
				if parent.is_connected(signal_name, _on_signaled.bind(sound_name)):
					parent.disconnect(signal_name, _on_signaled.bind(sound_name))

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_signaled(sound_name : StringName) -> void:
	if owner is UIControl:
		owner.request(Game.UI_ACTION_SOUND, [sound_name])
