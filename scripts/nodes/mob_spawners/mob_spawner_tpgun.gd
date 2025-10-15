@tool
extends MobSpawner
class_name MobSpawnerTPGun

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _ED_RAY_LENGTH : float = 20.0
const _ED_COLOR : Color = Color.AQUA

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
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _draw_editor_display() -> void:
	if not Engine.is_editor_hint(): return
	var to : Vector2 = Vector2.RIGHT.rotated(deg_to_rad(weapon_angle)) * _ED_RAY_LENGTH
	draw_line(Vector2.ZERO, to, _ED_COLOR, 1.0, true)

func _VerifyMob(mob : Node2D) -> bool:
	var props : Array[String] = ["flipped", "idle_time", "weapon_angle", "weapon_def", "projectile_container"]
	for prop : String in props:
		if not prop in mob:
			return false
	mob.flipped = flipped
	mob.idle_time = idle_time
	mob.weapon_angle = weapon_angle
	mob.weapon_def = weapon_def
	mob.projectile_container = projectile_container
	return true
