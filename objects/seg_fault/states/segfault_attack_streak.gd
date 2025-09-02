extends SegFaultState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var streak_speed : float = 70.0
@export var hitbox_primary : HitBox = null
@export var hitbox_streak : HitBox = null
@export var detector : Area2D = null
@export var detector_group : StringName = &""
@export var state_idle : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _direction : float = 0.0

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ActivateStreakHitbox(activate : bool) -> void:
	if hitbox_primary == null or hitbox_streak == null:
		printerr("SegFault Streak Attack missing required hitboxes!")
		return
	if activate:
		hitbox_primary.disable_hitbox(true)
		hitbox_streak.disable_hitbox(false)
	else:
		hitbox_primary.disable_hitbox(false)
		hitbox_streak.disable_hitbox(true)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null or detector == null:
		pop()
		return
	
	var player : CharacterActor2D = actor.get_player()
	if player == null:
		printerr("SegFault AttackStreak state failed to find player!")
		pop()
		return
	_direction = get_player_direction(player)
	
	actor.velocity = Vector2.ZERO
	_ActivateStreakHitbox(true)
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	if not detector.area_entered.is_connected(_on_detector_area_entered):
		detector.area_entered.connect(_on_detector_area_entered)
	actor.set_tree_param(APARAM_ATTACK_TYPE, ACTION_ATTACK_STREAK)
	actor.set_tree_param(APARAM_ATTACK_STREAK_SE, ACTION_ATTACK_STREAK_START)
	actor.set_tree_param(APARAM_ONCE_ATTACK2, ONCE_FIRE)
	actor.set_tree_param(APARAM_STATE, ACTION_STATE_ATTACK)

func exit() -> void:
	if detector != null:
		if detector.area_entered.is_connected(_on_detector_area_entered):
			detector.area_entered.disconnect(_on_detector_area_entered)
	
	if actor != null:
		_ActivateStreakHitbox(false)
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)
		actor.set_tree_param(APARAM_STATE, ACTION_STATE_MOVE)

func physics_update(delta : float) -> void:
	if actor == null: return

	actor.velocity = Vector2(streak_speed * _direction, 0.0)
	actor.move_and_slide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_detector_area_entered(area : Area2D) -> void:
	if detector_group.is_empty(): return
	if area.is_in_group(detector_group):
		actor.set_tree_param(APARAM_ATTACK_STREAK_SE, ACTION_ATTACK_STREAK_END)
		actor.set_tree_param(APARAM_ONCE_ATTACK2, ONCE_FIRE)

func _on_animation_finished(anim_name : StringName) -> void:
	match anim_name:
		ANIM_ATTACK_STREAK_START:
			pass
		ANIM_ATTACK_STREAK_END:
			swap_to(state_idle)
