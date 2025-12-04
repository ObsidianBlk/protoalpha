extends Node
class_name FragBlockCrusher

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _DIR_UP : int = 0
const _DIR_DOWN : int = 1
const _DIR_LEFT : int = 2
const _DIR_RIGHT : int = 3

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_enum("up:0", "down:1", "left:2", "right:3") var direction : int = 0
@export var max_fall_speed : float = 128.0
@export var acceleration : float = 10.0
@export var rest_duration : float = 3.0
@export var reset_duration : float = 1.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _body : AnimatableBody2D = null
var _initial_position : Vector2 = Vector2.ZERO
var _fall_speed : float = 0.0
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_GetBody()

func _physics_process(delta: float) -> void:
	var body : AnimatableBody2D = _GetBody()
	if body == null: return
	
	var horizontal : bool = direction >= _DIR_LEFT
	_fall_speed = clampf(_fall_speed + (acceleration * delta), 0.0, max_fall_speed)
	var fs : float = _fall_speed * (1.0 if direction == _DIR_DOWN or direction == _DIR_RIGHT else -1.0)
	var vel : Vector2 = Vector2(
		0.0 if not horizontal else fs,
		0.0 if horizontal else fs
	)
	body.global_position += vel * delta
	# TODO: How to detect "floor"

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetBody() -> AnimatableBody2D:
	if _body == null:
		var parent : Node = get_parent()
		if parent is AnimatableBody2D:
			_body = parent
			_initial_position = _body.global_position
	return _body

func _ResetPosition() -> void:
	if _tween != null: return
	var body : AnimatableBody2D = _GetBody()
	if body == null: return
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(body, "global_position", _initial_position, reset_duration)
	
	await _tween.finished
	_tween = null
