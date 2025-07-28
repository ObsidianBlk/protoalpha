extends Camera2D
class_name ChaseCamera


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var pixels_per_second : float = 320.0
@export var target : Node2D = null:					set=set_target

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target_position : Vector2 = Vector2.ZERO
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _instance : ChaseCamera = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_target(t : Node2D) -> void:
	if t != target:
		target = t
		if target == null:
			_target_position = get_screen_center_position()
			if not global_position.is_equal_approx(_target_position):
				global_position = _target_position
			if _tween != null:
				_tween.kill()
				_tween = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	if _instance == null:
		_instance = self

func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _physics_process(delta: float) -> void:
	if target == null: return
	if not target.global_position.is_equal_approx(_target_position):
		_target_position = target.global_position
		_TweenToTarget()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _TweenToTarget() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	
	var dist : float = global_position.distance_to(_target_position)
	var duration : float = dist / pixels_per_second
	_tween = create_tween()
	_tween.tween_property(self, "global_position", _target_position, duration)
	_tween.finished.connect(_on_tween_finished, CONNECT_ONE_SHOT)

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Get_Camera() -> ChaseCamera:
	return _instance

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_target_position(pos : Vector2) -> void:
	if target == null:
		_target_position = pos
		_TweenToTarget()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_tween_finished() -> void:
	_tween = null
