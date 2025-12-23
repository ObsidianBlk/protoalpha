extends UIControl


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The "menu" to display when a level is unavailable
@export var unavailable : StringName = &""
## The "menu" to display when a level is in active development
@export var development : StringName = &""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_center: PanelContainer = %BTN_CENTER


# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func _on_reveal() -> void:
	_btn_center.focus()
	#refocus_input(_btn_center)
	super._on_reveal()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_level_pressed(id : int) -> void:
	var lstate : Game.LevelDevState = Game.Get_Level_State(id)
	match lstate:
		Game.LevelDevState.NOT_AVAILABLE:
			if not unavailable.is_empty():
				swap_to(unavailable, false, {OPTION_PREVIOUS_UI: name})
		Game.LevelDevState.ACTIVE_DEV:
			if not development.is_empty():
				swap_to(development, false, {OPTION_PREVIOUS_UI: name, &"id":id})
		Game.LevelDevState.READY:
			request(Game.UI_ACTION_LOAD_LEVEL, [id])
