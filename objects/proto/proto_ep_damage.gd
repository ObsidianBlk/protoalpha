extends Node2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_GROUND : StringName = &"ground"
const ANIM_AIR : StringName = &"air"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _triggered : bool = false
var _anim : StringName = &""
var _flipped : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if _anim != &"":
		_Trigger(_anim, _flipped)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Trigger(anim : StringName, flipped : bool) -> void:
	if _triggered: return
	if _sprite == null:
		_anim = anim
		_flipped = flipped
	else:
		_sprite.flip_h = flipped
		_sprite.play(anim)
		_triggered = true

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func ground(flipped : bool = false) -> void:
	_Trigger(ANIM_GROUND, flipped)

func air(flipped : bool = false) -> void:
	_Trigger(ANIM_AIR, flipped)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_a_sprite_animation_finished() -> void:
	if _sprite == null: return
	if _sprite.animation in [ANIM_GROUND, ANIM_AIR]:
		queue_free.call_deferred()
