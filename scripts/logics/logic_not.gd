@tool
extends Logic
class_name LogicNot


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckTriggered() -> void:
	var triggered : bool = true
	if connections.size() > 0:
		for c : Node in connections:
			if c.has_method(REQ_METHOD_NAME):
				if c.is_triggered():
					triggered = false
	_triggered = triggered
