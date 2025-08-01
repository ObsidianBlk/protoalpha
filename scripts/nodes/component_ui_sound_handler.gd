extends Node
class_name ComponentUISoundHandler

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var sound_sheet : SoundSheet = null

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
	parent.register_action_handler(Game.UI_ACTION_SOUND, _HandleSoundRequest)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _HandleSoundRequest(sound_name : StringName) -> void:
	if sound_sheet == null: return
	sound_sheet.play(sound_name)
