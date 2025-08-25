extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal health_changed(health : int, max_health : int)

signal boss_health_changed(health : int, max_health : int)
signal boss_dead()
signal boss_removed()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
