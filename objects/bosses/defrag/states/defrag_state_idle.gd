extends ActorState


# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null: return
	actor.change_action(actor.CORE_ACTION_IDLE)

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	pass
