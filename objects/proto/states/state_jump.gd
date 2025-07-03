extends ProtoState

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var jump_power : float = 140.0
@export var fall_multiplier : float = 1.1

@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_move : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _move_direction : Vector2 = Vector2.ZERO
var _jump_released : bool = false

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	print("Entering Jump")
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	proto.velocity.y = -jump_power
	if sprite != null:
		sprite.play(ANIM_JUMP)
	_jump_released = false

func exit() -> void:
	pass

func update(_delta : float) -> void:
	pass

func physics_update(delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null or sprite == null: return
	
	var gravity : float = proto.get_gravity().y
	if _jump_released and proto.velocity.y < 0.0:
		proto.velocity.y = 0.0
	
	if not is_equal_approx(proto.velocity.y, gravity):
		var g_actual : float = (gravity * delta)
		if proto.velocity.y >= 0.0:
			g_actual = (gravity * delta * fall_multiplier)
			if sprite.animation != ANIM_FALL:
				sprite.play(ANIM_FALL)
		proto.velocity.y = min(proto.velocity.y + g_actual, gravity)
	
	proto.move_and_slide()
	if proto.is_on_floor():
		if is_equal_approx(_move_direction.x, 0.0):
			swap_to(state_idle)
		else:
			swap_to(state_move, _move_direction)

func handle_input(event : InputEvent) -> void:
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	elif event.is_action_released(&"jump"):
		_jump_released = true
