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
	if proto == null:
		pop()
		return
	
	proto.play_animation(ANIM_FALL)
	_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func update(_delta : float) -> void:
	if proto == null: return
	
	if proto.is_on_surface():
		play_sfx(AUDIO_LAND)
		if is_equal_approx(_move_direction.x, 0.0):
			swap_to(state_idle)
		else:
			swap_to(state_move, _move_direction)


func physics_update(_delta : float) -> void:
	if proto == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		proto.flip(_move_direction.x < 0.0)
	
	proto.velocity.x = _move_direction.x * speed
	proto.velocity.y = 0.0 if proto.is_on_surface() else proto.get_gravity().y
	proto.move_and_slide()

func handle_input(event : InputEvent) -> void:
	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
