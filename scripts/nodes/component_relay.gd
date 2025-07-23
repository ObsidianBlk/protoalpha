extends Node
class_name ComponentRelay


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func health_changed(health : int, max_health : int) -> void:
	Relay.health_changed.emit(health, max_health)
