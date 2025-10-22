extends Area2D
class_name LogicPlayerTrigger

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal trigger_state_changed(triggered : bool)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var trigger_on_enter : bool = true
@export var trigger_delay : float = 0.0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if trigger_on_enter:
		body_entered.connect(_on_body_triggered)
	else:
		body_exited.connect(_on_body_triggered)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_triggered() -> bool:
	return false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_triggered(_body : Node2D) -> void:
	if trigger_delay > 0.0:
		await get_tree().create_timer(trigger_delay).timeout
	trigger_state_changed.emit(true)
