extends Node

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = false:			set=set_enabled

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	enabled = e
	set_process_input(enabled)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_process_input(enabled)

func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
