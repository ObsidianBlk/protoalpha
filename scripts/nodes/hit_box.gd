extends Area2D
class_name HitBox


# ------------------------------------------------------------------------------
# Signal
# ------------------------------------------------------------------------------
signal invulnerability_changed(enabled : bool)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var health : ComponentHealth = null
@export var damage : int = 0
@export var invulnerability_time : float = 1.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_invulnerable : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func hurt(amount : int) -> void:
	if health != null and not _is_invulnerable:
		health.hurt(amount)
		trigger_invulnerability(invulnerability_time)

func trigger_invulnerability(time : float) -> void:
	if _is_invulnerable or time <= 0.0: return
	_is_invulnerable = true
	invulnerability_changed.emit(_is_invulnerable)
	get_tree().create_timer(time).timeout.connect(
		(func():
			_is_invulnerable = false
			invulnerability_changed.emit(_is_invulnerable)),
		CONNECT_ONE_SHOT
	)

func is_invulnerable() -> bool:
	return _is_invulnerable

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if damage > 0 and area is HitBox:
		area.hurt(damage)
