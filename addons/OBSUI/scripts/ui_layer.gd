extends CanvasLayer
class_name UILayer

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal ui_revealed(ui_name : StringName)
signal ui_hidden(ui_name : StringName)
signal all_hidden()

# ------------------------------------------------------------------------------
# Contruct Class
# ------------------------------------------------------------------------------
class ActiveInfo extends RefCounted:
	var ui_name : StringName = &""
	var is_open : bool = true
	
	func _init(ui : StringName):
		ui_name = ui

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var immediate_open : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ui_children : Dictionary[StringName, UIControl] = {}

var _active : Array[ActiveInfo] = []

var _registered_actions : Dictionary[StringName, Array] = {}

var _uigroup : UIGroup = UIGroup.new()



# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	for child : Node in get_children():
		_on_child_entered_tree(child)
	register_action_handler(UIControl.ACTION_OPEN_UI, open_ui)
	register_action_handler(UIControl.ACTION_OPEN_DEFAULT_UI, open_default_ui)
	register_action_handler(UIControl.ACTION_SWAP_TO_UI, swap_to_ui)
	register_action_handler(UIControl.ACTION_POP_UI, pop_ui)
	register_action_handler(UIControl.ACTION_CLOSE_UI, close_ui)
	register_action_handler(UIControl.ACTION_CLOSE_ALL_UI, close_all_ui)
	
	if immediate_open:
		open_default_ui()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetActiveIndex(ui_name : StringName) -> int:
	for idx : int in range(_active.size()):
		if _active[idx].ui_name == ui_name:
			return idx
	return -1

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_action_handler(action : StringName, handler : Callable) -> int:
	if action.strip_edges().is_empty() or handler == null: return ERR_INVALID_PARAMETER
	if not action in _registered_actions:
		_registered_actions[action] = []
	if _registered_actions[action].find(handler) >= 0:
		return ERR_ALREADY_EXISTS
	_registered_actions[action].append(handler)
	return OK

func unregister_action_handler(action : StringName, handler : Callable) -> void:
	if not action in _registered_actions: return
	
	var idx : int = _registered_actions[action].find(handler)
	if idx < 0: return
	
	_registered_actions[action].remove_at(idx)
	if _registered_actions[action].size() <= 0:
		_registered_actions.erase(action)

func open_ui(ui_name : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	if ui_name in _ui_children:
		if _GetActiveIndex(ui_name) >= 0: return
		_ui_children[ui_name].reveal_ui(immediate, options)
		_active.append(ActiveInfo.new(ui_name))

func open_default_ui(immediate : bool = false, options : Dictionary = {}) -> void:
	var ctrl_name : StringName = _uigroup.get_default_ui()
	if ctrl_name.is_empty():
		if _ui_children.size() > 0:
			printerr("UILayer missing default UI")
		return
	open_ui(ctrl_name, immediate, options)

func close_ui(ui_name : StringName, immediate : bool = false) -> void:
	var idx : int = _GetActiveIndex(ui_name)
	if idx >= 0 and _active[idx].is_open:
		_active[idx].is_open = false
		await _ui_children[ui_name].hide_ui(immediate)

func pop_ui(immediate : bool = false) -> void:
	if _active.size() > 0:
		_active[0].is_open = false
		await _ui_children[_active[0].ui_name].hide_ui(immediate)

func swap_to_ui(ui_name : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	if not ui_name in _ui_children: return
	await pop_ui(immediate)
	open_ui(ui_name, immediate, options)

func close_all_ui(immediate : bool = false) -> void:
	for info : ActiveInfo in _active:
		info.is_open = false
		_ui_children[info.ui_name].hide_ui(immediate)

func has_ui(ui_name : StringName) -> bool:
	return ui_name in _ui_children

func get_ui_list() -> Array[StringName]:
	return _ui_children.keys()

func get_active_ui() -> Array[StringName]:
	var active : Array[StringName] = []
	for info : ActiveInfo in _active:
		if info.is_open:
			active.append(info.ui_name)
	return active

func is_ui_active(ui_name : StringName) -> bool:
	var idx : int = _GetActiveIndex(ui_name)
	if idx >= 0:
		return _active[idx].is_open
	return false

func ui_active() -> bool:
	var active_open : Array[ActiveInfo] = _active.filter(
		func(info : ActiveInfo): return info.is_open
	)
	return active_open.size() > 0

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered_tree(child : Node) -> void:
	if not child is UIControl: return
	if child.name in _ui_children:
		printerr("UI named, ", child.name, ", already registered with UI Canvas Layer, ", name)
		return
	
	_ui_children[child.name] = child
	if child.visible:
		_active.append(child.name)
	
	if not child.action_requested.is_connected(_on_action_requested):
		child.action_requested.connect(_on_action_requested)
	if not child.ui_revealed.is_connected(_on_ui_revealed.bind(child.name)):
		child.ui_revealed.connect(_on_ui_revealed.bind(child.name))
	if not child.ui_hidden.is_connected(_on_ui_hidden.bind(child.name)):
		child.ui_hidden.connect(_on_ui_hidden.bind(child.name))
	
	_uigroup.register_ui_control(child)


func _on_child_exiting_tree(child : Node) -> void:
	if not child is UIControl: return
	if child.name in _ui_children:
		_ui_children.erase(child.name)
	if child.name in _active:
		_active.erase(child.name)
	
	if child.action_requested.is_connected(_on_action_requested):
		child.action_requested.disconnect(_on_action_requested)
	if child.ui_revealed.is_connected(_on_ui_revealed.bind(child.name)):
		child.ui_revealed.disconnect(_on_ui_revealed.bind(child.name))
	if child.ui_hidden.is_connected(_on_ui_hidden.bind(child.name)):
		child.ui_hidden.disconnect(_on_ui_hidden.bind(child.name))
	
	_uigroup.remove_ui_control(child)

func _on_action_requested(action : StringName, args : Array) -> void:
	if action in _registered_actions:
		for fn : Callable in _registered_actions[action]:
			fn.callv(args)

func _on_ui_revealed(ui_name : StringName) -> void:
	ui_revealed.emit(ui_name)

func _on_ui_hidden(ui_name : StringName) -> void:
	ui_hidden.emit(ui_name)
	var idx : int = _GetActiveIndex(ui_name)
	if idx >= 0:
		_active.remove_at(idx)
	if _active.size() <= 0:
		all_hidden.emit()
