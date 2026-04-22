extends Node
class_name ComponentUISoundHandler

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
## UI Action - Play sound effect
const UI_ACTION_SOUND : StringName = &"sound"
## UI Action - Prevent the next sound from playing
const UI_ACTION_BLOCK_NEXT_SOUND : StringName = &"block_next_sound"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var sound_sheet : SoundSheet = null


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _block_next_sound : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	var parent : Node = get_parent()
	if not parent is UILayer:
		printerr("ComponentUISoundHandler parent, ", parent.name, ", expected to be a UILayer object.")
		return
	if not parent.is_node_ready():
		await parent.ready
	parent.register_action_handler(UI_ACTION_SOUND, _HandleSoundRequest)
	parent.register_action_handler(UI_ACTION_BLOCK_NEXT_SOUND, _HandleBlockNextSound)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _HandleSoundRequest(sound_name : StringName) -> void:
	if sound_sheet == null: return
	if not _block_next_sound:
		sound_sheet.play(sound_name)
	else: _block_next_sound = false

func _HandleBlockNextSound() -> void:
	_block_next_sound = true
