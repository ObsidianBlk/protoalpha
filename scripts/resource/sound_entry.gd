@tool
extends Resource
class_name SoundEntry


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var stream : AudioStream = null:				set=set_stream
@export var volume_db : float = 0.0:					set=set_volume_db
@export_range(0.0, 1.0) var volume_linear : float:		set=set_volume_linear, get=get_volume_linear
@export var min_pitch : float = 1.0:					set=set_min_pitch
@export var max_pitch : float = 1.0:					set=set_max_pitch

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_stream(s : AudioStream) -> void:
	if stream != s:
		stream = s
		changed.emit()

func set_volume_db(v : float) -> void:
	if not is_equal_approx(v, volume_db):
		volume_db = v
		changed.emit()

func set_volume_linear(v : float) -> void:
	v = clampf(v, 0.0, 1.0)
	volume_db = linear_to_db(v)

func get_volume_linear() -> float:
	return db_to_linear(volume_db)

func set_min_pitch(p : float) -> void:
	if not is_equal_approx(p, min_pitch):
		min_pitch = p
		if min_pitch > max_pitch:
			max_pitch = min_pitch
		else: changed.emit()

func set_max_pitch(p : float) -> void:
	if not is_equal_approx(p, max_pitch):
		max_pitch = p
		if max_pitch < min_pitch:
			min_pitch = max_pitch
		else: changed.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_pitch() -> float:
	if not is_equal_approx(min_pitch, max_pitch):
		return min_pitch + ((max_pitch - min_pitch) * randf())
	return min_pitch
