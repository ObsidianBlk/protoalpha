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
	var proto : CharacterBody2D = get_proto_node()
	if proto == null:
		pop()
		return
	proto.play_animation(ANIM_CLIMB)
	_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	_CheckMovement()

func exit() -> void:
	pass

func update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	
	if not proto.is_on_surface():
		if not state_fall.is_empty():
			swap_to(state_fall)

func physics_update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	
	if is_equal_approx(_move_direction.y, 0.0):
		proto.stop_animation()
	elif not proto.is_animation_playing():
		proto.play_animation()
	
	proto.velocity.y = _move_direction.y * proto.speed * 0.5
	proto.move_and_slide()

func handle_input(event : InputEvent) -> void:
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		_CheckMovement()
	elif event.is_action_pressed(&"jump"):
		if not state_jump.is_empty():
			swap_to(state_jump)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckMovement() -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return

	var climbing : bool = not is_equal_approx(_move_direction.y, 0.0)
	if not climbing and not is_equal_approx(_move_direction.x, 0.0):
		swap_to(state_move, _move_direction)
	elif climbing:
		proto.velocity.x = 0.0
