@tool
extends Area2D
class_name Projectile


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal hit()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 320.0
@export_range(-180.0, 180.0) var angle : float:		set=set_angle, get=get_angle
@export var lifetime : float = 2.0
@export var dmg : int = 1
@export var visual_node : Node2D = null:			set=set_visual_node

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _angle : float = 0.0
var _dead : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_speed(s : float) -> void:
	if s > 0.0 and not is_equal_approx(speed, s):
		speed = s

func set_angle(a : float) -> void:
	a = deg_to_rad(clampf(a, -180.0, 180.0))
	if not is_equal_approx(_angle, a):
		_angle = a
		_UpdateVisualNode()

func get_angle() -> float:
	return rad_to_deg(_angle)

func set_visual_node(n : Node2D) -> void:
	if visual_node != n:
		visual_node = n
		_UpdateVisualNode()


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		area_entered.connect(_on_area_entered)
	_UpdateVisualNode()

func _process(delta: float) -> void:
	if not (Engine.is_editor_hint() or _dead):
		position += Vector2.RIGHT.rotated(_angle) * speed * delta
		lifetime -= delta
		if lifetime <= 0.0:
			die()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateVisualNode() -> void:
	if visual_node != null:
		visual_node.rotation = _angle

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func die() -> void:
	if not (Engine.is_editor_hint() or _dead):
		_dead = true
		if visual_node != null:
			visual_node.visible = false
		# TODO: Maybe spawn a small explosion sprite?
		queue_free()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if not (Engine.is_editor_hint() or _dead):
		hit.emit()
		die()

func _on_area_entered(area : Area2D) -> void:
	if Engine.is_editor_hint(): return
	if area is HitBox:
		hit.emit()
		area.hurt(dmg)
		die()
