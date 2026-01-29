extends Area2D
class_name HitBox


# ------------------------------------------------------------------------------
# Signal
# ------------------------------------------------------------------------------
## Emitted when this [HitBox] collides with another.
signal hitbox_collided(hitbox : HitBox)
## Emitted when this [HitBox] damages another
signal hitbox_damaged(hitbox : HitBox)
## Emitted when the state of this [HitBox] vulnerability changes.
signal invulnerability_changed(enabled : bool)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## [ComponentHealth] node. 
@export var health : ComponentHealth = null
## The amount of damage dealt to detected colliding [HitBox][br][br]
## A value of [code]-1[/code] will trigger an instant death to the colliding
## [HitBox] object (if that [HitBox] object has an assigned [ComponentHealth]
## object.
@export var damage : int = 0
## If [code]true[/code] damage will be dealt every [property invulnerability_time] seconds.
@export var continuous : bool = false
## The amount of time (in seconds) this [HitBox] will not take damage after being hit.
@export var invulnerability_time : float = 1.0
## If [code]true[/code] this [HitBox] start disabled.
@export var disabled_on_start : bool = false
## If [code]true[/code] this [HitBox] will print out debug messages to console.
@export var debug_verbose : bool = false

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
	if disabled_on_start:
		disable_hitbox(true)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DebugPrint(msg : String) -> void:
	if not debug_verbose: return
	print(msg)

func _HurtIfWithin(hb : HitBox) -> void:
	if damage == 0 or not hb.name in _hitboxes: return
	if damage > 0 and not hb.is_invulnerable():
		hb.hurt(damage)
		hitbox_damaged.emit(hb)
	elif damage < 0:
		hb.hurt(-1)
	if continuous:
		get_tree().create_timer(hb.invulnerability_time).timeout.connect(
				_HurtIfWithin.bind(hb), CONNECT_ONE_SHOT
			)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func hurt(amount : int) -> void:
	if health != null:
		if amount > 0 and not _is_invulnerable:
			health.hurt(amount)
			trigger_invulnerability(invulnerability_time)
		elif amount < 0:
			health.hurt(health.max_health * 2) # Why times 2? BECAUSE!

func heal(amount : int) -> void:
	if health != null:
		health.heal(amount)

func kill(ignore_invulnerability : bool = false) -> void:
	# This should be a simple insta-kill
	var can_kill : bool = not _is_invulnerable or ignore_invulnerability
	if health.health > 0 and can_kill:
		health.hurt(health.health)

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

func disable_hitbox(disable : bool = true) -> void:
	for child : Node in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", disable)
			#child.disabled = disable
		if child is CollisionPolygon2D:
			child.set_deferred("disabled", disable)
			#child.disabled = disable

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if damage != 0 and area is HitBox:
		_hitboxes[area.name] = area
		_HurtIfWithin(area)
		hitbox_collided.emit(area)

func _on_area_exited(area : Area2D) -> void:
	if area.name in _hitboxes:
		_hitboxes.erase(area.name)
