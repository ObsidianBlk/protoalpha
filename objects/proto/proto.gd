extends CharacterActor2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
#signal reloaded()

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
var _special : StringName = GameState.WEAPON_CHARGED_BOLT

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

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_weapon() -> Weapon:
	# TODO: Really, if this is supposed to exist, it should be in CharacterActor2D,
	# NOT here!
	return weapon

func get_special() -> StringName:
	return _special

func set_special(special_name : StringName) -> void:
	if weapon == null: return
	if Game.Is_Valid_Weapon(special_name):
		_special = special_name
		if _special == GameState.WEAPON_CHARGED_BOLT:
			weapon.weapon_def = Game.Get_Weapon_Resource(GameState.WEAPON_BOLT)
		else:
			weapon.weapon_def = Game.Get_Weapon_Resource(special_name)

func enable_alt_fire(enable : bool) -> bool:
	if weapon != null:
		if _special == GameState.WEAPON_CHARGED_BOLT:
			if enable:
				weapon.weapon_def = Game.Get_Weapon_Resource(GameState.WEAPON_CHARGED_BOLT)
			else:
				weapon.weapon_def = Game.Get_Weapon_Resource(GameState.WEAPON_BOLT)
			return true
	return false

func spawn_at(spawn_position : Vector2, payload : Dictionary = {}) -> void:
	super.spawn_at(spawn_position, payload)
	if has_user_signal(&"spawn"):
		emit_signal(&"spawn")

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
