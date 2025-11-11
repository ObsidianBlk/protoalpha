extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _destination : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null or typeof(payload) != TYPE_VECTOR2:
		pop()
		return

	_destination = payload
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	actor.set_tree_param(APARAM_ONCE_TELEPORT, ONCE_FIRE)


func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	match anim_name:
		ANIM_TELEPORT_OUT:
			actor.global_position = _destination
		ANIM_TELEPORT_IN:
			swap_to(state_idle)
