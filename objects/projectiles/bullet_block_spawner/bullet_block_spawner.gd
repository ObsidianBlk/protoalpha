extends Node2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal spawn_completed()

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _weapon: Weapon = %Weapon

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_target(target : Node2D) -> void:
	_target = weakref(target)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished() -> void:
	var target : Node2D = _target.get_ref()
	var parent : Node = get_parent()
	if target != null and parent is Node2D:
		_weapon.rotation = global_position.angle_to(target.global_position)
		_weapon.press_trigger(parent)
		_weapon.release_trigger()
	spawn_completed.emit()
	queue_free.call_deferred()
