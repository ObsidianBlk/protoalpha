extends SegFaultState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 20.0
@export var state_idle : StringName = &""

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	enable_hitbox()

func physics_update(_delta : float) -> void:
	if actor == null: return
	var player : CharacterActor2D = actor.get_player()
	if player == null:
		swap_to(state_idle)
		return
	
	var dir : float = get_player_direction(player)
	actor.velocity.x = speed * dir
	
	if actor.is_on_surface():
		swap_to(state_idle)
	actor.velocity.y = actor.get_gravity().y
	
	actor.move_and_slide()
