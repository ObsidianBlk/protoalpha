extends CharacterActor2D


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _weapon: Weapon = %Weapon
@onready var _sprite: AnimatedSprite2D = %ASprite


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func flip(enable : bool) -> void:
	if _sprite != null:
		_sprite.flip_h = enable
	if _weapon != null:
		_weapon.scale.x = -1.0 if enable else 1.0

func is_flipped() -> bool:
	if _sprite != null:
		return _sprite.flip_h
	return false
