@tool
extends MobSpawner
class_name MobSpawnerShellie


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MOB_INFO: MobInfo = preload("uid://1nk16vgguts7")

const _SPRITE_Y_OFFSET : float = 2.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(1, 16) var speed : int = 8
@export_enum("TOP:1", "BOTTOM:-1") var orientation : int = 1:	set=set_orientation
@export var facing : Game.MobFacingH = Game.MobFacingH.RIGHT:	set=set_facing

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_orientation(o : int) -> void:
	if o in [-1,1] and o != orientation:
		orientation = o
		queue_redraw()

func set_facing(f : Game.MobFacingH) -> void:
	if f != facing:
		facing = f
		queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	if mob_info == null:
		mob_info = MOB_INFO


# ------------------------------------------------------------------------------
# "Virutal" Private Methods
# ------------------------------------------------------------------------------
func _draw_sprite_ref() -> void:
	var size : Vector2i = mob_info.sprite_reference.get_size()
	var pos : Vector2 = Vector2(-(size.x * 0.5), -(size.y * 0.5) + (_SPRITE_Y_OFFSET * -orientation))
	var rsize : Vector2 = Vector2(
		size.x, size.y * orientation
	)
	draw_texture_rect(mob_info.sprite_reference, Rect2(pos, rsize), false)
	#draw_texture(mob_info.sprite_reference, pos)

func _verify_mob(mob : Node2D) -> bool:
	if Game.Node_Has_Properties(mob, ["speed", "orientation", "facing"]):
		mob.speed = speed
		mob.orientation = orientation
		mob.facing = facing
		return true
	return false
