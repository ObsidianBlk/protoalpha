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
## If definied, the values in the [property overrides] [HitboxResource] will be used
## instead of the values defined by the [Hitbox] node.
@export var overrides : HitboxResource = null
## If [code]true[/code] this [HitBox] start disabled.
@export var disabled_on_start : bool = false
## The node name of the specific [CollisionShape2D] or [CollisionPolygon2D] child node
## to enable/disable when toggling [Hitbox] disabled state.
## [br][br]
## If no name is given, will automatically enable/disable [i]all[/i]
## [CollisionShape2D] or [CollisionPolygon2D] child nodes when toggling [HitBox]
## disabled state.
@export var collision_shape_name : StringName = &"":		set=set_collision_shape_name
## If [code]true[/code] this [HitBox] will print out debug messages to console.
@export var debug_verbose : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_invulnerable : bool = false
var _hitboxes : Dictionary[StringName, HitBox] = {}
var _mask : int = 0


func set_collision_shape_name(csn : StringName) -> void:
	if csn != collision_shape_name:
		collision_shape_name = csn
		if not is_hitbox_disabled():
			# Because this cycles through all collision shapes and enables them
			# if they match collision_shape_name
			disable_hitbox(false)
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
	var dmg : int = get_damage()
	if dmg == 0 or not hb.name in _hitboxes: return
	if dmg > 0 and not hb.is_invulnerable():
		hb.hurt(dmg)
		hitbox_damaged.emit(hb)
	elif damage < 0:
		hb.hurt(-1)
	if is_continuous():
		get_tree().create_timer(hb.get_invulnerability_time()).timeout.connect(
			_HurtIfWithin.bind(hb), CONNECT_ONE_SHOT
		)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_damage() -> int:
	return damage if overrides == null else overrides.damage

func is_continuous() -> bool:
	return continuous if overrides == null else overrides.continuous

func get_invulnerability_time() -> float:
	return invulnerability_time if overrides == null else overrides.invulnerability_time

func has_health() -> bool:
	if overrides == null or not overrides.ignore_health:
		return health != null
	return false

func hurt(amount : int) -> void:
	if has_health():
		if amount > 0 and not _is_invulnerable:
			health.hurt(amount)
			trigger_invulnerability(get_invulnerability_time())
		elif amount < 0:
			health.hurt(health.max_health * 2) # Why times 2? BECAUSE!

func heal(amount : int) -> void:
	if has_health():
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
		if child is CollisionShape2D or child is CollisionPolygon2D:
			if disable and not child.disabled:
				child.set_deferred("disabled", true)
			elif not disable:
				var valid_cs : bool = collision_shape_name.is_empty() or child.name == collision_shape_name
				if valid_cs:
					child.set_deferred("disabled", false)
				elif child.disabled == false:
					child.set_deferred("disabled", true)

func is_hitbox_disabled() -> bool:
	for child : Node in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			if not child.disabled: return false
	return true

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	var dmg : int = get_damage()
	if dmg != 0 and area is HitBox:
		_hitboxes[area.name] = area
		_HurtIfWithin(area)
		hitbox_collided.emit(area)

func _on_area_exited(area : Area2D) -> void:
	if area.name in _hitboxes:
		_hitboxes.erase(area.name)
