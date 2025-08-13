extends ProtoState

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 40.0

@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_move : StringName = &""

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
	
	_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func update(_delta : float) -> void:
	if actor == null: return
	
	if actor.is_on_surface():
		play_sfx(AUDIO_LAND)
		if is_equal_approx(_move_direction.x, 0.0):
			swap_to(state_idle)
		else:
			swap_to(state_move, _move_direction)


func physics_update(_delta : float) -> void:
	if actor == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		actor.flip(_move_direction.x < 0.0)
	
	actor.velocity.x = _move_direction.x * speed
	actor.velocity.y = 0.0 if actor.is_on_surface() else actor.get_gravity().y
	actor.move_and_slide()

func handle_input(event : InputEvent) -> void:
	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
