extends Node
class_name FragBlockCrusher

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal fallen()
signal reset()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _DIR_UP : int = 0
const _DIR_DOWN : int = 1
const _DIR_LEFT : int = 2
const _DIR_RIGHT : int = 3

const SIGNAL_ANIM_FINISHED : StringName = &"animation_finished"
const METHOD_TRIGGER_EFFECT : StringName = &"trigger_effect"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_enum("up:0", "down:1", "left:2", "right:3") var direction : int = 0
@export var max_fall_speed : float = 64.0
@export var acceleration : float = 10.0
@export var rest_duration : float = 3.0
@export var reset_duration : float = 1.0
@export var auto_fall : bool = true
@export var auto_reset : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _body : AnimatableBody2D = null
var _initial_position : Vector2 = Vector2.ZERO

var _fall_speed : float = 0.0
var _rest_duration = 0.0
var _tween : Tween = null

var _trigger : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_GetBody()

func _physics_process(delta: float) -> void:
	if _tween == null:
		if _rest_duration <= 0.0:
			if _fall_speed > 0.0 or auto_fall or _trigger:
				_trigger = false
				_ProcessFalling(delta)
		else:
			if auto_reset:
				_rest_duration -= delta
			elif _trigger:
				_rest_duration = 0.0
			
			if _rest_duration <= 0.0:
				_fall_speed = 0.0
				_ResetPosition()

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

func _GetExpectedNormal() -> Vector2:
	match direction:
		0: # UP
			return Vector2.DOWN
		1: # Down
			return Vector2.UP
		2: # Left
			return Vector2.RIGHT
		3: # Right
			return Vector2.LEFT
	return Vector2.ZERO

func _ProcessFalling(delta : float) -> void:
	var body : AnimatableBody2D = _GetBody()
	if body == null: return
	
	var horizontal : bool = direction >= _DIR_LEFT
	_fall_speed = clampf(_fall_speed + (acceleration * delta), 0.0, max_fall_speed)
	var fs : float = _fall_speed * (1.0 if direction == _DIR_DOWN or direction == _DIR_RIGHT else -1.0)
	var vel : Vector2 = Vector2(
		0.0 if not horizontal else fs,
		0.0 if horizontal else fs
	)
	var res : KinematicCollision2D = body.move_and_collide(vel)
	if res != null:
		if res.get_normal().is_equal_approx(_GetExpectedNormal()):
			var cobj : Node2D = res.get_collider()
			if cobj is PhysicsBody2D:
				if cobj.collision_layer & body.collision_mask > 0:
					_rest_duration = rest_duration
					fallen.emit()
			elif cobj is TileMapLayer:
				# We'll just assume that a TileMapLayer collision is automatically floor
				_rest_duration = reset_duration
				fallen.emit()


func _ResetPosition() -> void:
	if _tween != null: return
	var body : AnimatableBody2D = _GetBody()
	if body == null: return
	
	_tween = create_tween()
	_tween.pause()
	if _body.has_method(METHOD_TRIGGER_EFFECT) and _body.has_signal(SIGNAL_ANIM_FINISHED):
		_body.trigger_effect()
		await _body.animation_finished
	
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_parallel(false)
	_tween.tween_property(body, "global_position", _initial_position, reset_duration)
	_tween.tween_interval(rest_duration)
	_tween.play()
	
	await _tween.finished
	_tween = null
	reset.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func trigger(enabled : bool) -> void:
	if enabled:
		_trigger = true
