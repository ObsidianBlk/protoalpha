@tool
extends PanelContainer


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal pressed(level_id : int)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ICON_DEFAULT : Texture2D = preload("res://assets/graphics/ui/level_select_default_icon.png")
const ANIM_PRESSED : StringName = &"pressed"

const LLUT : Dictionary[int, int] = {
	1: GameState.LEVEL_1,
	2: GameState.LEVEL_2,
	3: GameState.LEVEL_3,
	4: GameState.LEVEL_4,
	5: GameState.LEVEL_5,
	6: GameState.LEVEL_6,
	7: GameState.LEVEL_7,
	8: GameState.LEVEL_8,
}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var level_number : int = 0:			set=set_level_number
@export var verbose : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _btn_pressed : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _icon_texture: TextureRect = %IconTexture


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_level_number(n : int) -> void:
	if level_number != n:
		level_number = n
		_UpdateIconTexture()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.State.changed.connect(_UpdateIconTexture)
	_UpdateIconTexture()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateIconTexture() -> void:
	if _icon_texture == null: return
	var icon : Texture2D = ICON_DEFAULT
	if level_number in LLUT and Game.State.is_level_unlocked(LLUT[level_number]):
		var ico : Texture2D = Game.Get_Level_Icon(LLUT[level_number])
		icon = ICON_DEFAULT if ico == null else ico
	_icon_texture.texture = icon

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_at_btn_pressed() -> void:
	_btn_pressed = true

func _on_at_btn_animation_finished(anim_name: StringName) -> void:
	if anim_name == ANIM_PRESSED and _btn_pressed:
		_btn_pressed = false
		if level_number in LLUT:
			pressed.emit(LLUT[level_number])
