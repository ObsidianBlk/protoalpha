extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_move : StringName = &""
@export var state_jump : StringName = &""
@export var state_fall : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _move_direction : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	actor.set_tree_param(APARAM_TRANSITION, TRANS_CLIMB)
	_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	_CheckMovement()

func exit() -> void:
	actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)

func update(_delta : float) -> void:
	if actor == null: return
	
	if not actor.is_on_surface():
		if not state_fall.is_empty():
			swap_to(state_fall)

func physics_update(_delta : float) -> void:
	if actor == null: return
	
	if is_equal_approx(_move_direction.y, 0.0):
		actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
	else:
		actor.set_tree_param(APARAM_TRANSITION, TRANS_CLIMB)
	
	actor.velocity.y = _move_direction.y * actor.speed * 0.5
	actor.move_and_slide()
	if actor.is_crushed():
		actor.die()

func handle_input(event : InputEvent) -> void:
	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		_CheckMovement()
	elif event.is_action_pressed(&"jump"):
		if not state_jump.is_empty():
			swap_to(state_jump)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckMovement() -> void:
	if actor == null: return

	var climbing : bool = not is_equal_approx(_move_direction.y, 0.0)
	if not climbing and not is_equal_approx(_move_direction.x, 0.0):
		swap_to(state_move, _move_direction)
	elif climbing:
		actor.velocity.x = 0.0
