extends RefCounted
class_name AltTimer

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _cb : Callable = func():pass
var _time : float = 0.0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init(delay : float = 0.0, cb : Callable = func():pass) -> void:
	_cb = cb
	_time = delay

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_timeout_method(m : Callable) -> void:
	if _time <= 0.0:
		_cb = m

func update(delta : float) -> void:
	if _time > 0.0:
		_time -= delta
		_cb.call()

func get_remaining_time() -> float:
	return _time

func start(delay : float) -> void:
	if _time <= 0.0 and delay > 0.0:
		_time = delay
