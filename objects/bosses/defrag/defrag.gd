extends CharacterActor2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal toggle_room_shift()
signal player_closeness_changed(close : bool)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const PULSE_SEGMENT_DURATION : float = 0.2
const PULSE_IDLE_DURATION : float = 0.05
const MODULATE_DEFAULT : Color = Color.WHITE
const MODULATE_PULSE : Color = Color.RED

const ATREE_CORE_TRANSITION : String = "parameters/Core/Transition/transition_request"
const ATREE_CAST : String = "parameters/Cast/request"

const CORE_ACTION_IDLE : String = "Idle"
const CORE_ACTION_WALK : String = "Walk"
const CORE_ACTION_HURT : String = "Hurt"
const CORE_ACTION_BRICK : String = "Brick"
const CORE_ACTION_CAST : String = "Cast"

const ANIM_IDLE : StringName = &"idle"
const ANIM_HURT : StringName = &"hurt"
const ANIM_WALK : StringName = &"walk"
const ANIM_FROM_BRICK : StringName = &"from_brick"
const ANIM_TO_BRICK : StringName = &"to_brick"
const ANIM_BRICK : StringName = &"brick"
const ANIM_FACE_AWAY : StringName = &"face_away"
const ANIM_FACE_TOWARD : StringName = &"face_toward"
const ANIM_CAST : StringName = &"cast"

const AUDIO_EXPLOSION : StringName = &"explosion"
const AUDIO_HURT : StringName = &"hurt"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The group to use for finding target travel locations ([Node2D])
@export var travel_target_group : StringName = &""
## Travel speed in pixels per second.
@export var travel_speed : float = 120.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tween : Tween = null
var _brick_mode : bool = false

var _player : WeakRef = weakref(null)
var _player_close : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_player_close() -> bool:
	return _player_close

func is_flipped() -> bool:
	if _sprite != null:
		return _sprite.flip_h
	return false

func flip(flip_h : bool) -> void:
	if _sprite != null:
		_sprite.flip_h = flip_h

func get_player() -> CharacterActor2D:
	var player : CharacterBody2D = _player.get_ref()
	if player == null:
		var parr : Array[Node] = get_tree().get_nodes_in_group(Game.GROUP_PLAYER)
		for p : Node in parr:
			if p is CharacterActor2D:
				player = p
				_player = weakref(p)
	return player

func face_player() -> void:
	var player : CharacterBody2D = get_player()
	if player != null and _sprite != null:
		_sprite.flip_h = player.global_position.x < global_position.x

func fire_map_weapon(count : int) -> void:
	var player : CharacterActor2D = get_player()
	if player == null: return
	
	var mwarr : Array[Node] = get_tree().get_nodes_in_group(Game.GROUP_BOSS_MAP_WEAPON)
	for i : int in range(count):
		if mwarr.size() <= 0: break
		var idx : int = randi_range(0, mwarr.size() - 1)
		if mwarr[idx].has_method(&"shoot_target"):
			mwarr[idx].shoot_target(player)
		mwarr.remove_at(idx)

func room_shift_toggle(pulse_segments : int, seg_duration : float) -> void:
	if _tween != null or _sprite == null: return
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_LINEAR)
	_tween.set_parallel(false)
	for seg : int in range(pulse_segments):
		_tween.tween_property(_sprite, "modulate", MODULATE_PULSE, seg_duration)
		_tween.tween_property(_sprite, "modulate", MODULATE_DEFAULT, 0.0)
		_tween.tween_interval(PULSE_IDLE_DURATION)
	await _tween.finished
	_tween = null
	toggle_room_shift.emit()

func change_action(action : String) -> void:
	if animation_tree == null: return
	animation_tree.set(ATREE_CORE_TRANSITION, action)
	if action == CORE_ACTION_BRICK:
		_brick_mode = true

func end_brick_mode() -> void:
	_brick_mode = false

#func cast() -> void:
	#if animation_tree == null: return
	#animation_tree.set(ATREE_CAST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_detector_body_entered(_body: Node2D) -> void:
	_player_close = true
	player_closeness_changed.emit(_player_close)

func _on_player_detector_body_exited(_body: Node2D) -> void:
	_player_close = false
	player_closeness_changed.emit(_player_close)
