extends CharacterBody2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(animation_name : StringName)
signal reloaded()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BULLET_SMALL_SCENE : PackedScene = preload("uid://xfj4a2moijg2")


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 100.0
@export var jump_power : float = 140.0
@export var air_speed_multiplier : float = 0.25
@export var fall_multiplier : float = 1.4
@export var rate_of_fire : float = 0.1


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_on_ladder : bool = false
var _can_shoot : bool = true
var _continuous_fire : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _bullet_position: Marker2D = %BulletPosition
@onready var _sprite: AnimatedSprite2D = %ASprite


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_sprite.animation_finished.connect(
		func():
			animation_finished.emit(_sprite.animation)
	)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_on_surface() -> bool:
	return is_on_floor() or _is_on_ladder

func is_on_ladder() -> bool:
	return _is_on_ladder

func flip(enable : bool) -> void:
	if _sprite != null:
		_sprite.flip_h = enable

func is_flipped() -> bool:
	if _sprite != null:
		return _sprite.flip_h
	return false

func stop_animation() -> void:
	if _sprite == null: return
	_sprite.stop()

func play_animation(anim_name : StringName = &"") -> void:
	if _sprite == null: return
	if anim_name.is_empty():
		if not _sprite.animation.is_empty():
			_sprite.play()
	elif not (_sprite.animation == anim_name and _sprite.is_playing()):
		_sprite.play(anim_name)

func play_animation_sync(anim_name : StringName) -> void:
	if _sprite == null: return
	if _sprite.sprite_frames == null: return
	
	var cur_anim : StringName = _sprite.animation
	if cur_anim == anim_name: return
	
	if _sprite.sprite_frames.get_frame_count(cur_anim) == _sprite.sprite_frames.get_frame_count(anim_name):
		var cur_frame : int = _sprite.frame
		var cur_progress : float = _sprite.frame_progress
		_sprite.play(anim_name)
		_sprite.set_frame_and_progress(cur_frame, cur_progress)
		

func is_animation_playing(anim_name : StringName = &"") -> bool:
	if _sprite != null:
		if _sprite.animation == anim_name or anim_name.is_empty():
			return _sprite.is_playing()
	return false

func get_current_animation() -> StringName:
	if _sprite == null: return &""
	return _sprite.animation

func can_shoot() -> bool:
	return _can_shoot

func is_shooting() -> bool:
	return _continuous_fire

func shoot() -> void:
	if not _can_shoot: return
	var parent : Node = get_parent()
	if parent is Node2D:
		var bullet = BULLET_SMALL_SCENE.instantiate()
		bullet.angle = 180.0 if _sprite.flip_h else 0.0
		parent.add_child(bullet)
		move_to_front()
		bullet.global_position = _bullet_position.global_position
		_can_shoot = false
		get_tree().create_timer(rate_of_fire).timeout.connect(_on_rof_timeout, CONNECT_ONE_SHOT)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_rof_timeout() -> void:
	_can_shoot = true
	reloaded.emit()

func _on_ladder_detector_body_entered(body: Node2D) -> void:
	_is_on_ladder = true

func _on_ladder_detector_body_exited(body: Node2D) -> void:
	_is_on_ladder = false
