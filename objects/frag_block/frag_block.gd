extends AnimatableBody2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(anim_name : StringName)


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const SYMBOL_REGION_SIZE : int = 32
enum BlockSym {EDDIE=0, TYPE1=1, MIDDLE_FINGER=2}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var symbol : BlockSym = BlockSym.TYPE1:			set=set_symbol

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_position : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Override Variables
# ------------------------------------------------------------------------------
@onready var _atree: AnimationTree = %AnimationTree
@onready var _symbol: Sprite2D = %Symbol

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_symbol(s : BlockSym) -> void:
	if s != symbol:
		symbol = s
		_UpdateSymbol()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_last_position = global_position
	_UpdateSymbol()

func _physics_process(_delta: float) -> void:
	_atree.set("parameters/movement/blend_position", (global_position - _last_position).normalized())
	_last_position = global_position

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateSymbol() -> void:
	if _symbol == null: return
	_symbol.region_rect.position.x = SYMBOL_REGION_SIZE * symbol

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
