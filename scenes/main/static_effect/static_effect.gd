@tool
extends MarginContainer
class_name StaticEffect


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _PKEY_TYPE : String = "type"
const _PKEY_MIN : String = "min"
const _PKEY_MAX : String = "max"
const _PKEY_DEF : String = "default"

const PARAMS : Dictionary[StringName, Dictionary] = {
	&"intensity": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.0},
	&"screen_bleed": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.3},
}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(0.0, 1.0) var intensity : float = 0.0:		set=set_intensity
@export_range(0.0, 1.0) var screen_bleed : float = 0.3:		set=set_screen_bleed

# ------------------------------------------------------------------------------
# Private Static Variables
# ------------------------------------------------------------------------------
static var _Instance : StaticEffect = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _shader_surface: ColorRect = %ShaderSurface


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_intensity(i : float) -> void:
	i = clampf(i, 0.0, 1.0)
	if not is_equal_approx(i, intensity):
		intensity = i
		_SetParameterValue(&"intensity", intensity)

func set_screen_bleed(sb : float) -> void:
	sb = clampf(sb, 0.0, 1.0)
	if not is_equal_approx(sb, screen_bleed):
		screen_bleed = sb
		_SetParameterValue(&"screen_bleed", screen_bleed)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_SetParameterValue(&"intensity", intensity)
	_SetParameterValue(&"screen_bleed", screen_bleed)

func _enter_tree() -> void:
	if _Instance == null:
		_Instance = self

func _exit_tree() -> void:
	if _Instance == self:
		_Instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetShaderMaterial() -> ShaderMaterial:
	if _shader_surface != null:
		if _shader_surface.material is ShaderMaterial:
			return _shader_surface.material
	return null

func _GetParameterValue(param : StringName) -> Variant:
	if param in PARAMS:
		var material : ShaderMaterial = _GetShaderMaterial()
		if material != null:
			return material.get_shader_parameter(param)
		elif _PKEY_DEF in PARAMS[param]:
			return PARAMS[param][_PKEY_DEF]
	return null

func _SetParameterValue(param : StringName, value : Variant, ignore_settings : bool = false) -> bool:
	if param in PARAMS:
		if PARAMS[param][_PKEY_TYPE] == typeof(value):
			var material : ShaderMaterial = _GetShaderMaterial()
			if material != null:
				material.set_shader_parameter(param, value)
				return true
	return false

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get() -> StaticEffect:
	return _Instance

static func Set_Effect(intensity : float, bleed : float) -> void:
	if _Instance == null: return
	_Instance.intensity = clampf(intensity, 0.0, 1.0)
	_Instance.screen_bleed = clampf(bleed, 0.0, 1.0)
