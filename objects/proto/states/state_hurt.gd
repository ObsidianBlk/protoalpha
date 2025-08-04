extends ProtoState



# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if proto == null:
		pop()
		return
	
	play_sfx(AUDIO_HURT)
	if not proto.animation_finished.is_connected(_on_animation_finished):
		proto.animation_finished.connect(_on_animation_finished)
	if proto.is_on_surface():
		proto.play_animation(ANIM_HURT_GROUND)
	else:
		proto.play_animation(ANIM_HURT_AIR)


func exit() -> void:
	if proto != null:
		if proto.animation_finished.is_connected(_on_animation_finished):
			proto.animation_finished.disconnect(_on_animation_finished)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_HURT_GROUND or anim_name == ANIM_HURT_AIR:
		pop()
