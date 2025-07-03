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
	if get_proto_node() == null: pop()
	if sprite != null:
		sprite.play(ANIM_FALL)

func physics_update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null or sprite == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		sprite.flip_h = _move_direction.x < 0.0
	
	proto.velocity.x = _move_direction.x * speed
	proto.velocity.y = proto.get_gravity().y
	proto.move_and_slide()
	if proto.is_on_floor():
		if is_equal_approx(proto.velocity.x, 0.0):
			swap_to(state_idle)
		else:
			swap_to(state_move, _move_direction)

func handle_input(event : InputEvent) -> void:
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
