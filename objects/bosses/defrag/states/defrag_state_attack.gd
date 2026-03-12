extends ActorState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""
@export var min_attack_count : int = 1
@export var max_attack_count : int = 5

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	actor.change_action(actor.CORE_ACTION_CAST)

func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == actor.ANIM_CAST:
		actor.fire_map_weapon(randi_range(min_attack_count, max_attack_count))
		if not state_idle.is_empty():
			swap_to(state_idle)
