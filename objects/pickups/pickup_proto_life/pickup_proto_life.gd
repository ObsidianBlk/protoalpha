@tool
extends Pickup


# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func handle_pick_up(body : Node2D) -> void:
	Game.State.lives += 1
	super.handle_pick_up(body)
