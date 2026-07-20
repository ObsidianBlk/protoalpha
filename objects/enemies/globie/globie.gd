extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_CHARGE_LOW : StringName = &"charge_low"
const ANIM_CHARGE_HIGH : StringName = &"charge_high"

const MIN_IDLE_TIME : float = 0.25
const MAX_IDLE_TIME : float = 1.0
const MAX_SHAKE_RADIUS : float = 1.0
const MAX_CHARGE : float = 100.0
const MAX_LOW_CHARGE : float = 50.0
const MIN_HOLDABLE_CHARGE : float = 8.0
const MIN_CHARGE_TIME : float = 6.0
const MAX_CHARGE_TIME : float = 8.0
const MIN_DISCHARGE_TIME : float = 1.0
const MAX_DISCHARGE_TIME : float = 1.5

const PLAYER_POSITION_OFFSET : Vector2 = Vector2(0.0, -12.0)

enum GlobieState {IDLE=0, CHARGING=1, DISCHARGING=2, HIT=3}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : GlobieState = GlobieState.IDLE
var _charge : float = 0.0
var _tween : Tween = null

var _player_hitbox : HitBox = null


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite
@onready var _weapon: Weapon = %Weapon


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_IdleState()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _KillTween() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null

func _IdleState() -> void:
	_state = GlobieState.IDLE
	_KillTween()
	
	_charge = 0.0
	_sprite.play(ANIM_IDLE)
	_tween = create_tween()
	_tween.tween_interval(randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME))
	_tween.set_parallel(false)
	_tween.tween_callback(_ChargeState)

func _ChargeState() -> void:
	if _state == GlobieState.CHARGING: return
	_state = GlobieState.CHARGING
	_KillTween()
	
	var travel : float = 1.0 - (_charge / MAX_CHARGE)
	if travel > 0.0:
		var duration : float = randf_range(MIN_CHARGE_TIME, MAX_CHARGE_TIME) * travel
		_tween = create_tween()
		_tween.tween_method(_on_charge_interval, _charge, MAX_CHARGE, duration)
		_tween.set_parallel(false)
		_tween.tween_callback(_DischargeState)

func _HitState(shakes : int, duration : float) -> void:
	if _state == GlobieState.HIT: return
	_state = GlobieState.HIT
	_KillTween()
	
	if _weapon.is_triggered():
		_weapon.release_trigger()
	
	_sprite.play(ANIM_CHARGE_LOW)
	if shakes > 0 and duration > 0.0:
		var interval : float = duration / float(shakes)
		_tween = create_tween()
		_tween.finished.connect(_on_state_finished)
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.set_trans(Tween.TRANS_ELASTIC)
		for i : int in range(shakes):
			var pos : Vector2 = Vector2.ZERO
			if i < (shakes - 1):
				var r : float = randf_range(0, MAX_SHAKE_RADIUS)
				pos = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * r
			_tween.tween_property(_sprite, "position", pos, interval)
	else: _on_state_finished()

func _DischargeState() -> void:
	if _state == GlobieState.DISCHARGING: return
	_state = GlobieState.DISCHARGING
	_KillTween()
	
	_sprite.speed_scale = 1.0
	_sprite.play(ANIM_CHARGE_LOW)
	
	var duration : float = randf_range(MIN_DISCHARGE_TIME, MAX_DISCHARGE_TIME)
	_tween = create_tween()
	# TODO: Adjust when the trigger is pressed!
	#_weapon.press_trigger(get_parent())
	
	if _player_hitbox != null:
		_weapon.look_at(_player_hitbox.global_position + PLAYER_POSITION_OFFSET)
		
		_tween.tween_interval(duration)
		_tween.set_parallel(false)
	else:
		var cb : Callable = func(v : float):
			_weapon.rotation = v
			if not _weapon.is_triggered():
				_weapon.press_trigger(get_parent())
		
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.set_trans(Tween.TRANS_LINEAR)
		
		_tween.tween_method(cb, 0.0, -PI, duration)
		_tween.set_parallel(false)
	_tween.tween_callback(_weapon.release_trigger)
	_tween.tween_callback(_IdleState)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_state_finished() -> void:
	match _state:
		GlobieState.HIT:
			if _charge < MIN_HOLDABLE_CHARGE:
				_IdleState()
			else:
				_ChargeState()

func _on_charge_interval(charge : float) -> void:
	_charge = charge
	if charge <= MAX_LOW_CHARGE:
		if _sprite.animation != ANIM_CHARGE_LOW:
			_sprite.play(ANIM_CHARGE_LOW)
		_sprite.speed_scale = charge / MAX_LOW_CHARGE
	elif charge <= MAX_CHARGE:
		if _sprite.animation != ANIM_CHARGE_HIGH:
			_sprite.play(ANIM_CHARGE_HIGH)
		_sprite.speed_scale = charge / MAX_CHARGE

func _on_hitbox_collided(_hitbox: HitBox) -> void:
	_charge = _charge * 0.5
	_HitState(15, 1.0)

func _on_hit_box_used() -> void:
	_charge = _charge * 0.5
	_HitState(15, 1.0)

func _on_detector_area_entered(area: Area2D) -> void:
	if area is HitBox:
		_player_hitbox = area

func _on_detector_area_exited(area: Area2D) -> void:
	if _player_hitbox == area:
		_player_hitbox = null
