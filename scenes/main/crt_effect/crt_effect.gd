@tool
extends MarginContainer
class_name CRTEffect


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CONFIG_SECTION : String = "CRT Effect"
#
#const _PKEY_TYPE : String = "type"
#const _PKEY_MIN : String = "min"
#const _PKEY_MAX : String = "max"
#const _PKEY_DEF : String = "default"
#
#const PARAMS : Dictionary[StringName, Dictionary] = {
	#&"resolution": {"type":TYPE_VECTOR2, "default":Vector2(320.0, 240.0)},
	#&"scan_line_amount": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":1.0},
	#&"warp_amount": {"type":TYPE_FLOAT, "min":0.0, "max":5.0, "default":0.1},
	#&"noise_amount": {"type":TYPE_FLOAT, "min":0.0, "max":0.3, "default":0.03},
	#&"interference_amount": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.2},
	#&"grille_amount": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.1},
	#&"grille_size": {"type":TYPE_FLOAT, "min":1.0, "max":5.0, "default":1.0},
	#&"vignette_amount": {"type":TYPE_FLOAT, "min":0.0, "max":2.0, "default":0.6},
	#&"vignette_intensity": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.4},
	#&"aberation_amount": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.5},
	#&"roll_line_amount": {"type":TYPE_FLOAT, "min":0.0, "max":1.0, "default":0.3},
	#&"roll_speed": {"type":TYPE_FLOAT, "min":-8.0, "max":8.0, "default":1.0},
	#&"scan_line_strength": {"type":TYPE_FLOAT, "min":-12.0, "max":-1.0, "default":-8.0},
	#&"pixel_strength": {"type":TYPE_FLOAT, "min":-4.0, "max":0.0, "default":-2.0}
#}


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = true:					set=set_enabled, get=get_enabled
@export var settings : CRTEffectResource = null:	set=set_settings
@export var overrides : CRTEffectResource = null:	set=set_overrides

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _Instance : CRTEffect = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _shader_surface: ColorRect = %ShaderSurface

# ------------------------------------------------------------------------------
# Setters/Getters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	if enabled != e:
		enabled = e
		if not Engine.is_editor_hint():
			Settings.set_value(CONFIG_SECTION, "enabled", enabled)
		if _shader_surface != null and overrides == null:
			_shader_surface.visible = enabled

func get_enabled() -> bool:
	return enabled

func set_settings(s : CRTEffectResource) -> void:
	if s != settings:
		_DisconnectSettings()
		if s == null:
			settings = CRTEffectResource.new()
		else: settings = s
		_ConnectSettings()

func set_overrides(o : CRTEffectResource) -> void:
	if o != overrides:
		overrides = o
		if overrides == null:
			_on_settings_load()
			if _shader_surface != null:
				_shader_surface.visible = enabled
		else:
			_ActivateFromResource(overrides)
			if _shader_surface != null:
				_shader_surface.visible = true

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if settings == null:
		settings = CRTEffectResource.new()
	
	_shader_surface.visible = enabled
	if not Engine.is_editor_hint():
		Settings.reset.connect(_on_settings_reset)
		Settings.loaded.connect(_on_settings_load)
		Settings.value_changed.connect(_on_settings_value_changed)

func _enter_tree() -> void:
	if _Instance == null:
		_Instance = self

func _exit_tree() -> void:
	if _Instance == self:
		_Instance = null

#func _get(property: StringName) -> Variant:
	#return _GetParameterValue(property)
#
#func _set(property: StringName, value: Variant) -> bool:
	#return _SetParameterValue(property, value)
#
#func _get_property_list() -> Array[Dictionary]:
	#var arr : Array[Dictionary] = []
	#for property_name : StringName in PARAMS.keys():
		#var info : Dictionary = {
			#"name": property_name,
			#"type": PARAMS[property_name][_PKEY_TYPE],
			#"usage": PROPERTY_USAGE_DEFAULT
		#}
		#if _PKEY_MIN in PARAMS[property_name]:
			#info["hint"] = PROPERTY_HINT_RANGE
			#info["hint_string"] = "%f,%f"%[
				#PARAMS[property_name][_PKEY_MIN],
				#PARAMS[property_name][_PKEY_MAX]
			#]
		#arr.append(info)
	#return arr

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSettings() -> void:
	if settings == null: return
	if not settings.value_changed.is_connected(_on_crt_settings_value_changed):
		settings.value_changed.connect(_on_crt_settings_value_changed)

func _DisconnectSettings() -> void:
	if settings == null: return
	if settings.value_changed.is_connected(_on_crt_settings_value_changed):
		settings.value_changed.disconnect(_on_crt_settings_value_changed)

func _GetShaderMaterial() -> ShaderMaterial:
	if _shader_surface != null:
		if _shader_surface.material is ShaderMaterial:
			return _shader_surface.material
	return null

func _GetParameterValue(param : StringName) -> Variant:
	if settings.is_value_parameter(param):
		var material : ShaderMaterial = _GetShaderMaterial()
		if material != null:
			return material.get_shader_parameter(param)
		else:
			return settings.get_value(param)
	return null

func _SetParameterValue(param : StringName, value : Variant, ignore_settings : bool = false) -> bool:
	if settings.is_value_parameter(param):
		if typeof(settings.get_value(param)) == typeof(value):
			var material : ShaderMaterial = _GetShaderMaterial()
			if material != null:
				material.set_shader_parameter(param, value)
				if not (Engine.is_editor_hint() or ignore_settings):
					Settings.set_value(CONFIG_SECTION, param, value)
				return true
	return false

func _ActivateFromResource(crt : CRTEffectResource) -> void:
	if crt != null:
		for param : StringName in crt.PARAM_NAMES:
			_SetParameterValue(param, crt.get_value(param), true)

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get() -> CRTEffect:
	return _Instance

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_crt_settings_value_changed(value_name : StringName, value : Variant) -> void:
	if overrides == null:
		_SetParameterValue(value_name, value, true)

func _on_settings_reset() -> void:
	set_enabled(true)
	for param : StringName in CRTEffectResource.PARAM_NAMES:
		_SetParameterValue(
			param,
			settings.get_value(param)
		)
		if overrides != null:
			_ActivateFromResource(overrides)

func _on_settings_load() -> void:
	set_enabled(Settings.load_value(CONFIG_SECTION, &"enabled", true))
	for param : StringName in CRTEffectResource.PARAM_NAMES:
		var def : Variant = null
		def = settings.get_value(param)
		
		_SetParameterValue(
			param,
			Settings.load_value(CONFIG_SECTION, param, def),
			true
		)
		if overrides != null:
			_ActivateFromResource(overrides)

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section != CONFIG_SECTION or overrides != null: return
	if settings.is_value_parameter(key):
		if typeof(value) == typeof(settings.get_value(key)):
			_SetParameterValue(key, value, true)
	elif key == "enabled":
		set_enabled(value)
