@tool
extends MobSpawner
class_name MobSpawnerBlockie


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _STEP : float = 16

const MOB_INFO : MobInfo = preload("uid://dt14yjdjvlyd4")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var flip_h : bool = false:			set=set_flip_h
@export var steps_from_center : int = 1:	set=set_steps_from_center


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_flip_h(f : bool) -> void:
	if f != flip_h:
		flip_h = f
		queue_redraw()

func set_steps_from_center(s : int) -> void:
	if s > 0 and s != steps_from_center:
		steps_from_center = s
		queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	if mob_info == null:
		#print("Setting MOB Info: ", MOB_INFO)
		mob_info = MOB_INFO

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _draw_editor_display() -> void:
	var dist : float = _STEP * steps_from_center
	draw_line(Vector2(-dist, -4.0), Vector2(dist, -4.0), Game.GUIDE_COLOR_MATCHING_AXIS, 1.0, true)
	draw_line(Vector2(-dist, -8.0), Vector2(-dist, 0.0), Game.GUIDE_COLOR_APPOSING_AXIS, 1.0, true)
	draw_line(Vector2(dist, -8.0), Vector2(dist, 0.0), Game.GUIDE_COLOR_APPOSING_AXIS, 1.0, true)

func _verify_mob(mob : Node2D) -> bool:
	if Game.Node_Has_Properties(mob, ["flip_h", "steps_from_center"]):
		mob.flip_h = flip_h
		mob.steps_from_center = steps_from_center
		return true
	return false
