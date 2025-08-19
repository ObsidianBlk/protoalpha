extends Node


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const LEVEL : String = "res://scenes/levels/demo_level/demo_level.tscn"


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var pause_menu : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _level : Level = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _game: Node2D = %Game
@onready var _ui_layer: UILayer = %UILayer
@onready var _game_hud_layer: CanvasLayer = %GameHudLayer


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	get_tree().paused = true
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()
	_ui_layer.register_action_handler(Game.UI_ACTION_START_GAME, _StartGame)
	_ui_layer.register_action_handler(Game.UI_ACTION_QUIT_GAME, _QuitGame)
	#_ui_layer.register_action_handler(Game.UI_ACTION_QUIT_APPLICATION, _QuitApplication)
	_ui_layer.register_action_handler(Game.UI_ACTION_PAUSE, _PauseGame)
	_ui_layer.register_action_handler(Game.UI_ACTION_RESUME, _ResumeGame)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CloseLevel() -> void:
	if _game == null or _level == null: return
	_game.remove_child(_level)
	if _level.pause_requested.is_connected(_PauseGame):
		_level.pause_requested.disconnect(_PauseGame)
	_level.queue_free()
	_level = null

func _LoadLevel(path_or_uid : String) -> void:
	var scene : PackedScene = load(path_or_uid)
	if scene == null:
		printerr("Failed to load level scene '", path_or_uid, "'.")
		return
	
	var lvl : Node = scene.instantiate()
	if not lvl is Level:
		printerr("Level scene, '", path_or_uid, "' is not a Level node!")
		lvl.queue_free()
		return
	
	if _level != null:
		_CloseLevel()
	
	_level = lvl
	if not _level.pause_requested.is_connected(_PauseGame):
		_level.pause_requested.connect(_PauseGame)
	_game.add_child(_level)
	_level.spawn_player(true)

func _StartGame() -> void:
	if _level != null: return
	_ui_layer.close_all_ui()
	await _ui_layer.all_hidden
	get_tree().paused = false
	_LoadLevel(LEVEL)
	_game_hud_layer.visible = true
	Game.Game_Running = true

func _PauseGame() -> void:
	if not Game.Game_Running or get_tree().paused: return
	if _ui_layer.has_ui(pause_menu):
		get_tree().paused = true
		_ui_layer.open_ui(pause_menu)

func _ResumeGame() -> void:
	if not Game.Game_Running or not get_tree().paused: return
	_ui_layer.close_all_ui()
	await _ui_layer.all_hidden
	get_tree().paused = false

func _QuitGame(keep_ui_closed : bool = false) -> void:
	_CloseLevel()
	Game.Game_Running = false
	get_tree().paused = true
	_game_hud_layer.visible = false
	_ui_layer.close_all_ui()
	await _ui_layer.all_hidden
	if not keep_ui_closed:
		_ui_layer.open_default_ui()

func _QuitApplication() -> void:
	Settings.save()
	get_tree().quit()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_tv_control_box_close_game() -> void:
	_QuitGame(true)

func _on_tv_control_box_quit_application() -> void:
	_QuitApplication()
