extends ActorState


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const EXPLOSION : PackedScene = preload("uid://nj2tagnipopm")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var explosion_rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ONE)
@export var explosion_count : int = 6
@export var explosion_interval_min : float = 0.1
@export var explosion_interval_max : float = 0.25


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _count : int = 0
var _interval : float = 0.0

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SpawnRandomExplosion() -> void:
	var parent : Node = actor.get_parent()
	if parent is Node2D:
		var hsize : Vector2 = explosion_rect.size * 0.5
		var exp : GPUParticles2D = EXPLOSION.instantiate()
		parent.add_child(exp)
		exp.position = Vector2(
			randf_range(-hsize.x, hsize.x),
			randf_range(-hsize.y, hsize.y)
		) + explosion_rect.position
		exp.emitting = true

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	actor.change_action(actor.CORE_ACTION_HURT)
	_interval = 0.0

func update(delta : float) -> void:
	if _count <= 0: return
	if _interval > 0.0:
		_interval -= delta
	else:
		_SpawnRandomExplosion()
		_count -= 1
		if _count <= 0:
			actor.queue_free.call_deferred()
		else:
			_interval = randf_range(explosion_interval_min, explosion_interval_max)
