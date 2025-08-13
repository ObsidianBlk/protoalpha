extends State
class_name ActorState


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var actor : CharacterActor2D = null

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func set_host(host : Node) -> void:
	if host == null or host is CharacterActor2D:
		actor = host

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func play_sfx(audio_name : StringName) -> int:
	if actor != null and actor.sound_sheet != null:
		return actor.sound_sheet.play(audio_name)
	return -1

func stop_sfx(id : int) -> void:
	if actor != null and actor.sound_sheet != null:
		actor.sound_sheet.stop(id)
