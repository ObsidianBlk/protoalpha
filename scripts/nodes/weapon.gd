@tool
extends Node2D
class_name Weapon

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal charged(percent : float)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var weapon_def : WeaponDef = null:			set=set_weapon_def

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _charge : float = 0.0
var _final_trigger : Callable = _Stub

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_weapon_def(wd : WeaponDef) -> void:
	if wd != weapon_def:
		# TODO: Reset any variables as needed.
		weapon_def = wd

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Stub() -> void: pass

func _trigger(projectile_container : Node2D) -> void:
	if projectile_container == null or weapon_def == null: return
	var p : Projectile = weapon_def.get_projectile_instance()
	projectile_container.add_child(p)
	p.global_position = global_position

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func trigger(projectile_container : Node2D = null) -> void:
	if weapon_def == null: return
	if projectile_container == null:
		_charge = 0.0
		_final_trigger = _Stub
		return
