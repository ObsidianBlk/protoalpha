extends Area2D
class_name LadderDetector


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal ladder_entered()
signal ladder_exited()

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ladders : Dictionary[NodePath, bool] = {}


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_on_ladder() -> bool:
	return _ladders.size() > 0

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if body == null: return
	var count : int = _ladders.size()
	var path : NodePath = body.get_path()
	if not path in _ladders:
		_ladders[path] = true
		if count == 0:
			ladder_entered.emit()

func _on_body_exited(body : Node2D) -> void:
	if body == null: return
	var path : NodePath = body.get_path()
	if path in _ladders:
		_ladders.erase(path)
		if _ladders.size() <= 0:
			ladder_exited.emit()
