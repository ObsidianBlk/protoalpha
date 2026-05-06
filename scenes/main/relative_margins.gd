@tool
extends MarginContainer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ctrl : Control = null:				set=set_ctrl


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ctrl(c : Control) -> void:
	if ctrl != c:
		_DisconnectCTRL()
		ctrl = c
		_ConnectCTRL()
		_UpdateMargins()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectCTRL()
	_UpdateMargins()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectCTRL() -> void:
	if ctrl == null: return
	if not ctrl.resized.is_connected(_UpdateMargins):
		ctrl.resized.connect(_UpdateMargins)

func _DisconnectCTRL() -> void:
	if ctrl == null: return
	if ctrl.resized.is_connected(_UpdateMargins):
		ctrl.resized.disconnect(_UpdateMargins)

func _UpdateMargins() -> void:
	if ctrl == null: return
	var gsize : Vector2 = Vector2.ZERO
	
	for child : Node in get_children():
		if not child is Control: continue
		var csize : Vector2 = child.get_size()
		gsize.x = max(gsize.x, csize.x)
		gsize.y = max(gsize.y, csize.y)

	var rsize : Vector2 = ctrl.get_size()
	add_theme_constant_override(
		"margin_top", floor(rsize.y + (gsize.y * 0.5))
	)
	add_theme_constant_override("margin_left", floor(gsize.x * 0.5))
	
