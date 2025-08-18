extends ActorState


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_TELEPORT_IN : StringName = &"teleport_in"
const ANIM_TELEPORT_OUT : StringName = &"teleport_out"

const ACTION_TELEPORT_IN : StringName = &"in"
const ACTION_TELEPORT_OUT : StringName = &"out"

const ACTION_STATE_MOVE : StringName = &"movement"
const ACTION_STATE_TELEPORT : StringName = &"teleport"

const APARAM_STATE : String = "parameters/state/transition_request"
const APARAM_TELEPORT : String = "parameters/teleport/transition_request"

const TELEPORT_DELAY : float = 1.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_attack : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tp_delay : float = 0.0

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
		
	# TODO: Disable all collisions
	
	actor.velocity = Vector2.ZERO
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	_tp_delay = 0.0
	actor.set_tree_param(APARAM_STATE, ACTION_STATE_TELEPORT)
	actor.set_tree_param(APARAM_TELEPORT, ACTION_TELEPORT_OUT)

func exit() -> void:
	if actor != null:
		
		# TODO: Re-Enable all collisions
		
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)
		actor.set_tree_param(APARAM_STATE, ACTION_STATE_MOVE)

func update(delta : float) -> void:
	if _tp_delay > 0.0:
		_tp_delay -= delta
		if _tp_delay <= 0.0:
			actor.global_position = actor.get_teleport_position()
			actor.set_tree_param(APARAM_TELEPORT, ACTION_TELEPORT_IN)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	match anim_name:
		ANIM_TELEPORT_OUT:
			_tp_delay = TELEPORT_DELAY
		ANIM_TELEPORT_IN:
			swap_to(state_attack)
