extends ProtoState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const EP_EFFECT : PackedScene = preload("uid://0nrp3rjdvhvo")

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SpawnEPEffect() -> void:
	var parent : Node = actor.get_parent()
	if not parent is Node2D: return
	
	var effect : Node2D = EP_EFFECT.instantiate()
	if effect == null: return
	
	parent.add_child(effect)
	effect.global_position = actor.global_position
	if actor.is_on_surface():
		effect.ground(actor.flip_h)
	else: effect.air(actor.flip_h)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	play_sfx(AUDIO_HURT)
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	#actor.set_tree_param(APARAM_ONCE_HURT, ONCE_FIRE)
	actor.set_tree_param(APARAM_TRANS_ACTION, TRANS_ACTION_HURT)
	actor.set_tree_param(APARAM_ONCE_INTERRUPT, ONCE_FIRE)
	actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
	
	if typeof(payload) == TYPE_BOOL and payload == true:
		_SpawnEPEffect()


func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_HURT_GROUND or anim_name == ANIM_HURT_AIR:
		pop(false, true)
