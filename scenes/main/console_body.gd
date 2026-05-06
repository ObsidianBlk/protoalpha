@tool
extends PanelContainer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ctrl : Control = null:			set=set_ctrl
@export var height_ratio : float = .4375:	set=set_height_ratio
@export var width_ratio : float = 2.776:	set=set_width_ratio


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ctrl(c : Control) -> void:
	if ctrl != c:
		_DisconnectCTRL()
		ctrl = c
		_ConnectCTRL()
		_UpdateSize()

func set_height_ratio(hr : float) -> void:
	if hr > 0.0 and not is_equal_approx(height_ratio, hr):
		height_ratio = hr
		_UpdateSize()

func set_width_ratio(wr : float) -> void:
	if wr > 0.0 and not is_equal_approx(width_ratio, wr):
		width_ratio = wr
		_UpdateSize()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectCTRL()
	_UpdateSize()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectCTRL() -> void:
	if ctrl == null: return
	if not ctrl.resized.is_connected(_UpdateSize):
		ctrl.resized.connect(_UpdateSize)

func _DisconnectCTRL() -> void:
	if ctrl == null: return
	if ctrl.resized.is_connected(_UpdateSize):
		ctrl.resized.disconnect(_UpdateSize)

func _UpdateSize() -> void:
	if ctrl == null: return
	
	var ctrl_size : Vector2 = ctrl.get_size()
	var nheight : float = ctrl_size.y * height_ratio
	var nwidth : float = nheight * width_ratio
	
	custom_minimum_size = Vector2(nwidth, nheight)
