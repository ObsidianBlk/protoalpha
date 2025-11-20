extends CharacterBody2D
class_name PickupBody2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
## Emitted when body has detected the floor.
signal landed()
## Emitted when body no longer detects the floor
signal falling()

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _landed : bool = false

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The amount of time (in seconds) until this pickup automatically despawns.
## [br]Pickup will never despawn with a value less than or equal to [code]0.0[/code]
@export var lifetime : float = 10.0


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if lifetime > 0.0:
		lifetime -= delta
		if lifetime <= 0.0:
			queue_free.call_deferred()
	
	if not is_on_floor():
		if _landed:
			_landed = false
			falling.emit()
		velocity = get_gravity()
		move_and_slide()
	if not _landed:
		_landed = true
		landed.emit()
