extends Control

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal focus_tv()
signal focus_game()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_DEFAULT : StringName = &"default"
const ANIM_PRESSED : StringName = &"pressed"

const JOY_MOUSE_SENSITIVITY : Vector2 = Vector2.ONE * 400.0
const JOY_DEAD_ZONE : float = 0.5

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mouse_left_stick : bool = true
var _mouse_warping : bool = false
var _joypad_device : int = -1

var _ignore_hover : bool = false



# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _pointer_sprite: AnimatedTextureRect = %PointerSprite

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_pointer_sprite.visible = false

func _enter_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		if not vp.gui_focus_changed.is_connected(_on_viewport_gui_focus_changed):
			vp.gui_focus_changed.connect(_on_viewport_gui_focus_changed)

func _exit_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		if vp.gui_focus_changed.is_connected(_on_viewport_gui_focus_changed):
			vp.gui_focus_changed.disconnect(_on_viewport_gui_focus_changed)

func _process(delta: float) -> void:
	if _pointer_sprite == null or not _pointer_sprite.visible: return
	_pointer_sprite.position = _HandleMousePosition(delta)
	_HoverFocusSnap()

func _input(event: InputEvent) -> void:
	if _pointer_sprite == null: return
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if _EventIsThumbStick(event):
			_mouse_left_stick = _EventIsLeftStick(event)
		#_mouse_motion_detected = false
		_joypad_device = event.device
	elif event is InputEventMouseButton:
		_joypad_device = -1
	elif event is InputEventMouseMotion:
		if not _mouse_warping:
			_joypad_device = -1
		else: _mouse_warping = false
	
	if event.is_action_pressed("focus_toggle"):
		_pointer_sprite.visible = not _pointer_sprite.visible
		if _pointer_sprite.visible:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			focus_tv.emit()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_ReleaseViewportControl()
			focus_game.emit()
	else:
		if not _pointer_sprite.visible:
			if event is InputEventMouseMotion or event is InputEventMouseButton:
				get_viewport().set_input_as_handled()
		elif _IsPointerPressed(event):
			if _pointer_sprite.animation == ANIM_DEFAULT:
				_pointer_sprite.play(ANIM_PRESSED)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsPointerPressed(event : InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_A:
			var e : InputEventMouseButton = InputEventMouseButton.new()
			e.button_index = MOUSE_BUTTON_LEFT
			e.pressed = true
			Input.parse_input_event(e)
			return true
	return false

func _EventIsThumbStick(event : InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		return event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y]
	return false

func _EventIsLeftStick(event : InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		return event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]
	return false

func _Threshold(v : float, edge : float) -> float:
	if abs(v) >= edge: return v
	return 0.0

func _HandleMousePosition(delta : float) -> Vector2:
	var pos : Vector2 = get_global_mouse_position()
	if _joypad_device < 0: return pos
	var stick : Vector2 = Vector2.ZERO
	if _mouse_left_stick:
		stick = Vector2(
			_Threshold(Input.get_joy_axis(_joypad_device, JOY_AXIS_LEFT_X), JOY_DEAD_ZONE),
			_Threshold(Input.get_joy_axis(_joypad_device, JOY_AXIS_LEFT_Y), JOY_DEAD_ZONE)
		)
	else:
		stick = Vector2(
			_Threshold(Input.get_joy_axis(_joypad_device, JOY_AXIS_RIGHT_X), JOY_DEAD_ZONE),
			_Threshold(Input.get_joy_axis(_joypad_device, JOY_AXIS_RIGHT_Y), JOY_DEAD_ZONE)
		)
	pos += (stick * JOY_MOUSE_SENSITIVITY * delta)
	_mouse_warping = true
	Input.warp_mouse(pos)
	return pos

func _HoverFocusSnap() -> void:
	if _joypad_device < 0: return
	if _ignore_hover:
		_ignore_hover = false
		return
	
	var vp : Viewport = get_viewport()
	if vp == null: return
	var ctrl : Control = vp.gui_get_hovered_control()
	var fowner : Control = vp.gui_get_focus_owner()
	if ctrl != null and ctrl != fowner:
		#print(
			#"Hover Focus: ",
			#"Null" if ctrl == null else ctrl.name,
			#" | Owner: ",
			#"Null" if fowner == null else fowner.name
		#)
		ctrl.grab_focus()

func _ReleaseViewportControl() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		vp.gui_release_focus()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_pointer_sprite_animation_finished(anim_name: StringName) -> void:
	if _pointer_sprite == null: return
	if anim_name == ANIM_PRESSED:
		_pointer_sprite.play(ANIM_DEFAULT)

func _on_viewport_gui_focus_changed(ctrl : Control) -> void:
	if _joypad_device < 0: return
	var csize : Vector2 = ctrl.get_size()
	_ignore_hover = true
	_mouse_warping = true
	Input.warp_mouse(ctrl.global_position + (csize * 0.5))
