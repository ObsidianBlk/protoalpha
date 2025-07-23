extends Node


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const LEVEL : String = "res://scenes/levels/demo_level/demo_level.tscn"


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _level : Level = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _game: Node2D = %Game
@onready var _ui_layer: UILayer = %UILayer

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ui_layer.register_action_handler(Game.UI_ACTION_START_GAME, _StartGame)
	_ui_layer.register_action_handler(Game.UI_ACTION_QUIT_APPLICATION, _QuitApplication)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CloseLevel() -> void:
	if _game == null or _level == null: return
	_game.remove_child(_level)
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
	_game.add_child(_level)
	_level.spawn_player(true)

func _StartGame() -> void:
	if _level != null: return
	_ui_layer.close_all_ui()
	_LoadLevel(LEVEL)

func _QuitApplication() -> void:
	get_tree().quit()
