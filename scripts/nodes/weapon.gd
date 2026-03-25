@tool
extends Node2D
class_name Weapon

# TODO: There's quite a bit of jank. Maybe another pass.

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal fired()
signal charged(percent : float)
signal fully_charged()
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
@export var verbose : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _can_shoot : bool = true
var _charge : float = 0.0
var _final_trigger : Callable = _Stub
var _auto_attack : Callable = _Stub

var _active_def : WeaponDef = null
var _last_fired_def : WeaponDef = null
var _trigger_pressed : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_weapon_def(wd : WeaponDef) -> void:
	if wd != weapon_def:
		_PrintVerbose("Setting Weapon Def")
		_Reset()
		weapon_def = wd
		_active_def = wd

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if weapon_def == null: return
	if _charge > 0.0:
		_charge -= delta
		charged.emit(1.0 - (_charge/weapon_def.rate_of_fire))
		if _charge <= 0.0:
			fully_charged.emit()
		#if _charge <= 0.0:
			#_final_trigger.call()
			#_Reset()
			#reloaded.emit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Stub() -> void: pass

func _PrintVerbose(msg : String) -> void:
	if not verbose: return
	print(msg)

func _Reset() -> void:
	#if weapon_def != null and weapon_def.charging == false:
		#print("Reset Called")
	_can_shoot = true
	_charge = 0.0
	_final_trigger = _Stub
	_active_def = weapon_def
	_last_fired_def = null
	_PrintVerbose("Resetting")

func _PlayWeaponSFX(sound_name : StringName) -> void:
	if weapon_def == null: return
	if weapon_def.sound_sheet == null: return
	weapon_def.sound_sheet.play(sound_name)

func _Trigger(projectile_container : Node2D) -> void:
	if projectile_container == null or _active_def == null: return
	var p : Projectile = _active_def.get_projectile_instance()
	if p == null:
		printerr("Weapon Definition failed to spawn projectile instance.")
		return
	
	p.collision_mask = collision_mask
	projectile_container.add_child(p)
	p.global_position = global_position
	p.angle = rad_to_deg(Vector2.RIGHT.rotated(global_rotation).angle())
	if _active_def.sound_sheet != null:
		var wss : SoundSheet = _active_def.sound_sheet
		wss.play(SFX_SPAWN)
		p.hit.connect(wss.play.bind(SFX_EXPLODE))
	fired.emit()

func _StartCharging(projectile_container : Node2D) -> void:
	if weapon_def.charging:
		_charge = weapon_def.rate_of_fire
		_final_trigger = _Trigger.bind(projectile_container)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func can_shoot() -> bool:
	return _can_shoot

func is_triggered() -> bool:
	# TODO: Remember what this was for.
	return not _can_shoot or _charge > 0.0

## Returns whether the trigger call to [Weapon] was from [method press_trigger]
## ([code]true[/code]) or from [method release_trigger] ([code]false[/code]
func is_trigger_pressed() -> bool:
	return _trigger_pressed

## Self explainitory
func press_trigger(projectile_container : Node2D = null) -> void:
	if _active_def == null or projectile_container == null or not _can_shoot: return
	_trigger_pressed = true
	_PrintVerbose("Trigger Pressed")
	_last_fired_def = _active_def
	match _active_def.type:
		WeaponDef.Type.PROJECTILE:
			if _active_def.charging:
				_can_shoot = false
				_charge = _active_def.rate_of_fire
				_final_trigger = _Trigger.bind(projectile_container)
			else:
				_can_shoot = false
				_Trigger(projectile_container)
				var rof : float = _active_def.rate_of_fire
				if _active_def.automatic:
					_auto_attack = press_trigger.bind(projectile_container)
				elif _active_def.alt_fire != null:
					_PrintVerbose("Alt Fire Projectile!")
					_active_def = _active_def.alt_fire
					_auto_attack = press_trigger.bind(projectile_container)
				_PrintVerbose("Time: %d"%[Time.get_ticks_msec()])
				get_tree().create_timer(rof).timeout.connect(
					(func():
						if not _can_shoot:
							_PrintVerbose("Time: %d"%[Time.get_ticks_msec()])
							_can_shoot = true
							if _auto_attack != _Stub:
								_auto_attack.call()
							else:
								_Reset()
								reloaded.emit()
						),
					CONNECT_ONE_SHOT
				)
		WeaponDef.Type.BEAM:
			_PrintVerbose("Yeah right... like I bothered making a beam!")


func release_trigger() -> void:
	_trigger_pressed = false
	if _last_fired_def == null: return
	if _last_fired_def.charging:
		if _charge <= 0.0 and _final_trigger != _Stub:
			_final_trigger.call()
			_final_trigger = _Stub
		_PrintVerbose("Trigger Releasing from Charge")
		_Reset()
		reloaded.emit()
	else:
		_auto_attack = _Stub
