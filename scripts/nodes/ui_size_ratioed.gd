@tool
extends Node
class_name UISizeRatioed


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ctrl : Control = null:				set=set_ctrl
@export var ratio : Vector2 = Vector2.ONE:		set=set_ratio

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ctrl(c : Control) -> void:
	if ctrl != c:
		_DisconnectCTRL()
		ctrl = c
		_ConnectCTRL()
		_UpdateParentCustomSize()

func set_ratio(r : Vector2) -> void:
	if r.x > 0.0 and r.y > 0.0 and not ratio.is_equal_approx(r):
		ratio = r
		_UpdateParentCustomSize()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectCTRL()
	_UpdateParentCustomSize()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectCTRL() -> void:
	if ctrl == null: return
	if not ctrl.resized.is_connected(_UpdateParentCustomSize):
		ctrl.resized.connect(_UpdateParentCustomSize)

func _DisconnectCTRL() -> void:
	if ctrl == null: return
	if ctrl.resized.is_connected(_UpdateParentCustomSize):
		ctrl.resized.disconnect(_UpdateParentCustomSize)

func _UpdateParentCustomSize() -> void:
	if ctrl == null: return
	var parent : Node = get_parent()
	if parent is Control:
		parent.custom_minimum_size = ctrl.size * ratio

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
