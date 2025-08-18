@tool
extends Node2D
class_name Weapon

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal fired()
signal charged(percent : float)
signal reloaded()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SFX_SPAWN : StringName = &"spawn"
const SFX_EXPLODE : StringName = &"explode"
const SFX_CHARGING : StringName = &"charging"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var weapon_def : WeaponDef = null:			set=set_weapon_def
@export_flags_2d_physics var collision_mask : int

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _can_shoot : bool = true
var _charge : float = 0.0
var _final_trigger : Callable = _Stub

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_weapon_def(wd : WeaponDef) -> void:
	if wd != weapon_def:
		_Reset()
		weapon_def = wd

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if weapon_def == null: return
	if _charge > 0.0:
		_charge -= delta
		charged.emit(1.0 - (_charge/weapon_def.rate_of_fire))
		if _charge <= 0.0:
			_final_trigger.call()
			_Reset()
			reloaded.emit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Stub() -> void: pass

func _Reset() -> void:
	_can_shoot = true
	_charge = 0.0
	_final_trigger = _Stub

func _PlayWeaponSFX(sound_name : StringName) -> void:
	if weapon_def == null: return
	if weapon_def.sound_sheet == null: return
	weapon_def.sound_sheet.play(sound_name)

func _Trigger(projectile_container : Node2D) -> void:
	if projectile_container == null or weapon_def == null: return
	var p : Projectile = weapon_def.get_projectile_instance()
	p.collision_mask = collision_mask
	projectile_container.add_child(p)
	p.global_position = global_position
	p.angle = rad_to_deg(Vector2.RIGHT.rotated(global_rotation).angle())
	if weapon_def.sound_sheet != null:
		var wss : SoundSheet = weapon_def.sound_sheet
		wss.play(SFX_SPAWN)
		p.hit.connect(wss.play.bind(SFX_EXPLODE))
	fired.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func can_shoot() -> bool:
	return _can_shoot

func is_triggered() -> bool:
	return not _can_shoot or _charge > 0.0

func press_trigger(projectile_container : Node2D = null) -> void:
	if weapon_def == null or projectile_container == null or not _can_shoot: return
	
	match weapon_def.type:
		WeaponDef.Type.PROJECTILE:
			if weapon_def.charging:
				_charge = weapon_def.rate_of_fire
				_final_trigger = _Trigger.bind(projectile_container)
			else:
				_can_shoot = false
				_Trigger(projectile_container)
				get_tree().create_timer(weapon_def.rate_of_fire).timeout.connect(
					(func():
						if not _can_shoot:
							_can_shoot = true
							reloaded.emit()),
					CONNECT_ONE_SHOT
				)
		WeaponDef.Type.BEAM:
			print("Yeah right... like I bothered making a beam!")

func release_trigger() -> void:
	if weapon_def == null: return
	if weapon_def.charging:
		_Reset()
