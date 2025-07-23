extends Control
class_name UIControl

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal action_requested(action : StringName, args : Array)
signal default()
signal ui_revealed()
signal ui_hidden()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ACTION_OPEN_UI : StringName = &"open_ui"
const ACTION_OPEN_DEFAULT_UI : StringName = &"open_default_ui"
const ACTION_SWAP_TO_UI : StringName = &"swap_to_ui"
const ACTION_POP_UI : StringName = &"pop_ui"
const ACTION_CLOSE_UI : StringName = &"close_ui"
const ACTION_CLOSE_ALL_UI : StringName = &"close_all_ui"

const OPTION_PREVIOUS_UI : StringName = &"prev_ui"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var initialize_hidden : bool = true
@export var default_ui : bool = false


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _prev_ui : StringName = &""

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_default_ui(d : bool) -> void:
	if default_ui != d:
		default_ui = d
		default.emit()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if initialize_hidden:
		visible = false
		#hide_ui(true)
	else:
		reveal_ui(true)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetOptionValue(d : Dictionary, key : Variant, default : Variant = null) -> Variant:
	var dtype : int = typeof(default)
	if key in d:
		var vtype : int = typeof(d[key])
		if dtype == TYPE_NIL or vtype == dtype:
			return d[key]
	return default

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func reveal_ui(immediate : bool = false, options : Dictionary = {}) -> void:
	if not visible:
		(func():
			set_options(options)
			visible = true
			_on_reveal()
		).call_deferred()

func hide_ui(immediate : bool = false) -> void:
	if visible:
		(func():
			await _on_hide()
			visible = false
		).call_deferred()

func set_options(options : Dictionary) -> void:
	_prev_ui = _GetOptionValue(options, OPTION_PREVIOUS_UI, &"")

func _on_reveal() -> void:
	ui_revealed.emit()

func _on_hide() -> void:
	ui_hidden.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func request(action : StringName, args : Array = []) -> void:
	action_requested.emit(action, args)

func open(ui_name : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	request(ACTION_OPEN_UI, [ui_name, immediate, options])

func close(ui_name : StringName, immediate : bool = false) -> void:
	request(ACTION_CLOSE_UI, [ui_name, immediate])

func swap_to(to_ui : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	request(ACTION_CLOSE_UI, [name, immediate])
	if not immediate:
		await ui_hidden
	request(ACTION_OPEN_UI, [to_ui, immediate, options])

func swap_back(immediate : bool = false, options : Dictionary = {}) -> void:
	if _prev_ui.is_empty():
		close(name, immediate)
		if not immediate:
			await ui_hidden
	else:
		await swap_to(_prev_ui, immediate, options)

#func pop_ui(immediate : bool = false, options : Dictionary = {}) -> void:
	#if _prev_ui.is_empty():
		#close_ui(name, immediate)
		#if not immediate:
			#await ui_hidden
	#else:
		#swap_ui(_prev_ui, immediate, options)
