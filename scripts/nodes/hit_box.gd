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
@export var continuous : bool = false
@export var invulnerability_time : float = 1.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_invulnerable : bool = false
var _hitboxes : Dictionary[StringName, HitBox] = {}
var _mask : int = 0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_mask = collision_mask
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _HurtIfWithin(hb : HitBox) -> void:
	if damage <= 0 or not hb.name in _hitboxes: return
	hb.hurt(damage)
	if continuous:
		get_tree().create_timer(hb.invulnerability_time).timeout.connect(
				_HurtIfWithin.bind(hb), CONNECT_ONE_SHOT
			)

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

func disable_mask(disable : bool = true) -> void:
	if not is_node_ready(): return
	collision_mask = 0 if disable else _mask

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if damage > 0 and area is HitBox:
		_hitboxes[area.name] = area
		_HurtIfWithin(area)

func _on_area_exited(area : Area2D) -> void:
	if area.name in _hitboxes:
		_hitboxes.erase(area.name)
