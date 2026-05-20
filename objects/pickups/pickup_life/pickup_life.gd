extends PickupBody2D


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_detected(_hitbox : HitBox) -> void:
	if sound_sheet != null:
		sound_sheet.play(AUDIO)
	Game.State.lives += 1
	queue_free.call_deferred()
