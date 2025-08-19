@tool
extends Resource
class_name SMPTEChannel

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_multiline var message : String = "":					set=set_message
@export_range(0.0, 1.0) var static_intensity : float = 0.0:		set=set_static_intensity
@export_range(0.0, 1.0) var static_bleed : float = 0.0:			set=set_static_bleed

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_message(msg : String) -> void:
	if msg != message:
		message = msg
		changed.emit()

func set_static_intensity(i : float) -> void:
	i = clampf(i, 0.0, 1.0)
	if not is_equal_approx(i, static_intensity):
		static_intensity = i
		changed.emit()

func set_static_bleed(b : float) -> void:
	b = clampf(b, 0.0, 1.0)
	if not is_equal_approx(b, static_bleed):
		static_bleed = b
		changed.emit()
