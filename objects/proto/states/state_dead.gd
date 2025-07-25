extends ProtoState


# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if proto == null:
		pop()
		return
	
	if not proto.animation_finished.is_connected(_on_animation_finished):
		proto.animation_finished.connect(_on_animation_finished)
	proto.play_animation(ANIM_DEAD)


func die() -> void:
	if proto == null: return
	proto.queue_free()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_DEAD:
		die()
