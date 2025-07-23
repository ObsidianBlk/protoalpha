extends MarginContainer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@onready var _health_progress: ProgressBar = %HealthProgress


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Relay.health_changed.connect(_on_health_changed)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_health_changed(health : int, max_health : int) -> void:
	_health_progress.value = float(health)
