extends ProtoState

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
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
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	proto.velocity.y = -proto.jump_power
	if sprite != null:
		sprite.play(ANIM_JUMP)
	_jump_released = false
	_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func exit() -> void:
	pass

func update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null or sprite == null: return
	
	var falling : bool = proto.velocity.y >= 0.0
	
	if proto.is_on_surface():
		if falling:
			if is_equal_approx(_move_direction.x, 0.0):
				swap_to(state_idle)
			else:
				swap_to(state_move, _move_direction)

func physics_update(delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null or sprite == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		sprite.flip_h = _move_direction.x < 0.0
	
	if not is_equal_approx(_move_direction.x, 0.0):
		var speed : float = _move_direction.x * (proto.speed * proto.air_speed_multiplier)
		proto.velocity.x = clampf(proto.velocity.x + speed, -proto.speed, proto.speed)
	
	var gravity : float = proto.get_gravity().y
	if _jump_released and proto.velocity.y < 0.0:
		proto.velocity.y = 0.0
	
	if not is_equal_approx(proto.velocity.y, gravity):
		var g_actual : float = gravity
		if proto.velocity.y >= 0.0:
			g_actual = (gravity * proto.fall_multiplier)
			if sprite.animation != ANIM_FALL:
				sprite.play(ANIM_FALL)
		proto.velocity.y = min(proto.velocity.y + (g_actual * delta), g_actual)
	
	proto.move_and_slide()

func handle_input(event : InputEvent) -> void:
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	elif event.is_action_released(&"jump"):
		_jump_released = true
