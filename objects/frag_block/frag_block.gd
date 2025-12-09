extends AnimatableBody2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(anim_name : StringName)

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_position : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Override Variables
# ------------------------------------------------------------------------------
@onready var _atree: AnimationTree = %AnimationTree

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_last_position = global_position

func _physics_process(_delta: float) -> void:
	_atree.set("parameters/movement/blend_position", (global_position - _last_position).normalized())
	_last_position = global_position

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func trigger_effect(_effect : String = "") -> void:
	if _atree == null: return
	_atree.set("parameters/effect_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name)
