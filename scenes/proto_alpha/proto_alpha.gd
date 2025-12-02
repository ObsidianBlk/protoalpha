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
@export var HUD_layer : int = 1:					set=set_hud_layer
@export var UI_layer : int = 10:					set=set_ui_layer
@export var pause_menu : StringName = &""
@export var level_select_menu : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _level : Level = null
var _game_running : bool = false

var _input_record : Array[String] = []
var _input_timestamp : float = 0.0

var _input_blocked : bool = false

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
	_ui.register_action_handler(Game.UI_ACTION_LOAD_LEVEL, _LoadLevelFromID)
	_ui.register_action_handler(Game.UI_ACTION_QUIT_LEVEL, _QuitLevel)
	_ui.register_action_handler(Game.UI_ACTION_QUIT_GAME, _QuitGame)
	_ui.register_action_handler(Game.UI_ACTION_PAUSE, _PauseGame)
	_ui.register_action_handler(Game.UI_ACTION_RESUME, _ResumeGame)

func _input(event: InputEvent) -> void:
	if _input_blocked:
		get_viewport().set_input_as_handled()
		return
	
	if _level != null:
		if event.is_action_pressed("start"):
			if _ui.is_ui_active(level_select_menu):
				_ui.swap_to_ui(pause_menu)
			elif _ui.is_ui_active(pause_menu):
				_ResumeGame()
			elif not _CheckCheatCode(event):
				_PauseGame()
		else:
			_CheckCheatCode(event)
	else:
		if event.is_action_pressed("start"):
			if _ui.is_ui_active(level_select_menu):
				await _ui.pop_ui()
				_game_running = false
				_ui.open_default_ui()
	
	#if event.is_action_pressed("start"):
		#if _level != null:
			#if _ui.is_ui_active(level_select_menu):
				#_ui.swap_to_ui(pause_menu)
			#elif _ui.is_ui_active(pause_menu):
				#_ResumeGame()
			#else:
				#_PauseGame()
		#else:
			#if _ui.is_ui_active(level_select_menu):
				#await _ui.pop_ui()
				#_game_running = false
				#_ui.open_default_ui()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetPressedActionName(event : InputEvent, actions : Array[String]) -> String:
	for action : String in actions:
		if event.is_action_pressed(action):
			return action
	return ""

func _InputRecordCode() -> StringName:
	var cheat_str : String = ""
	for action : String in _input_record:
		if action.is_empty(): continue
		if cheat_str.is_empty():
			cheat_str = action
		else:
			cheat_str = "%s_%s"%[cheat_str, action]
	return cheat_str

func _CheckCheatCode(event : InputEvent) -> bool:
	var action : String = _GetPressedActionName(
		event,
		["move_up", "move_down", "move_left", "move_right", "jump", "shoot", "select", "start"]
	)
	if not action.is_empty():
		var timestamp = Time.get_ticks_msec()
		if _input_record.size() > 0:
			var diff : float = timestamp - _input_timestamp
			if diff >= 300.0:
				_input_record.clear()
		_input_record.append(action)
		_input_timestamp = timestamp
		
		var cheat_code : StringName = _InputRecordCode()
		return Game.State.activate_cheat(cheat_code)
	return false

func _CloseLevel() -> void:
	if _level == null: return
	_level.despawn()
	_container.remove_child(_level)
	if _level.pause_requested.is_connected(_PauseGame):
		_level.pause_requested.disconnect(_PauseGame)
	if _level.completed.is_connected(_on_level_completed):
		_level.completed.disconnect(_on_level_completed)
	if _level.defeated.is_connected(_on_level_defeated):
		_level.defeated.disconnect(_on_level_defeated)
	_level.queue_free()
	_level = null

func _LoadLevel(path_or_uid : String) -> int:
	if path_or_uid.is_empty():
		printerr("Given level path or resource ID is empty")
		return ERR_FILE_BAD_PATH
	
	var scene : PackedScene = load(path_or_uid)
	if scene == null:
		printerr("Failed to load level scene '", path_or_uid, "'.")
		return ERR_FILE_UNRECOGNIZED
	
	var lvl : Node = scene.instantiate()
	if not lvl is Level:
		printerr("Level scene, '", path_or_uid, "' is not a Level node!")
		lvl.queue_free()
		return ERR_CANT_RESOLVE
	
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
	return OK

func _LoadLevelFromID(level_id : int) -> void:
	_ui.close_all_ui()
	await _ui.all_hidden
	get_tree().paused = false
	
	if _LoadLevel(Game.Get_Level_Path(level_id)) == OK:
		_hud.visible = true
	else:
		(func():
			get_tree().paused = true
			_ui.open_ui(level_select_menu)
		).call_deferred()

func _StartGame() -> void:
	if level_select_menu.is_empty() or pause_menu.is_empty():
		printerr("Missing names for Pause and/or Level Select menus.")
		return
	if _game_running: return
	
	Game.State.reset()
	_game_running = true
	_ui.swap_to_ui(level_select_menu)

func _QuitLevel() -> void:
	if not (_level != null and _game_running): return
	_CloseLevel()
	get_tree().paused = true
	_hud.visible = false
	_ui.swap_to_ui(level_select_menu)


#func _StartGame() -> void:
	#if _level != null: return
	#_ui.close_all_ui()
	#await _ui.all_hidden
	#get_tree().paused = false
	#Game.State.reset()
	#_LoadLevel(LEVEL)
	#_hud.visible = true
	#Game.Game_Running = true

func _PauseGame() -> void:
	if not _game_running or get_tree().paused: return
	if _ui.ui_active(): return
	
	if _ui.has_ui(pause_menu):
		get_tree().paused = true
		_ui.open_ui(pause_menu)

func _ResumeGame() -> void:
	if not _game_running or not get_tree().paused: return
	if _level == null: return
	
	_ui.close_all_ui()
	await _ui.all_hidden
	get_tree().paused = false

func _QuitGame(keep_ui_closed : bool = false) -> void:
	_CloseLevel()
	_game_running = false
	get_tree().paused = true
	_hud.visible = false
	if _ui.ui_active():
		_ui.close_all_ui()
		var asp : AudioPlayerPolyphonic = AudioBoard.get_music_player(&"Game")
		if asp != null:
			asp.stop_all()
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

func enable_input(enable : bool) -> void:
	_input_blocked = not enable
	if enable:
		_ui.refocus_ui()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_level_completed() -> void:
	_QuitGame.call_deferred()

func _on_level_defeated() -> void:
	_QuitGame.call_deferred()
