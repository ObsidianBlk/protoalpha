extends ActorState


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
	
	actor.room_shift_toggle(3, 0.25)
	if not actor.toggle_room_shift.is_connected(_on_toggled):
		actor.toggle_room_shift.connect(_on_toggled)

func exit() -> void:
	if actor != null:
		if actor.toggle_room_shift.is_connected(_on_toggled):
			actor.toggle_room_shift.disconnect(_on_toggled)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_toggled() -> void:
	if not state_idle.is_empty():
		swap_to(state_idle)
