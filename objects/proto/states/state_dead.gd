extends ProtoState


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal explode()

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	if actor.is_on_surface():
		if not actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.connect(_on_animation_finished)
		actor.set_tree_param(APARAM_ONCE_SPAWN, ONCE_FIRE)
	else:
		actor.hide_sprite(true)
		explode.emit()
		play_sfx(AUDIO_EXPLODE)


func die() -> void:
	if actor == null: return
	actor.queue_free()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_DEAD:
		die()

func _on_explosion_finished() -> void:
	die()
