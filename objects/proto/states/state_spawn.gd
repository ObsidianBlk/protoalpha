extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""
@export var state_move : StringName = &""


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _move_direction : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func set_host(host : Node) -> void:
	super.set_host(host)
	if actor != null:
		actor.add_user_signal(&"spawn")
		actor.connect(&"spawn", _on_spawn)

func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return

	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	actor.set_tree_param(APARAM_ONCE_SPAWN, ONCE_FIRE)

func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)

func handle_input(event : InputEvent) -> void:
	if actor == null: return
	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		_move_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

func update(_delta : float) -> void:
	if actor == null: return
	# Technically, the player should spawn in on the ground,
	# however, is_on_floor() will be false until the first move.
	if not actor.is_on_surface():
		actor.velocity.y = actor.get_gravity().y
		actor.move_and_slide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_SPAWN:
		if _move_direction.is_equal_approx(Vector2.ZERO):
			swap_to(state_idle)
		else:
			swap_to(state_move, _move_direction)

func _on_spawn() -> void:
	swap_to(name)
