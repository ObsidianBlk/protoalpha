extends RefCounted
class_name UIGroup

# NOTE: This class is intended to be used internally between a UILayer node
#  and it's UIControl children.

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _uis : Dictionary[StringName, UIControl]
var _default_ui : StringName = &""

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateDefaultUI(ctrl_name : StringName) -> void:
	if _default_ui != ctrl_name:
		_default_ui = ctrl_name
		for cname : StringName in _uis.keys():
			if cname != ctrl_name:
				_uis[cname].default_ui = false

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_ui_control(ctrl : UIControl) -> int:
	if ctrl.name in _uis: return ERR_ALREADY_EXISTS
	_uis[ctrl.name] = ctrl
	if not ctrl.default.is_connected(_UpdateDefaultUI.bind(ctrl.name)):
		ctrl.default.connect(_UpdateDefaultUI.bind(ctrl.name))
	
	if ctrl.default_ui:
		if _default_ui.is_empty():
			_default_ui = ctrl.name
		else:
			ctrl.default_ui = false
	
	return OK

func remove_ui_control(ctrl : UIControl) -> void:
	if ctrl.name in _uis:
		if _uis[ctrl.name] == ctrl:
			if ctrl.default.is_connected(_UpdateDefaultUI.bind(ctrl.name)):
				ctrl.default.disconnect(_UpdateDefaultUI.bind(ctrl.name))
			
			if _default_ui == ctrl.name:
				_default_ui = &""
			
			_uis.erase(ctrl.name)
			
			if _default_ui.is_empty() and _uis.size() > 0:
				_uis[_uis.keys()[0]].default_ui = true

func get_default_ui() -> StringName:
	return _default_ui
