extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The speed of the Fault Dash special ability in pixels per second
@export var dash_speed : int = 320
## The length of time (in seconds) the dash should be active
@export var duration : float = 1.0
@export var hitbox : HitBox = null
@export var hitbox_override : HitboxResource = null
@export var collision_ray : RayCast2D = null
@export_subgroup("States")
@export var state_idle : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _current_duration : float = 0.0

var _source_hbo : HitboxResource = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _EndDash() -> void:
	actor.set_tree_param(APARAM_SPECIAL_FAULTDASH_INACTIVE, true)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	if hitbox != null:
		_source_hbo = hitbox.overrides
		hitbox.overrides = hitbox_override
	
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	actor.set_tree_param(APARAM_SPECIAL_FAULTDASH_INACTIVE, false)
	actor.set_tree_param(APARAM_TRANS_ACTION, TRANS_ACTION_SPECIAL_FAULT_DASH)
	actor.set_tree_param(APARAM_ONCE_INTERRUPT, ONCE_FIRE)
	
	actor.velocity.x = sign(actor.velocity.x) * dash_speed
	actor.velocity.y = 0.0

func exit() -> void:
	if hitbox != null:
		hitbox.overrides = _source_hbo
		_source_hbo = null

func update(delta : float) -> void:
	if _current_duration > 0.0:
		_current_duration -= delta
		if _current_duration <= 0.0:
			_EndDash()
		else:
			if collision_ray != null and collision_ray.is_colliding():
				_EndDash()
			else:
				actor.move_and_slide()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	match anim_name:
		ANIM_FAULT_DASH_FORM:
			_current_duration = duration
		ANIM_FAULT_DASH_EXIT:
			if not state_idle.is_empty():
				swap_to.call_deferred(state_idle)
