extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_climb : StringName = &""
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
		
	var wep : Weapon = proto.get_weapon()
	if not wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.connect(_on_reloaded)
	
	if wep.is_triggered():
		proto.play_animation(ANIM_SHOOT_RUN)
	else:
		proto.play_animation(ANIM_RUN)
	
	if typeof(payload) == TYPE_VECTOR2:
		_move_direction = payload

func exit() -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	var wep : Weapon = proto.get_weapon()
	if wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.disconnect(_on_reloaded)

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		proto.flip(_move_direction.x < 0.0)
	
	proto.velocity.x = _move_direction.x * proto.speed
	
	if not proto.is_on_ladder():
		proto.velocity.y = proto.get_gravity().y
	else: proto.velocity.y = 0.0
	proto.move_and_slide()
	
	if not proto.is_on_surface():
		swap_to(state_fall)
	elif proto.velocity.is_equal_approx(Vector2.ZERO):
		swap_to(state_idle)

func handle_input(event : InputEvent) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		if not is_equal_approx(_move_direction.y, 0.0) and proto.is_on_ladder():
			swap_to(state_climb)
	elif event.is_action_pressed(&"jump"):
		swap_to(state_jump)
	elif event.is_action(&"shoot"):
		var wep : Weapon = proto.get_weapon()
		if event.is_pressed():
			if wep.can_shoot():
				wep.press_trigger(proto.get_parent())
				proto.play_animation_sync(ANIM_SHOOT_RUN)
		else:
			if proto.get_current_animation() == ANIM_SHOOT_RUN:
				proto.play_animation(ANIM_RUN)
			wep.release_trigger()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_reloaded() -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto != null:
		proto.play_animation_sync(ANIM_RUN)
