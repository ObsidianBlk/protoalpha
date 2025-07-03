extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 100.0

@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_jump : StringName = &""
@export var state_fall : StringName = &""
@export var state_shoot : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _move_direction : Vector2 = Vector2.ZERO


# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if get_proto_node() == null:
		pop()
	if sprite != null:
		sprite.play(ANIM_RUN)
	if typeof(payload) == TYPE_VECTOR2:
		_move_direction = payload

func exit() -> void:
	pass

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null or sprite == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		sprite.flip_h = _move_direction.x < 0.0
	
	proto.velocity.x = _move_direction.x * speed
	proto.velocity.y = proto.get_gravity().y
	proto.move_and_slide()
	
	if not proto.is_on_floor():
		swap_to(state_fall)
	elif proto.velocity.is_equal_approx(Vector2.ZERO):
		swap_to(state_idle)

func handle_input(event : InputEvent) -> void:
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	elif event.is_action_pressed(&"jump"):
		swap_to(state_jump)
	elif event.is_action_pressed(&"shoot"):
		swap_to(state_shoot)
