extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_move : StringName = &""
@export var state_climb : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _move_direction : Vector2 = Vector2.ZERO
var _jump_released : bool = false

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	var wep : Weapon = actor.get_weapon()
	if not wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.connect(_on_reloaded)
	
	actor.velocity.y = -actor.jump_power
	play_sfx(AUDIO_JUMP)
	
	_jump_released = false
	_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func exit() -> void:
	if actor == null: return
	var wep : Weapon = actor.get_weapon()
	if wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.disconnect(_on_reloaded)

func update(_delta : float) -> void:
	if actor == null: return
	
	var falling : bool = actor.velocity.y >= 0.0
	
	if actor.is_on_surface():
		if actor.is_on_ladder() and not is_equal_approx(_move_direction.y, 0.0):
			swap_to(state_climb)
		if falling:
			if is_equal_approx(_move_direction.x, 0.0):
				play_sfx(AUDIO_LAND)
				swap_to(state_idle)
			else:
				play_sfx(AUDIO_LAND)
				swap_to(state_move, _move_direction)

func physics_update(delta : float) -> void:
	if actor == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		actor.flip(_move_direction.x < 0.0)
	
	if not is_equal_approx(_move_direction.x, 0.0):
		var speed : float = _move_direction.x * (actor.speed * actor.air_speed_multiplier)
		actor.velocity.x = clampf(actor.velocity.x + speed, -actor.speed, actor.speed)
	
	var gravity : float = actor.get_gravity().y
	if _jump_released and actor.velocity.y < 0.0:
		actor.velocity.y = 0.0
	
	if not is_equal_approx(actor.velocity.y, gravity):
		var g_actual : float = gravity
		if actor.velocity.y >= 0.0:
			g_actual = (gravity * actor.fall_multiplier)
			#if actor.get_current_animation() != ANIM_FALL:
			#	actor.play_animation(ANIM_FALL)
		actor.velocity.y = min(actor.velocity.y + (g_actual * delta), g_actual)
	
	actor.move_and_slide()

func handle_input(event : InputEvent) -> void:
	if actor == null: return
	
	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	elif event.is_action_released(&"jump"):
		_jump_released = true
	elif event.is_action(&"shoot"):
		var wep : Weapon = actor.get_weapon()
		if event.is_pressed():
			actor.set_tree_param(APARAM_TRANSITION, TRANS_ATTACK)
			wep.press_trigger(actor.get_parent())
		else:
			if wep.can_shoot() and actor.is_tree_param(APARAM_TRANSITION, TRANS_ATTACK):
				actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
			wep.release_trigger()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_reloaded() -> void:
	if actor == null: return
	actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
