extends ActorState
class_name SegFaultState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_TELEPORT_IN : StringName = &"teleport_in"
const ANIM_TELEPORT_OUT : StringName = &"teleport_out"
const ANIM_ATTACK : StringName = &"attack"
const ANIM_ATTACK_STREAK_START : StringName = &"attack2_start"
const ANIM_ATTACK_STREAK_END : StringName = &"attack2_end"
const ANIM_HURT : StringName = &"hurt"
const ANIM_DEAD : StringName = &"dead"

const ACTION_TELEPORT_IN : String = "in"
const ACTION_TELEPORT_OUT : String = "out"

const ACTION_STATE_MOVE : String = "movement"
const ACTION_STATE_TELEPORT : String = "teleport"
const ACTION_STATE_ATTACK : String = "attack"
const ACTION_STATE_DEAD : String = "dead"

const ACTION_ATTACK_BULLET : String = "attack_bullet"
const ACTION_ATTACK_STREAK : String = "attack_streak"

const ACTION_ATTACK_STREAK_START : String = "start"
const ACTION_ATTACK_STREAK_END : String = "end"

const ONCE_FIRE : int = 1

const APARAM_STATE : String = "parameters/state/transition_request"
const APARAM_TELEPORT : String = "parameters/teleport/transition_request"
const APARAM_ATTACK_TYPE : String = "parameters/attack_type/transition_request"
const APARAM_ATTACK_STREAK_SE : String = "parameters/a2se/transition_request"
const APARAM_ONCE_ATTACK2 : String = "parameters/a2shot/request"
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
