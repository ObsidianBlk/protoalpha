extends CharacterBody2D
class_name CharacterActor2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(animation_name : StringName)
signal dead()


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var alive : bool = true:						set=set_alive
@export var ladder_detector : LadderDetector = null:	set=set_ladder_detector


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_alive(a : bool) -> void:
	if a != alive:
		alive = a
		if not alive:
			dead.emit()

func set_ladder_detector(ld : LadderDetector) -> void:
	if ld != ladder_detector:
		_DisconnectLadderDetector()
		ladder_detector = ld
		_ConnectLadderDetector()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectLadderDetector() -> void:
	if ladder_detector == null: return
	if not ladder_detector.ladder_entered.is_connected(_on_ladder_entered):
		ladder_detector.ladder_entered.connect(_on_ladder_entered)
	if not ladder_detector.ladder_exited.is_connected(_on_ladder_exited):
		ladder_detector.ladder_exited.connect(_on_ladder_exited)

func _DisconnectLadderDetector() -> void:
	if ladder_detector == null: return
	if ladder_detector.ladder_entered.is_connected(_on_ladder_entered):
		ladder_detector.ladder_entered.disconnect(_on_ladder_entered)
	if ladder_detector.ladder_exited.is_connected(_on_ladder_exited):
		ladder_detector.ladder_exited.disconnect(_on_ladder_exited)

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func spawn_at(spawn_position : Vector2, spawn_payload : Dictionary = {}) -> void:
	global_position = spawn_position

func die() -> void:
	if alive:
		alive = false

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_on_ladder() -> bool:
	if ladder_detector != null:
		return ladder_detector.is_on_ladder()
	return false

func is_on_surface() -> bool:
	return is_on_floor() or is_on_ladder()

func is_dead() -> bool:
	return not alive

# ------------------------------------------------------------------------------
# "Virtual" Handler Methods
# ------------------------------------------------------------------------------
func _on_ladder_entered() -> void:
	pass

func _on_ladder_exited() -> void:
	pass
