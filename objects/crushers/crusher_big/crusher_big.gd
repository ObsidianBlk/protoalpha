@tool
extends CrusherBlock


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const SYMBOL_REGION_SIZE : int = 32
const ANIM_SURGE : StringName = &"surge"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_enum("Eddie:0", "Standard:1", "Finger:2") var symbol : int = 0:	set=set_symbol


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_position : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _symbol: Sprite2D = %Symbol
@onready var _atree: AnimationTree = %AnimationTree

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_symbol(s : int) -> void:
	s = clampi(s, 0, 2)
	if s != symbol:
		symbol = s
		if _symbol != null:
			_symbol.region_rect.position = Vector2(symbol * SYMBOL_REGION_SIZE, 0.0)


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_last_position = global_position

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------

func trigger_effect(_dir : Direction) -> void:
	effect_triggering = true
	_atree.set("parameters/surge/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == ANIM_SURGE:
		effect_triggering = false
	animation_finished.emit(anim_name)


func _on_timer_timeout() -> void:
	_atree.set("parameters/movement/blend_position", (global_position - _last_position).normalized())
	_last_position = global_position
