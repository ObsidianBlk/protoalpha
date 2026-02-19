extends Node
class_name PairedTrigger


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal triggered()

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _a_triggered : bool = false
var _b_triggered : bool = false

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _check_triggered_pair() -> void:
	if _a_triggered and _b_triggered:
		triggered.emit()
		reset()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	_a_triggered = false
	_b_triggered = false

func trigger_a() -> void:
	_a_triggered = true
	_check_triggered_pair()

func trigger_b() -> void:
	_b_triggered = true
	_check_triggered_pair()
