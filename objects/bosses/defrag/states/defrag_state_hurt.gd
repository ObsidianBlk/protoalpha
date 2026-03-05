extends ActorState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var hurt_duration : float = 1.0
@export var idle_state : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _duration : float = 0.0

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	actor.change_action(actor.CORE_ACTION_HURT)
	_duration = hurt_duration

func exit() -> void:
	pass

func update(delta : float) -> void:
	_duration -= delta
	if _duration <= 0.0:
		swap_to(idle_state)
