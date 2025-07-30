extends CharacterActor2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal reloaded()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 100.0
@export var jump_power : float = 140.0
@export var air_speed_multiplier : float = 0.25
@export var fall_multiplier : float = 1.4


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite
@onready var _body: Node2D = %Body
@onready var _weapon: Weapon = %Weapon


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_weapon.reloaded.connect(
		func(): reloaded.emit()
	)
	_sprite.animation_finished.connect(
		func():
			animation_finished.emit(_sprite.animation)
	)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func flip(enable : bool) -> void:
	if _sprite != null:
		_sprite.flip_h = enable
	if _body != null:
		_body.scale.x = -1.0 if enable else 1.0

func is_flipped() -> bool:
	if _sprite != null:
		return _sprite.flip_h
	return false

func stop_animation() -> void:
	if _sprite == null: return
	_sprite.stop()

func play_animation(anim_name : StringName = &"", sync : bool = false) -> void:
	if _sprite == null: return
	if anim_name.is_empty():
		if not _sprite.animation.is_empty():
			_sprite.play()
	elif _sprite.animation != anim_name:
		if sync:
			Game.Sync_Play_Animated_Sprite(_sprite, anim_name)
		else:
			_sprite.play(anim_name)

func is_animation_playing(anim_name : StringName = &"") -> bool:
	if _sprite != null:
		if _sprite.animation == anim_name or anim_name.is_empty():
			return _sprite.is_playing()
	return false

func get_current_animation() -> StringName:
	if _sprite == null: return &""
	return _sprite.animation

func get_weapon() -> Weapon:
	return _weapon

func spawn_at(spawn_position : Vector2, payload : Dictionary = {}) -> void:
	super.spawn_at(spawn_position, payload)
	if has_user_signal(&"spawn"):
		emit_signal(&"spawn")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_ladder_entered() -> void:
	if velocity.y > 0.0:
		velocity.y = 0.0
