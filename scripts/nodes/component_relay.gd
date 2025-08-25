extends Node
class_name ComponentRelay


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func health_changed(health : int, max_health : int, is_boss : bool = false) -> void:
	if is_boss:
		Relay.boss_health_changed.emit(health, max_health)
	else:
		Relay.health_changed.emit(health, max_health)

func boss_dead() -> void:
	Relay.boss_dead.emit()

func boss_removed() -> void:
	Relay.boss_removed.emit()
