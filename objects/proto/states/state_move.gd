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
	if actor == null:
		pop()
		return
	
	# This identifies if entering this state is due to an action or
	# if it was RETURNED_TO by another state (such as the hurt state).
	var returned_to : bool = typeof(payload) == TYPE_BOOL and payload == true

	var wep : Weapon = actor.get_weapon()
	if not wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.connect(_on_reloaded)
	
	if typeof(payload) == TYPE_VECTOR2:
		_move_direction = payload
	elif returned_to:
		_move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

func exit() -> void:
	if actor == null: return
	var wep : Weapon = actor.get_weapon()
	if wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.disconnect(_on_reloaded)

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	if actor == null: return
	
	if not is_equal_approx(abs(_move_direction.x), 0.0):
		actor.flip(_move_direction.x < 0.0)
	
	actor.velocity.x = _move_direction.x * actor.speed
	
	if not actor.is_on_ladder():
		actor.velocity.y = actor.get_gravity().y
	else: actor.velocity.y = 0.0
	actor.move_and_slide()
	
	if actor.is_crushed():
		actor.die()
	elif not actor.is_on_surface():
		swap_to(state_fall)
	elif actor.velocity.is_equal_approx(Vector2.ZERO):
		swap_to(state_idle)

func handle_input(event : InputEvent) -> void:
	if actor == null: return
	
	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		if not is_equal_approx(_move_direction.y, 0.0) and actor.is_on_ladder():
			swap_to(state_climb)
	elif event.is_action_pressed(&"jump"):
		swap_to(state_jump)
	elif event.is_action(&"shoot"):
		var wep : Weapon = actor.get_weapon()
		if event.is_pressed():
			if wep.can_shoot():
				wep.press_trigger(actor.get_parent())
				actor.set_tree_param(APARAM_TRANSITION, TRANS_ATTACK)
		else:
			if wep.can_shoot() and actor.is_tree_param(APARAM_TRANSITION, TRANS_ATTACK):
				actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
			wep.release_trigger()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_reloaded() -> void:
	if actor != null:
		actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
