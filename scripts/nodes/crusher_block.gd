@tool
extends CharacterBody2D
class_name CrusherBlock

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(anim_name : StringName)
## Emits when [CrusherBlock] detects a collision
signal collided()
## Emits when [CrusherBlock] detects a collision while traveling RIGHT/DOWN
signal collided_high()
## Emits when [CrusherBlock] detects a collision while traveling LEFT/UP
signal collided_low()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum Direction {LEFT=0, RIGHT=1, UP=2, DOWN=3}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The [MapSegment] this [CrusherBlock] is assigned.[br]
## [b]NOTE:[/b] If no [MapSegment] is assigned, the parent will be auto-assigned
## if the parent is a [MapSegment]
@export var segment : MapSegment = null:				set=set_segment
## The initial direction to "fall".[br]
## Upon collision detection, Left becomes Right (and vice versa), or[br]
## Up becomes Down (and vice versa).
@export var initial_direction : Direction = Direction.LEFT
## The maximum speed, in pixels per second, the crusher can move.
@export var max_speed : float = 64.0
## The acceleration, in pixels-per-second squared, the crusher will accelerate.
@export var acceleration : float = 64.0
## The amount of time (in seconds) the crusher will wait after a collision before
## moving again.
@export var rest_time : float = 1.0:					set=set_rest_time
## The amount of time (in seconds) the crusher will rest after a [method reset].[br]
## [b]NOTE:[/b] This value has effect if set to [code]0.0[/code] or if
## [property start_resting] is [code]false[/code].
@export var initial_rest_time : float = 0.0:			set=set_initial_rest_time
## If [code]true[/code] the crusher will wait the duration of either
## [property initial_rest_time] seconds, if greater than [code]0.0[/code], otherwise
## for [property rest_time] seconds before starting to move on and initial spawn or
## after a reset.
@export var start_resting : bool = false
## If [code]true[/code] crusher will continue to be active even when outside
## camera view.
@export var active_outside_camera : bool = false
@export var active : bool = true:						set=set_active


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _initial_position : Vector2 = Vector2.ZERO
var _initial_active_state : bool = true
var _direction : Direction = Direction.LEFT
var _rest : float = 0.0

var effect_triggering : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_segment(s : MapSegment) -> void:
	if s != segment:
		_DisconnectMapSegment()
		segment = s
		_ConnectMapSegment()

func set_rest_time(t : float) -> void:
	if t > 0.0:
		rest_time = t

func set_initial_rest_time(t : float) -> void:
	if t >= 0.0:
		initial_rest_time = t

func set_active(a : bool) -> void:
	active = a
	if not Engine.is_editor_hint():
		set_physics_process(active)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_initial_active_state = active
	if segment == null:
		var parent : Node = get_parent()
		if parent is MapSegment:
			segment = parent
	
	_initial_position = global_position
	_direction = initial_direction
	if start_resting:
		_rest = rest_time
	
	if not Engine.is_editor_hint():
		set_physics_process(active)
	else: set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not active_outside_camera and not _IsInCamera(): return
	
	_physics_update(delta)
	if effect_triggering: return
	
	if _rest <= 0.0:
		var dmult : float = 1.0
		if _direction == Direction.LEFT or _direction == Direction.UP:
			dmult = -1.0
		
		match _direction:
			Direction.LEFT, Direction.RIGHT:
				velocity.x = clampf(velocity.x + (acceleration * delta * dmult), -max_speed, max_speed)
			Direction.UP, Direction.DOWN:
				velocity.y = clampf(velocity.y + (acceleration * delta * dmult), -max_speed, max_speed)
		if move_and_slide():
			match _direction:
				Direction.LEFT, Direction.UP:
					collided_low.emit()
				Direction.RIGHT, Direction.DOWN:
					collided_high.emit()
			collided.emit()
			_FlipDirection()
			_rest = rest_time
	else:
		_rest -= delta
		if _rest <= 0.0:
			trigger_effect(_direction)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectMapSegment() -> void:
	if segment == null: return
	if not segment.entered.is_connected(reset):
		segment.entered.connect(reset)

func _DisconnectMapSegment() -> void:
	if segment == null: return
	if segment.entered.is_connected(reset):
		segment.entered.disconnect(reset)

func _IsInCamera() -> bool:
	if active_outside_camera: return true
	return Game.Node_In_Camera_View(self)

func _FlipDirection() -> void:
	match _direction:
		Direction.LEFT:
			_direction = Direction.RIGHT
		Direction.RIGHT:
			_direction = Direction.LEFT
		Direction.UP:
			_direction = Direction.DOWN
		Direction.DOWN:
			_direction = Direction.UP

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func _physics_update(_delta : float) -> void:
	pass

func trigger_effect(_dir : Direction) -> void:
	pass

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	if Engine.is_editor_hint(): return
	global_position = _initial_position
	_rest = 0.0
	active = _initial_active_state
	if start_resting:
		_rest = initial_rest_time if initial_rest_time > 0.0 else rest_time
	set_physics_process(active)
