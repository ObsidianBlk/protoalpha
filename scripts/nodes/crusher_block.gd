@tool
extends CharacterBody2D
class_name CrusherBlock

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(anim_name : StringName)
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
## The initial direction to "fall".[br]
## Upon collision detection, Left becomes Right (and vice versa), or[br]
## Up becomes Down (and vice versa).
@export var initial_direction : Direction = Direction.LEFT
## The maximum speed, in pixels per second, the crusher can move.
@export var max_speed : float = 64.0
## The acceleration, in pixels-per-second squared, the crusher will accelerate.
@export var acceleration : float = 10.0
## The amount of time (in seconds) the crusher will wait after a collision before
## moving again.
@export var rest_time : float = 1.0
## If [code]true[/code] the crusher will wait the [property rest_time] seconds
## before starting to move on and initial spawn or after a reset.
@export var start_resting : bool = false
## If [code]true[/code] crusher will continue to be active even when outside
## camera view.
@export var active_outside_camera : bool = false
@export var active : bool = true

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsInCamera() -> bool:
	if active_outside_camera: return true
	return Game.Node_In_Camera_View(self)

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func trigger_effect() -> void:
	pass
