@tool
extends Area2D
class_name TransitionZone


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var axis : Game.ScrollAxis = Game.ScrollAxis.HORIZONTAL:		set=set_axis
@export var offset : Vector2 = Vector2.ZERO:							set=set_offset

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_axis(a : Game.ScrollAxis) -> void:
	if axis != a:
		axis = a
		queue_redraw()


func set_offset(o : Vector2) -> void:
	if not offset.is_equal_approx(o):
		offset = o
		queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	if not Engine.is_editor_hint(): return # Only draw guide in editor.
	var hw : float = Game.SCREEN_RESOLUTION.x * 0.5
	var hh : float = Game.SCREEN_RESOLUTION.y * 0.5
	
	var tl : Vector2 = offset + Vector2(-hw, -hh)
	var tr : Vector2 = offset + Vector2(hw, -hh)
	var bl : Vector2 = offset + Vector2(-hw, hh)
	var br : Vector2 = offset + Vector2(hw, hh)
	var hcolor : Color = Game.Guide_Color_From_Axis(axis, Game.ScrollAxis.HORIZONTAL)
	var vcolor : Color = Game.Guide_Color_From_Axis(axis, Game.ScrollAxis.VERTICAL)

	draw_line(tl, tr, hcolor, 1.0, true)
	draw_line(bl, br, hcolor, 1.0, true)
	draw_line(tl, bl, vcolor, 1.0, true)
	draw_line(tr, br, vcolor, 1.0, true)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if Engine.is_editor_hint(): return # Don't do anything in editor
