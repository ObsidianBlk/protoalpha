@tool
extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const STEP : float = 16.0
const EXPLOSION : PackedScene = preload("res://objects/enemy_explosion/enemy_explosion.tscn")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var flip_h : bool = false:			set=set_flip_h
@export var steps_from_center : int = 1:	set=set_steps_from_center
@export_category("Sound")
@export var sound_sheet : SoundSheet = null
@export var sound_explosion : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _origin : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _viz: Node2D = %Viz
@onready var _lower: HitBox = %Lower
@onready var _mid: HitBox = %Mid
@onready var _face: HitBox = %Face
@onready var _anim: AnimationPlayer = %AnimationPlayer


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_flip_h(flip : bool) -> void:
	if flip != flip_h:
		flip_h = flip
		_UpdateViz()

func set_steps_from_center(s : int) -> void:
	if s > 0 and s != steps_from_center:
		steps_from_center = s
		queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_origin = global_position
	_UpdateViz()

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var dist : float = STEP * steps_from_center
	draw_line(Vector2(-dist, -4.0), Vector2(dist, -4.0), Game.GUIDE_COLOR_MATCHING_AXIS, 1.0, true)
	draw_line(Vector2(-dist, -8.0), Vector2(-dist, 0.0), Game.GUIDE_COLOR_APPOSING_AXIS, 1.0, true)
	draw_line(Vector2(dist, -8.0), Vector2(dist, 0.0), Game.GUIDE_COLOR_APPOSING_AXIS, 1.0, true)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateViz() -> void:
	if _viz == null: return
	_viz.scale.x = -1.0 if flip_h else 1.0

func _Step() -> void:
	if Engine.is_editor_hint() or _viz == null: return
	global_position.x += STEP * _viz.scale.x
	if is_equal_approx(global_position.x, _origin.x + (_viz.scale.x * steps_from_center * STEP)):
		flip_h = not flip_h

func _ExplodePart(part : Node2D) -> void:
	var parent : Node2D = get_parent()
	if parent != null:
		var exp : GPUParticles2D = EXPLOSION.instantiate()
		exp.position = part.global_position
		parent.add_child(exp)
		if sound_sheet != null:
			sound_sheet.play(sound_explosion)
		exp.emitting = true
		part.visible = false
		await exp.finished

func _Die() -> void:
	await _ExplodePart(_face)
	await _ExplodePart(_mid)
	await _ExplodePart(_lower)
	queue_free()
	
	

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_component_health_dead() -> void:
	_anim.pause()
	_Die.call_deferred()
