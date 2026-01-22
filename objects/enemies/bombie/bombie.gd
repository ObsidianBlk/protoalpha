extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _SCENE_EXPLOSION : PackedScene = preload("uid://nj2tagnipopm")
const ANIM_SPAWN : StringName = &"spawn"
const ANIM_HOVER : StringName = &"hover"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## Speed (in pixels-per-second)
@export var speed : float = 30.0
## The offset from the player's origin in which to track.
@export var offset : Vector2 = Vector2(0.0, -10.0)

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _player : WeakRef = weakref(null)
var _tracking : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite
@onready var _hitbox: HitBox = %HitBox


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var player : Node2D = _GetPlayer()
	if player == null: return
	
	var dir : Vector2 = global_position.direction_to(player.global_position + offset).normalized()
	_sprite.flip_h = dir.x < 0.0
	if _tracking:
		global_position += dir * speed * delta

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetPlayer() -> Node2D:
	var player : Node2D = _player.get_ref()
	if player == null:
		for pnode : Node in get_tree().get_nodes_in_group(Game.GROUP_PLAYER):
			if pnode is Node2D:
				player = pnode
				_player = weakref(pnode)
	return player

func _SpawnExplosion(pos : Vector2) -> bool:
	var parent : Node = get_parent()
	if not parent is Node2D: return false
	
	var expl : GPUParticles2D = _SCENE_EXPLOSION.instantiate()
	if expl != null:
		expl.finished.connect(queue_free, CONNECT_ONE_SHOT)
		parent.add_child(expl)
		expl.global_position = pos
		expl.emitting = true
		return true
	return false

func _Die() -> void:
	set_physics_process(false)
	if _hitbox != null:
		_hitbox.disable_hitbox(true)
	if _sprite != null:
		_sprite.visible = false
	if not _SpawnExplosion(global_position):
		queue_free.call_deferred()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_sprite_animation_finished() -> void:
	if _sprite == null: return
	if _sprite.animation == ANIM_SPAWN:
		_sprite.play(ANIM_HOVER)
		if _hitbox != null:
			_hitbox.disable_hitbox(false)
		_tracking = true

func _on_component_health_dead() -> void:
	_Die.call_deferred()


func _on_hitbox_damaged(_hb: HitBox) -> void:
	_Die.call_deferred()
