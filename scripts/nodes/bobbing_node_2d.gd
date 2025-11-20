@tool
extends Node2D
class_name BobbingNode2D

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var disabled : bool = true:				set=set_disabled
@export var height : float = 8.0
@export var half_time : float = 0.5:			set=set_half_time
@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var easing : Tween.EaseType = Tween.EaseType.EASE_IN_OUT

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tween : Tween = null
var _base_height : float = 0.0


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_disabled(d : bool) -> void:
	if d != disabled:
		disabled = d
		_Begin()

func set_half_time(t : float) -> void:
	if t > 0.0 and not is_equal_approx(t, half_time):
		half_time = t

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_Begin()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Begin() -> void:
	if not disabled and _tween == null:
		_base_height = position.y
		_Tween.call_deferred()

func _Tween() -> void:
	if _tween != null: return
	
	var max_height : float = _base_height - height
	var target : float = max_height if is_equal_approx(position.y, _base_height) else _base_height
	_tween = create_tween()
	_tween.set_ease(easing)
	_tween.set_trans(transition)
	_tween.tween_property(self, "position:y", target, half_time)
	await _tween.finished
	_tween = null
	if not disabled or not is_equal_approx(position.y, _base_height):
		_Tween.call_deferred()
