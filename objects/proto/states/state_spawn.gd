extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


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
	actor.set_tree_param("parameters/spawn/active", true)

func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_SPAWN:
		swap_to(state_idle)

func _on_spawn() -> void:
	swap_to(name)
