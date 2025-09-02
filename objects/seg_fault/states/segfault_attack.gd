extends SegFaultState


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_idle : StringName = &""
@export var attack_count : int = 1
@export var attack_delay : float = 0.25

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _count : int = 0
var _delay : float = 0.0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay <= 0.0 and _count > 0:
			_count -= 1
			_Attack()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Attack() -> void:
	if actor == null: return
	var parent : Node = actor.get_parent()
	var weapon : Weapon = actor.weapon
	if weapon != null and parent is Node2D:
		var player : CharacterActor2D = actor.get_player()
		if player == null: return
		weapon.look_at(
			player.global_position - Vector2(0.0, randf_range(2, 18))
		)
		weapon.press_trigger(parent)
		if _count > 0:
			_delay = attack_delay
		else: swap_to(state_idle)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	actor.velocity = Vector2.ZERO
	if not actor.animation_finished.is_connected(_on_animation_finished):
		actor.animation_finished.connect(_on_animation_finished)
	actor.set_tree_param(APARAM_ATTACK_TYPE, ACTION_ATTACK_BULLET)
	actor.set_tree_param(APARAM_STATE, ACTION_STATE_ATTACK)

func exit() -> void:
	if actor != null:
		if actor.animation_finished.is_connected(_on_animation_finished):
			actor.animation_finished.disconnect(_on_animation_finished)
		actor.set_tree_param(APARAM_STATE, ACTION_STATE_MOVE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name : StringName) -> void:
	if anim_name == ANIM_ATTACK:
		_count = attack_count - 1
		_Attack()
		#swap_to(state_idle)
