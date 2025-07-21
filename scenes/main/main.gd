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

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_LoadLevel(LEVEL)

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
