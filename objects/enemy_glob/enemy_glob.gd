extends CharacterBody2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_PREP : StringName = &"prep"
const ANIM_LEAP : StringName = &"leap"
const ANIM_LAND : StringName = &"land"

const GROUP_PLAYER : StringName = &"player"

const PREPS_TO_LEAP : int = 3
const BOUNCE_DELAY : float = 0.25
const LEAP_DELAY : float = 1.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 40.0
@export var jump_speed : float = 120.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _leaping : bool = false
var _preps : int = PREPS_TO_LEAP

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_sprite.animation_finished.connect(_on_animation_finished)
	_sprite.play(ANIM_IDLE)
	_Bounce.call_deferred()

func _physics_process(delta: float) -> void:
	var dir : float = -1.0 if _sprite.flip_h else 1.0
	velocity.x = (speed * dir) if _leaping else 0.0
	
	var gravity : float = get_gravity().y
	velocity.y += gravity * delta
	move_and_slide()
	if is_equal_approx(velocity.x, 0.0) and _leaping:
		_sprite.flip_h = not _sprite.flip_h
	
	if is_on_floor() and _leaping:
		_leaping = false
		_sprite.play(ANIM_LAND)
		get_tree().create_timer(LEAP_DELAY).timeout.connect(_Bounce, CONNECT_ONE_SHOT)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Bounce() -> void:
	_sprite.play(ANIM_PREP)
	_preps -= 1

func _FacePlayer() -> void:
	var nodes : Array[Node] = get_tree().get_nodes_in_group(GROUP_PLAYER)
	for n : Node in nodes:
		if n is CharacterBody2D:
			var dir : Vector2 = global_position.direction_to(n.global_position)
			_sprite.flip_h = dir.x < 0.0


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func hit(dmg : int) -> void:
	queue_free()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished() -> void:
	if _sprite == null: return
	match _sprite.animation:
		ANIM_PREP:
			_sprite.play(ANIM_IDLE)
			if _preps <= 0:
				_sprite.play(ANIM_LEAP)
				_preps = PREPS_TO_LEAP
			else:
				get_tree().create_timer(BOUNCE_DELAY).timeout.connect(_Bounce, CONNECT_ONE_SHOT)
		ANIM_LAND:
			_sprite.play(ANIM_IDLE)
			get_tree().create_timer(BOUNCE_DELAY).timeout.connect(_Bounce, CONNECT_ONE_SHOT)
		ANIM_LEAP:
			_leaping = true
			_FacePlayer()
			velocity.y -= jump_speed
