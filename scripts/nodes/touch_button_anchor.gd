@tool
extends Node
class_name TouchButtonAnchor


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var touch_ctrl : TouchScreenButton = null:				set=set_touch_ctrl
@export var override_touch_ctrl_size : bool = false:			set=set_override_touch_ctrl_size
@export var touch_ctrl_size : Vector2 = Vector2.ZERO:			set=set_touch_ctrl_size
@export var auto_update_anchors : bool = false

@export_subgroup("Anchor Points", "anchor_")
@export_range(0.0, 1.0) var anchor_left : float = 0.0:			set=set_anchor_left
@export_range(0.0, 1.0) var anchor_right : float = 1.0:			set=set_anchor_right
@export_range(0.0, 1.0) var anchor_top : float = 0.0:			set=set_anchor_top
@export_range(0.0, 1.0) var anchor_bottom : float = 1.0:		set=set_anchor_bottom

@export_subgroup("Anchor Offset", "anchor_offset")
@export var anchor_offset_horizontal : float = 0.0:				set=set_anchor_offset_horizontal
@export var anchor_offset_vertical : float = 0.0:				set=set_anchor_offset_vertical

@export_tool_button("Update Anchors") var update_anchors : Callable = _UpdateAnchors


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _viewport : Viewport = null
var _lock_transform_update : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_touch_ctrl(ctrl : TouchScreenButton) -> void:
	if ctrl != touch_ctrl:
		_DisconnectTouchCtrl()
		_viewport = null
		touch_ctrl = ctrl
		_ConnectTouchCtrl()
		if Engine.is_editor_hint() and auto_update_anchors:
			_UpdateAnchors()
		elif not Engine.is_editor_hint():
			_UpdateCtrlTransforms()

func set_override_touch_ctrl_size(o : bool) -> void:
	if override_touch_ctrl_size != o:
		override_touch_ctrl_size = o
		if not override_touch_ctrl_size:
			touch_ctrl_size = Vector2.ZERO
		notify_property_list_changed()

func set_touch_ctrl_size(tcs : Vector2) -> void:
	if not touch_ctrl_size.is_equal_approx(tcs):
		touch_ctrl_size = tcs
		_UpdateCtrlTransforms()

func set_anchor_left(v : float) -> void:
	v = clampf(v, 0.0, 1.0)
	if not is_equal_approx(anchor_left, v):
		anchor_left = v
		if anchor_left > anchor_right:
			anchor_right = anchor_left
			# Don't update transforms here, as the set_anchor_right() method
			# will handle it
		else: _UpdateCtrlTransforms()

func set_anchor_right(v : float) -> void:
	v = clampf(v, 0.0, 1.0)
	if not is_equal_approx(anchor_right, v):
		anchor_right = v
		if anchor_right < anchor_left:
			anchor_left = anchor_right
			# Don't update transforms here, as the set_anchor_left() method
			# will handle it
		else: _UpdateCtrlTransforms()

func set_anchor_top(v : float) -> void:
	v = clampf(v, 0.0, 1.0)
	if not is_equal_approx(anchor_top, v):
		anchor_top = v
		if anchor_top > anchor_bottom:
			anchor_top = anchor_bottom
			# Don't update transforms here, as the set_anchor_bottom() method
			# will handle it
		else: _UpdateCtrlTransforms()

func set_anchor_bottom(v : float) -> void:
	v = clampf(v, 0.0, 1.0)
	if not is_equal_approx(anchor_bottom, v):
		anchor_bottom = v
		if anchor_bottom < anchor_top:
			anchor_bottom = anchor_top
			# Don't update transforms here, as the set_anchor_top() method
			# will handle it
		_UpdateCtrlTransforms()

func set_anchor_offset_horizontal(h : float) -> void:
	if not is_equal_approx(anchor_offset_horizontal, h):
		anchor_offset_horizontal = h
		_UpdateCtrlTransforms()

func set_anchor_offset_vertical(v : float) -> void:
	if not is_equal_approx(anchor_offset_vertical, v):
		anchor_offset_vertical = v
		_UpdateCtrlTransforms()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if touch_ctrl == null:
		var parent : Node = get_parent()
		if parent is TouchScreenButton:
			touch_ctrl = parent
	else:
		_ConnectTouchCtrl()
		if Engine.is_editor_hint() and auto_update_anchors:
			_UpdateAnchors()
		else:
			_UpdateCtrlTransforms()

func _validate_property(property: Dictionary) -> void:
	if property.name == "touch_ctrl_size":
		property.usage = PROPERTY_USAGE_DEFAULT
		if not override_touch_ctrl_size:
			property.usage = PROPERTY_USAGE_STORAGE

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectTouchCtrl() -> void:
	if touch_ctrl == null: return
	var vp : Viewport = touch_ctrl.get_viewport()
	if vp == null: return
	_viewport = vp
	if not Engine.is_editor_hint():
		if not vp.size_changed.is_connected(_on_ctrl_viewport_size_changed):
			vp.size_changed.connect(_on_ctrl_viewport_size_changed)
	if not touch_ctrl.tree_entered.is_connected(_on_ctrl_tree_entered):
		touch_ctrl.tree_entered.connect(_on_ctrl_tree_entered)
	if not touch_ctrl.tree_exiting.is_connected(_on_ctrl_tree_exiting):
		touch_ctrl.tree_exiting.connect(_on_ctrl_tree_exiting)

func _DisconnectTouchCtrl() -> void:
	if touch_ctrl == null: return
	_DisconnectTouchCtrlViewport()
	if touch_ctrl.tree_entered.is_connected(_on_ctrl_tree_entered):
		touch_ctrl.tree_entered.disconnect(_on_ctrl_tree_entered)
	if touch_ctrl.tree_exiting.is_connected(_on_ctrl_tree_exiting):
		touch_ctrl.tree_exiting.disconnect(_on_ctrl_tree_exiting)

func _DisconnectTouchCtrlViewport() -> void:
	if _viewport == null: return
	if _viewport.size_changed.is_connected(_on_ctrl_viewport_size_changed):
		_viewport.size_changed.disconnect(_on_ctrl_viewport_size_changed)
	_viewport = null

func _GetViewportSize() -> Vector2:
	if Engine.is_editor_hint():
		return Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	elif _viewport != null:
		return _viewport.get_visible_rect().size
	return Vector2.ZERO

func _UpdateAnchors() -> void:
	if touch_ctrl == null or _viewport == null: return
	_lock_transform_update = true
	
	var vp_size : Vector2 = _GetViewportSize()
	if is_equal_approx(vp_size.x, 0.0) or is_equal_approx(vp_size.y, 0.0):
		_lock_transform_update = false
		return
	
	var t_size : Vector2 = touch_ctrl_size
	if not override_touch_ctrl_size and touch_ctrl.texture_normal != null:
		t_size = touch_ctrl.texture_normal.get_size()
	var t_pos : Vector2 = touch_ctrl.position
	
	anchor_left = (t_pos.x - (t_size.x * 0.5)) / vp_size.x
	anchor_right = (t_pos.x + (t_size.x * 0.5)) / vp_size.x
	anchor_top = (t_pos.y - (t_size.y * 0.5)) / vp_size.y
	anchor_bottom = (t_pos.y + (t_size.y * 0.5)) / vp_size.y
	
	_lock_transform_update = false

func _UpdateCtrlTransforms() -> void:
	if touch_ctrl == null or _viewport == null or _lock_transform_update: return
	
	var vp_size : Vector2 = _GetViewportSize()
	if is_equal_approx(vp_size.x, 0.0) or is_equal_approx(vp_size.y, 0.0):
		return
	
	var top_left : Vector2 = Vector2(anchor_left, anchor_top) * vp_size
	var bottom_right : Vector2 = Vector2(anchor_right, anchor_bottom) * vp_size
	var ctrl_target_size : Vector2 = bottom_right - top_left
	
	var t_size : Vector2 = touch_ctrl_size
	if not override_touch_ctrl_size and touch_ctrl.texture_normal != null:
		t_size = touch_ctrl.texture_normal.get_size()
	
	var pos : Vector2 = Vector2(anchor_offset_horizontal, anchor_offset_vertical)
	
	touch_ctrl.position = pos + top_left
	touch_ctrl.scale = ctrl_target_size / t_size

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_ctrl_tree_entered() -> void:
	_ConnectTouchCtrl()
	_UpdateCtrlTransforms()

func _on_ctrl_tree_exiting() -> void:
	_DisconnectTouchCtrlViewport()

func _on_ctrl_viewport_size_changed() -> void:
	_UpdateCtrlTransforms()
