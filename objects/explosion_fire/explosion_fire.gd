@tool
extends Node2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal finished()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var spawn_area : Shape2D = null:		set=set_spawn_area
@export var sub_explosions : int = 1:			set=set_sub_explosions

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _count : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _particles: GPUParticles2D = %ExpFire

# ------------------------------------------------------------------------------
# Setter
# ------------------------------------------------------------------------------
func set_spawn_area(s : Shape2D) -> void:
	if s is RectangleShape2D or s is CircleShape2D and s != spawn_area:
		_DisconnectShape()
		spawn_area = s
		_ConnectShape()
		queue_redraw()

func set_sub_explosions(e : int) -> void:
	if e >= 1 and e != sub_explosions:
		sub_explosions = e

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_particles.finished.connect(_on_particles_finished)

func _draw() -> void:
	if spawn_area == null or not Engine.is_editor_hint(): return
	var rid : RID = get_canvas_item()
	var c : Color = Color.AQUA
	c.a = 0.1
	spawn_area.draw(rid, c)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectShape() -> void:
	if spawn_area == null: return
	if not spawn_area.changed.is_connected(queue_redraw):
		spawn_area.changed.connect(queue_redraw)

func _DisconnectShape() -> void:
	if spawn_area == null: return
	if spawn_area.changed.is_connected(queue_redraw):
		spawn_area.changed.disconnect(queue_redraw)

func _GetRandomPoint() -> Vector2:
	if spawn_area != null:
		if spawn_area is RectangleShape2D:
			return Vector2(
				randf_range(-0.5, 0.5) * spawn_area.size.x,
				randf_range(-0.5, 0.5) * spawn_area.size.y
			)
		elif spawn_area is CircleShape2D:
			return Vector2(randf_range(0.0, spawn_area.radius), 0.0).rotated(TAU * randf())
	return Vector2.ZERO

func _ExplodeParticle() -> void:
	if _particles == null: return
	var pos : Vector2 = _GetRandomPoint()
	_particles.position = pos
	_particles.emitting = true

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func explode() -> void:
	if _particles == null or _count > 0: return
	_count = sub_explosions
	_ExplodeParticle()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_particles_finished() -> void:
	_count -= 1
	if _count > 0:
		_ExplodeParticle()
	else: finished.emit()
