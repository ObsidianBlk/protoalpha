extends Area2D
class_name Interactor2D

# TODO: Finish me off!

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _interactables : Array[Node] = []

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsInteractable(o : Node2D) -> bool:
	for sig_name : StringName in [Interactable.USIG_INTERACTED, Interactable.USIG_FOCUS_ENTERED, Interactable.USIG_FOCUS_EXITED]:
		if not o.has_user_signal(sig_name):
			return false
	return true

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if _IsInteractable(body):
		pass

func _on_body_exited(body : Node2D) -> void:
	pass

func _on_area_entered(area : Area2D) -> void:
	if _IsInteractable(area):
		pass

func _on_area_exited(area : Area2D) -> void:
	pass
