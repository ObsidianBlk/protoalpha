@tool
extends SubViewportContainer
class_name RatioSubViewportContainer


# ------------------------------------------------------------------------------
# Signal
# ------------------------------------------------------------------------------
signal game_focus_requested()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ratio : Vector2i = Vector2i(4,3):		set=set_ratio
@export var relative_screen_scale : float = 0.5:	set=set_relative_screen_scale
@export var disable_input : bool = false:			set=set_disable_input

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _screen_size : Vector2 = Vector2.ZERO

var _main_viewport : WeakRef = weakref(null)

var _mouse_entered : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ratio(r : Vector2i) -> void:
	if r.x > 0 and r.y > 0 and r != ratio:
		ratio = r
		_CalculateMinimumSize.call_deferred()

func set_relative_screen_scale(rss : float) -> void:
	rss = clampf(rss, 0.0, 1.0)
	if not is_equal_approx(rss, relative_screen_scale):
		relative_screen_scale = rss
		_CalculateMinimumSize.call_deferred()

func set_disable_input(disabled : bool) -> void:
	if disable_input != disabled:
		disable_input = disabled
		_UpdateSubViewportInput()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateSubViewportInput()

func _enter_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		if not vp.size_changed.is_connected(_on_viewport_size_changed):
			vp.size_changed.connect(_on_viewport_size_changed)
		_on_viewport_size_changed()

func _exit_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		if vp.size_changed.is_connected(_on_viewport_size_changed):
			vp.size_changed.disconnect(_on_viewport_size_changed)

func _gui_input(event: InputEvent) -> void:
	if not (_mouse_entered and disable_input): return
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			game_focus_requested.emit.call_deferred()
	elif event.is_action_pressed("shoot") and event is InputEventJoypadButton:
		game_focus_requested.emit.call_deferred()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_mouse_entered = true
		NOTIFICATION_MOUSE_EXIT:
			_mouse_entered = false

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateMinimumSize() -> void:
	var min_size : Vector2 = Vector2.ZERO
	var target_ratio : float = float(ratio.x) / float(ratio.y)
	var screen_size : Vector2 = _screen_size * relative_screen_scale
	
	var min_edge : float = min(screen_size.x, screen_size.y)
	
	#print("Actual Size: ", _screen_size, " | Target Size: ", screen_size, " | Shortest Edge: ", min_edge)
	var w : float = min_edge# * target_ratio
	var h : float = min_edge / target_ratio
	var rscale : float = min(screen_size.x / w, screen_size.y / h)
	
	min_size = Vector2(w * rscale, h * rscale)
	print("Result: ", min_size)
	custom_minimum_size = min_size

func _GetMainSubViewport() -> SubViewport:
	var vp : SubViewport = _main_viewport.get_ref()
	if vp == null:
		for child : Node in get_children():
			if child is SubViewport:
				vp = child
				_main_viewport = weakref(child)
				break
	return vp

func _UpdateSubViewportInput() -> void:
	var svp : SubViewport = _GetMainSubViewport()
	if svp != null:
		svp.gui_disable_input = disable_input


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_viewport_size_changed() -> void:
	var vrect : Rect2 = get_viewport_rect()
	_screen_size = vrect.size
	_CalculateMinimumSize.call_deferred()
