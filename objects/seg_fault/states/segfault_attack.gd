extends ActorState


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_ATTACK : StringName = &"attack"

const ACTION_STATE_MOVE : StringName = &"movement"
const ACTION_STATE_ATTACK : StringName = &"teleport"

const APARAM_STATE : String = "parameters/state/transition_request"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	actor.velocity = Vector2.ZERO
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	actor.set_tree_param(APARAM_STATE, ACTION_STATE_ATTACK)

func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)
		actor.set_tree_param(APARAM_STATE, ACTION_STATE_MOVE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_ATTACK:
		# TODO: Fire actual weapon
		swap_to(state_idle)
