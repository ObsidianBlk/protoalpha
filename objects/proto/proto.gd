extends CharacterActor2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal special_changed(special : GameState.Special)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const STATE_TELEPORT : StringName = &"Teleport"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 100.0
@export var jump_power : float = 140.0
@export var air_speed_multiplier : float = 0.25
@export var fall_multiplier : float = 1.4

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite
#@onready var _body: Node2D = %Body


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	#_weapon.reloaded.connect(
		#func(): reloaded.emit()
	#)
	_sprite.animation_finished.connect(
		func():
			animation_finished.emit(_sprite.animation)
	)
	print("Player Special: ", Game.State.get_special())
	set_special(Game.State.get_special())
	#special_changed.emit(Game.State.get_special())

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_weapon() -> Weapon:
	# TODO: Really, if this is supposed to exist, it should be in CharacterActor2D,
	# NOT here!
	return weapon

func get_special() -> GameState.Special:
	return Game.State.get_special()

func set_special(special : GameState.Special) -> void:
	if Game.State.set_special(special):
		if weapon != null:
			if Game.Is_Valid_Weapon(special):
				weapon.weapon_def = Game.Get_Weapon_Resource(special)
			else: weapon.weapon_def = null
		special_changed.emit(special)

func spawn_at(spawn_position : Vector2, payload : Dictionary = {}) -> void:
	super.spawn_at(spawn_position, payload)
	if has_user_signal(&"spawn"):
		emit_signal(&"spawn")

func get_size() -> Vector2:
	if _sprite != null and _sprite.sprite_frames != null:
		var tex : Texture2D = _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame)
		if tex != null:
			return tex.get_size()
	return Vector2.ZERO

func hide_sprite(h : bool) -> void:
	if _sprite != null:
		_sprite.visible = not h

func teleport_to(destination : Vector2) -> void:
	request_state.emit(STATE_TELEPORT, destination)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_ladder_entered() -> void:
	if velocity.y > 0.0:
		velocity.y = 0.0
