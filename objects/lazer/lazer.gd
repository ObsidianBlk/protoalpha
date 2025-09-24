@tool
extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BEAM : PackedScene = preload("uid://cdu2rmkbkl0vo")

const BEAM_SEGMENT_SIZE : int = 16

const ANIM_INACTIVE : StringName = &"inactive"
const ANIM_ACTIVE : StringName = &"active"
const ANIM_CHARGING : StringName = &"charging"
const ANIM_DISCHARGING : StringName = &"discharging"

enum Facing {RIGHT, DOWN, LEFT, UP}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var orientation : Facing = Facing.RIGHT:		set=set_orientation
@export var length : int = 2:							set=set_length
@export var travel_speed : float = 12.0:				set=set_travel_speed
@export var start_on : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _beams : Array[HitBox] = []
var _seg_delay : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _body: Node2D = %Body
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_orientation(o : Facing) -> void:
	if o != orientation:
		orientation = o
		_UpdateFacing()

func set_length(l : int) -> void:
	if l >= 1 and l != length:
		length = l

func set_travel_speed(s : float) -> void:
	if s > 0.0 and not is_equal_approx(travel_speed, s):
		travel_speed = s

func set_start_on(o : bool) -> void:
	if o != start_on:
		start_on = o
		if Engine.is_editor_hint():
			activate(start_on)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateFacing()
	if not Engine.is_editor_hint():
		if start_on:
			_sprite.play(ANIM_ACTIVE)
			_AllBeams()

func _process(delta: float) -> void:
	if _sprite == null or _body == null: return
	if _sprite.animation == ANIM_ACTIVE:
		if _beams.size() < length:
			_seg_delay -= delta
			if _seg_delay <= 0.0:
				_AddBeam()
				_seg_delay = 1.0 / travel_speed
		elif _beams.size() > length:
			_seg_delay -= delta
			if _seg_delay < 0.0:
				_RemoveBeam()
				_seg_delay = 1.0 / travel_speed
	elif _sprite.animation == ANIM_INACTIVE and _beams.size() > 0:
		_seg_delay -= delta
		if _seg_delay <= 0.0:
			_RemoveBeam()
			_seg_delay = 1.0 / travel_speed

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateFacing() -> void:
	if _body != null:
		match orientation:
			Facing.RIGHT:
				_body.rotation_degrees = 0.0
			Facing.DOWN:
				_body.rotation_degrees = 90.0
			Facing.LEFT:
				_body.rotation_degrees = 180.0
			Facing.UP:
				_body.rotation_degrees = 270.0

func _AllBeams() -> void:
	if _body == null: return
	while _beams.size() < length:
		_AddBeam()

func _AddBeam() -> void:
	if _body == null: return
	var beam : Node = BEAM.instantiate()
	if beam is HitBox:
		beam.position.x = _beams.size() * BEAM_SEGMENT_SIZE
		beam.show_behind_parent = true
		_body.add_child(beam)
		_beams.append(beam)
	else:
		printerr("BEAM instance wrong object type.")
		beam.queue_free()

func _RemoveBeam() -> void:
	if _body == null: return
	var idx : int = _beams.size() - 1
	if idx >= 0:
		_body.remove_child(_beams[idx])
		_beams[idx].queue_free()
		_beams.remove_at(idx)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_active() -> bool:
	if _sprite != null:
		return _sprite.animation != ANIM_INACTIVE
	return false

func is_charging() -> bool:
	if is_active():
		return _sprite.animation != ANIM_ACTIVE
	return false

func activate(on : bool) -> void:
	if _sprite == null: return
	if on and not is_active():
		_sprite.play(ANIM_CHARGING)
	elif not on:
		_sprite.play(ANIM_INACTIVE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_sprite_animation_finished() -> void:
	if _sprite == null: return
	match _sprite.animation:
		ANIM_CHARGING:
			_sprite.play(ANIM_DISCHARGING)
		ANIM_DISCHARGING:
			_sprite.play(ANIM_ACTIVE)
