extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_IDLE_BLINK : StringName = &"idle_blink"
const ANIM_FLY : StringName = &"fly"
const ANIM_SPINELESS : StringName = &"spineless"
const ANIM_ATTACK : StringName = &"attack"
const ANIM_DEATH : StringName = &"death"

enum EState {IDLE=0, FLY=1, SHOOT=2, DIVE=3, DEAD=4}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 60.0
@export var idle_time : float = 2.0
@export var weapon : Weapon = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : EState = EState.IDLE
var _state_changed : bool = false
var _has_spine : bool = true

var _fly_direction : float = 0.0

var _player : CharacterActor2D = null

var _idle_action : WeightedRandomCollection = WeightedRandomCollection.new([
	{
		WeightedRandomCollection.DICT_KEY_ID: &"none",
		WeightedRandomCollection.DICT_KEY_WEIGHT: 100.0
	},
	{
		WeightedRandomCollection.DICT_KEY_ID: &"blink",
		WeightedRandomCollection.DICT_KEY_WEIGHT: 4.0
	}
])

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	match _state:
		EState.IDLE:
			_ProcIdle(delta)
		EState.FLY:
			_ProcFly(delta)
		EState.SHOOT:
			_ProcShoot(delta)
		EState.DIVE:
			_ProcDive(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SetState(s : EState) -> void:
	if s != _state:
		_state = s
		_state_changed = true

func _ProcIdle(delta : float) -> void:
	if idle_time > 0.0:
		var action : StringName = _idle_action.get_random()
		if action == &"blink":
			_sprite.play("idle_blink")
		idle_time -= delta
		if idle_time <= 0.0:
			_SetState(EState.FLY)

func _ProcFly(delta : float) -> void:
	if _state_changed:
		_state_changed = false
		_sprite.play(ANIM_FLY if _has_spine else ANIM_SPINELESS)
	if not is_equal_approx(_fly_direction, 0.0):
		pass

func _ProcShoot(delta : float) -> void:
	if _state_changed:
		_state_changed = false
		if weapon != null:
			_sprite.play(ANIM_ATTACK)

func _ProcDive(delta : float) -> void:
	pass

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_component_health_dead() -> void:
	if _sprite == null: return
	_SetState(EState.DEAD)
	_sprite.play(ANIM_DEATH)

func _on_component_health_hit() -> void:
	pass # Replace with function body.

func _on_sprite_animation_finished() -> void:
	if _sprite == null: return
	match _sprite.animation:
		ANIM_IDLE_BLINK:
			if _state == EState.IDLE:
				_sprite.play(ANIM_IDLE)
		ANIM_ATTACK:
			if _player != null:
				weapon.look_at(_player.global_position)
				weapon.press_trigger(get_parent())
				_has_spine = false
			_SetState(EState.FLY)
		ANIM_DEATH:
			queue_free.call_deferred()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		_player = body

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
