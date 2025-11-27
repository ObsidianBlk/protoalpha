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

const JOY_MOUSE_SENSITIVITY : Vector2 = Vector2.ONE * 200.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mouse_left_stick : bool = true
var _joypad_device : int = -1
var _mouse_motion_detected : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _pointer_sprite: AnimatedTextureRect = %PointerSprite

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_pointer_sprite.visible = false

func _process(delta: float) -> void:
	if _pointer_sprite == null or not _pointer_sprite.visible: return
	var mouse_pos : Vector2 = get_global_mouse_position()
	if _joypad_device >= 0:
		var stick : Vector2 = _HandleJoypadMouse()
		print("Stick: ", stick * JOY_MOUSE_SENSITIVITY * delta)
		if not is_equal_approx(stick.length_squared(), 0.0):
			mouse_pos += stick * JOY_MOUSE_SENSITIVITY * delta
			Input.warp_mouse(mouse_pos)
	_pointer_sprite.position = mouse_pos

func _input(event: InputEvent) -> void:
	if _pointer_sprite == null: return
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_mouse_motion_detected = false
		_joypad_device = event.device
	elif event is InputEventMouseButton:
		_joypad_device = -1
	elif event is InputEventMouseMotion:
		if _mouse_motion_detected:
			_joypad_device = -1
		_mouse_motion_detected = true
	
	if event.is_action_pressed("focus_toggle"):
		_pointer_sprite.visible = not _pointer_sprite.visible
		if _pointer_sprite.visible:
			focus_tv.emit()
		else: focus_game.emit()
	else:
		if _IsPointerPressed(event):
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

func _HandleJoypadMouse() -> Vector2:
	if _joypad_device < 0: return Vector2.ZERO
	if _mouse_left_stick:
		return Vector2(
			Input.get_joy_axis(_joypad_device, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(_joypad_device, JOY_AXIS_LEFT_Y)
		)
	return Vector2(
			Input.get_joy_axis(_joypad_device, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(_joypad_device, JOY_AXIS_RIGHT_Y)
		)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_pointer_sprite_animation_finished(anim_name: StringName) -> void:
	if _pointer_sprite == null: return
	if anim_name == ANIM_PRESSED:
		_pointer_sprite.play(ANIM_DEFAULT)
