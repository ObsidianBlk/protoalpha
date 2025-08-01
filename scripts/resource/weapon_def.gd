@tool
extends Resource
class_name WeaponDef


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
enum Type {PROJECTILE=0, BEAM=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var type : Type = Type.PROJECTILE
@export var name : StringName = "Weapon"
@export var icon : Texture2D = null
@export var sound_sheet : SoundSheet = null
@export_group("Projectile Info")
@export var projectile : PackedScene = null
@export var rate_of_fire : float = 1.0
@export var charging : bool = false


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_projectile_instance() -> Projectile:
	if projectile != null:
		var p : Node = projectile.instantiate()
		if p is Projectile:
			return p
		p.queue_free()
	return null
