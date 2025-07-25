extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass
	#if proto != null:
		#proto.add_user_signal(&"spawn")
		#proto.connect(&"spawn", _on_spawn)


# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if proto == null:
		pop()
		return

	if not proto.animation_finished.is_connected(_on_animation_finished):
		proto.animation_finished.connect(_on_animation_finished)
	proto.play_animation(ANIM_SPAWN)

func exit() -> void:
	if proto != null:
		if proto.animation_finished.is_connected(_on_animation_finished):
			proto.animation_finished.disconnect(_on_animation_finished)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_SPAWN:
		swap_to(state_idle)

func _on_spawn() -> void:
	swap_to(name)
