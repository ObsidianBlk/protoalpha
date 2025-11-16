extends Node

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = true:			set=set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _asp : AudioStreamPlayer2D = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	if enabled != e:
		enabled = e
		_Play()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not owner.is_node_ready():
		owner.ready.connect(_SetASP, CONNECT_ONE_SHOT)
	else: _SetASP()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SetASP() -> void:
	if _asp == null:
		var parent : Node = get_parent()
		if parent is AudioStreamPlayer2D:
			_asp = parent
			if not _asp.finished.is_connected(_Play):
				_asp.finished.connect(_Play)
			_Play()

func _Play() -> void:
	if _asp == null or not enabled: return
	_asp.play()
