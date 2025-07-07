extends CharacterBody2D


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
var _is_on_ladder : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_on_surface() -> bool:
	return is_on_floor() or _is_on_ladder

func is_on_ladder() -> bool:
	return _is_on_ladder

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_ladder_detector_body_entered(body: Node2D) -> void:
	_is_on_ladder = true

func _on_ladder_detector_body_exited(body: Node2D) -> void:
	_is_on_ladder = false
