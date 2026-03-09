extends ActorState


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const EXPLOSION : PackedScene = preload("uid://nj2tagnipopm")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var explosion_rect : Rect2 = Rect2(Vector2.ZERO, Vector2.ONE)
@export var explosion_count : int = 8
@export var explosion_interval_min : float = 0.15
@export var explosion_interval_max : float = 0.4


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
		var expl : GPUParticles2D = EXPLOSION.instantiate()
		parent.add_child(expl)
		expl.global_position = Vector2(
			randf_range(-hsize.x, hsize.x),
			randf_range(-hsize.y, hsize.y)
		) + explosion_rect.position + actor.global_position
		expl.emitting = true
		play_sfx(actor.AUDIO_EXPLOSION)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(_payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	actor.change_action(actor.CORE_ACTION_HURT)
	play_sfx(actor.AUDIO_HURT)
	_interval = 0.0
	_count = explosion_count

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
			if _count < (explosion_count / 2):
				actor.visible = false
			_interval = randf_range(explosion_interval_min, explosion_interval_max)
