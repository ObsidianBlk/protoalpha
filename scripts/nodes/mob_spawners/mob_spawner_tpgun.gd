@tool
extends MobSpawner
class_name MobSpawnerTPGun

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _ED_RAY_LENGTH : float = 20.0
const _ED_COLOR : Color = Color.AQUA

const MOB_INFO : MobInfo = preload("uid://5ovideremesx")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var flipped : bool = false:								set=set_flipped
@export var idle_time : float = 1.0
@export_range(-90.0, 90.0) var weapon_angle : float = 0.0:		set=set_weapon_angle
@export var weapon_def : WeaponDef = null
@export var projectile_container : Node2D = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_flipped(f : bool) -> void:
	if f != flipped:
		flipped = f
		queue_redraw()

func set_weapon_angle(a : float) -> void:
	a = clampf(a, -90.0, 90.0)
	if not is_equal_approx(a, weapon_angle):
		weapon_angle = a
		queue_redraw()


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	if mob_info == null:
		mob_info = MOB_INFO

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _draw_sprite_ref() -> void:
	var size : Vector2i = mob_info.sprite_reference.get_size()
	var pos : Vector2 = Vector2(-(size.x * 0.5), -(size.y * 0.5))
	draw_texture(mob_info.sprite_reference, pos)

func _draw_editor_display() -> void:
	if not Engine.is_editor_hint(): return
	var to : Vector2 = Vector2.RIGHT.rotated(deg_to_rad(weapon_angle)) * _ED_RAY_LENGTH
	if flipped:
		to = to.reflect(Vector2.UP)
	draw_line(Vector2.ZERO, to, _ED_COLOR, 1.0, true)

func _verify_mob(mob : Node2D) -> bool:
	if Game.Node_Has_Properties(mob, ["flipped", "idle_time", "weapon_angle", "weapon_def", "projectile_container"]):
		mob.flipped = flipped
		mob.idle_time = idle_time
		mob.weapon_angle = weapon_angle
		mob.weapon_def = weapon_def
		mob.projectile_container = projectile_container
		return true
	return false
