extends CharacterBody2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal animation_finished(animation_name : StringName)
signal reloaded()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 100.0
@export var jump_power : float = 140.0
@export var air_speed_multiplier : float = 0.25
@export var fall_multiplier : float = 1.4


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _is_on_ladder : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite
@onready var _body: Node2D = %Body
@onready var _weapon: Weapon = %Weapon


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_weapon.reloaded.connect(
		func(): reloaded.emit()
	)
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
	if _body != null:
		_body.scale.x = -1.0 if enable else 1.0

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

func get_weapon() -> Weapon:
	return _weapon

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_ladder_detector_body_entered(body: Node2D) -> void:
	_is_on_ladder = true

func _on_ladder_detector_body_exited(body: Node2D) -> void:
	_is_on_ladder = false
