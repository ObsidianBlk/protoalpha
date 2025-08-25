extends ActorState
class_name SegFaultState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_TELEPORT_IN : StringName = &"teleport_in"
const ANIM_TELEPORT_OUT : StringName = &"teleport_out"
const ANIM_ATTACK : StringName = &"attack"
const ANIM_HURT : StringName = &"hurt"
const ANIM_DEAD : StringName = &"dead"

const ACTION_TELEPORT_IN : StringName = &"in"
const ACTION_TELEPORT_OUT : StringName = &"out"

const ACTION_STATE_MOVE : StringName = &"movement"
const ACTION_STATE_TELEPORT : StringName = &"teleport"
const ACTION_STATE_ATTACK : StringName = &"attack"
const ACTION_STATE_DEAD : StringName = &"dead"

const ONCE_FIRE : int = 1

const APARAM_STATE : String = "parameters/state/transition_request"
const APARAM_TELEPORT : String = "parameters/teleport/transition_request"
const APARAM_ONCE_HURT : String = "parameters/hurt/request"


# ------------------------------------------------------------------------------
# Public Functions
# ------------------------------------------------------------------------------
func get_hitbox() -> HitBox:
	if actor != null:
		for child : Node in actor.get_children():
			if child is HitBox:
				return child
	return null

func enable_hitbox(enable : bool = true) -> void:
	var hitbox : HitBox = get_hitbox()
	if hitbox != null:
		hitbox.disable_mask(not enable)

func get_player_direction(player : CharacterActor2D) -> float:
	if actor != null and player != null:
		var dir : Vector2 = actor.global_position.direction_to(player.global_position)
		return sign(dir.x)
	return 0.0
