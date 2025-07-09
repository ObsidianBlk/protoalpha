extends CharacterBody2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 100.0
@export var jump_power : float = 140.0
@export var air_speed_multiplier : float = 0.25
@export var fall_multiplier : float = 1.4
@export var rate_of_fire : float = 0.1


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_on_ladder : bool = false
var _can_shoot : bool = true
var _continuous_fire : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _bullet_position: Marker2D = %BulletPosition


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_on_surface() -> bool:
	return is_on_floor() or _is_on_ladder

func is_on_ladder() -> bool:
	return _is_on_ladder

func can_shoot() -> bool:
	return _can_shoot

func is_shooting() -> bool:
	return _continuous_fire

func shoot() -> void:
	if not _can_shoot: return
	var parent : Node = get_parent()
	if parent is Node2D:
		print("Pew")
		_can_shoot = false
		get_tree().create_timer(rate_of_fire).timeout.connect(_on_rof_timeout, CONNECT_ONE_SHOT)

func shooting(enable : bool) -> void:
	_continuous_fire = enable
	if _continuous_fire and _can_shoot:
		shoot()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_rof_timeout() -> void:
	_can_shoot = true
	if _continuous_fire:
		shoot.call_deferred()

func _on_ladder_detector_body_entered(body: Node2D) -> void:
	_is_on_ladder = true

func _on_ladder_detector_body_exited(body: Node2D) -> void:
	_is_on_ladder = false
