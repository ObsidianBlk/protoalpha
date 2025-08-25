@tool
extends Area2D
class_name Pickup

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func picked_up() -> void:
	# Do something for having been picked up.
	pass

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	picked_up()
	queue_free.call_deferred()
