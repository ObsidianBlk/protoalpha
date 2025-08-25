extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal game_open()
signal game_closed()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const LEVEL : String = "res://scenes/levels/demo_level/demo_level.tscn"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var HUD_layer : int = 1:				set=set_hud_layer
@export var UI_layer : int = 10:				set=set_ui_layer
@export var pause_menu : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _level : Level = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _hud: CanvasLayer = %HUD
@onready var _ui: UILayer = %UILayer
@onready var _container: Node2D = %Container


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_hud_layer(l : int) -> void:
	if HUD_layer != l:
		HUD_layer = l
		if _hud != null:
			_hud.layer = HUD_layer

func set_ui_layer(l : int) -> void:
	if UI_layer != l:
		UI_layer = l
		if _ui != null:
			_ui.layer = UI_layer

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	get_tree().paused = true
	_ui.close_all_ui(true)
	_ui.register_action_handler(Game.UI_ACTION_START_GAME, _StartGame)
	_ui.register_action_handler(Game.UI_ACTION_QUIT_GAME, _QuitGame)
	#_ui_layer.register_action_handler(Game.UI_ACTION_QUIT_APPLICATION, _QuitApplication)
	_ui.register_action_handler(Game.UI_ACTION_PAUSE, _PauseGame)
	_ui.register_action_handler(Game.UI_ACTION_RESUME, _ResumeGame)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CloseLevel() -> void:
	if _level == null: return
	_container.remove_child(_level)
	if _level.pause_requested.is_connected(_PauseGame):
		_level.pause_requested.disconnect(_PauseGame)
	if _level.completed.is_connected(_on_level_completed):
		_level.completed.disconnect(_on_level_completed)
	if _level.defeated.is_connected(_on_level_defeated):
		_level.defeated.disconnect(_on_level_defeated)
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
	if not _level.completed.is_connected(_on_level_completed):
		_level.completed.connect(_on_level_completed)
	if not _level.defeated.is_connected(_on_level_defeated):
		_level.defeated.connect(_on_level_defeated)
	_container.add_child(_level)
	_level.spawn_player(true)

func _StartGame() -> void:
	if _level != null: return
	_ui.close_all_ui()
	await _ui.all_hidden
	get_tree().paused = false
	Game.State.reset()
	_LoadLevel(LEVEL)
	_hud.visible = true
	Game.Game_Running = true

func _PauseGame() -> void:
	if not Game.Game_Running or get_tree().paused: return
	if _ui.has_ui(pause_menu):
		get_tree().paused = true
		_ui.open_ui(pause_menu)

func _ResumeGame() -> void:
	if not Game.Game_Running or not get_tree().paused: return
	_ui.close_all_ui()
	await _ui.all_hidden
	get_tree().paused = false

func _QuitGame(keep_ui_closed : bool = false) -> void:
	_CloseLevel()
	Game.Game_Running = false
	get_tree().paused = true
	_hud.visible = false
	if _ui.ui_active():
		_ui.close_all_ui()
		await _ui.all_hidden
	if not keep_ui_closed:
		_ui.open_default_ui()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func open_game() -> void:
	if is_open(): return
	_ui.open_default_ui()
	game_open.emit()

func close_game() -> void:
	if not is_open(): return
	await _QuitGame(true)
	game_closed.emit()

func is_open() -> bool:
	return _level != null or _ui.ui_active()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_level_completed() -> void:
	_QuitGame.call_deferred()

func _on_level_defeated() -> void:
	_QuitGame.call_deferred()
