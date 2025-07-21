extends Area2D
class_name Checkpoint


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var level_spawn_point : bool = false:		set=set_level_spawn_point


# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _level_spawn : Checkpoint = null
static var _current_checkpoint : Checkpoint = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_level_spawn_point(sp : bool) -> void:
	if sp != level_spawn_point:
		level_spawn_point = sp
		if level_spawn_point:
			_level_spawn = self

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _exit_tree() -> void:
	if _level_spawn == self:
		_level_spawn = null

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Get_Spawn_Point() -> Checkpoint:
	return _level_spawn

static func Get_Current_Checkpoint() -> Checkpoint:
	return _current_checkpoint

static func Clear() -> void:
	_current_checkpoint = null

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if body == null: return
	if body.is_in_group(Game.GROUP_PLAYER):
		_current_checkpoint = self
