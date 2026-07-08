@tool
extends Projectile

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_POOF : StringName = &"poof"

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func die() -> void:
	if not (Engine.is_editor_hint() or _dead):
		_dead = true
		if visual_node is AnimatedSprite2D:
			visual_node.animation_finished.connect(_on_sprite_animation_finished)
			visual_node.play(ANIM_POOF)
		else:
			if visual_node != null:
				visual_node.visible = false
			_projectile_exploded()
			queue_free()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_sprite_animation_finished() -> void:
	queue_free.call_deferred()
