extends Node
class_name SliderJoyInterpreter

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var value_per_second : float = 0.5

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _parent : Slider = null
var _focused : bool = false
var _strength : float = 0.0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if _parent == null:
		_ConnectToParent()

func _enter_tree() -> void:
	_ConnectToParent()

func _exit_tree() -> void:
	_DisconnectParent()

func _process(delta: float) -> void:
	if _parent != null and _focused:
		_parent.value += value_per_second * _strength * delta

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectParent() -> void:
	if _parent == null: return
	if _parent.focus_entered.is_connected(_on_focus_entered):
		_parent.focus_entered.disconnect(_on_focus_entered)
	if _parent.focus_exited.is_connected(_on_focus_exited):
		_parent.focus_exited.disconnect(_on_focus_exited)
	if _parent.gui_input.is_connected(_on_gui_input):
		_parent.gui_input.disconnect(_on_gui_input)

func _ConnectToParent() -> void:
	var parent : Node = get_parent()
	
	if _parent != null and _parent != parent:
		_DisconnectParent()
		_parent = null
	
	if parent is Slider:
		_parent = parent
		if not _parent.focus_entered.is_connected(_on_focus_entered):
			_parent.focus_entered.connect(_on_focus_entered)
		if not _parent.focus_exited.is_connected(_on_focus_exited):
			_parent.focus_exited.connect(_on_focus_exited)
		if not _parent.gui_input.is_connected(_on_gui_input):
			_parent.gui_input.connect(_on_gui_input)

# ------------------------------------------------------------------------------
# Handlers Methods
# ------------------------------------------------------------------------------
func _on_focus_entered() -> void:
	_focused = true

func _on_focus_exited() -> void:
	_focused = false
	_strength = 0.0

func _on_gui_input(event : InputEvent) -> void:
	if not _focused: return
	if event.is_action("ui_page_up") or event.is_action("ui_page_down"):
		_strength = Input.get_axis("ui_page_up", "ui_page_down")
