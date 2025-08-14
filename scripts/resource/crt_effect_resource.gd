@tool
extends Resource
class_name CRTEffectResource

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal value_changed(value_name : StringName, value : Variant)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const PARAM_NAMES : Array[StringName] = [
	&"resolution",
	&"scan_line_amount",
	&"warp_amount",
	&"noise_amount",
	&"interference_amount",
	&"grille_amount",
	&"grille_size",
	&"vignette_amount",
	&"vignette_intensity",
	&"aberation_amount",
	&"roll_line_amount",
	&"roll_speed",
	&"scan_line_strength",
	&"pixel_strength"
]

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var resolution : Vector2 = Vector2(320.0, 240.0):			set=set_resolution
@export_range(0.0, 1.0) var scan_line_amount : float = 1.0:			set=set_scan_line_amount
@export_range(0.0, 5.0) var warp_amount : float = 0.1:				set=set_warp_amount
@export_range(0.0, 0.3) var noise_amount : float = 0.03:			set=set_noise_amount
@export_range(0.0, 1.0) var interference_amount : float = 0.2:		set=set_interference_amount
@export_range(0.0, 1.0) var grille_amount : float = 0.1:			set=set_grille_amount
@export_range(1.0, 5.0) var grille_size : float = 1.0:				set=set_grille_size
@export_range(0.0, 2.0) var vignette_amount : float = 0.6:			set=set_vignette_amount
@export_range(0.0, 1.0) var vignette_intensity : float = 0.4:		set=set_vignette_intensity
@export_range(0.0, 1.0) var aberation_amount : float = 0.5:			set=set_aberation_amount
@export_range(0.0, 1.0) var roll_line_amount : float = 0.3:			set=set_roll_line_amount
@export_range(-8.0, 8.0) var roll_speed : float = 1.0:				set=set_roll_speed
@export_range(-12.0, -1.0) var scan_line_strength : float = -8.0:	set=set_scan_line_strength
@export_range(-4.0, 0.0) var pixel_strength : float = -2.0:			set=set_pixel_strength

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_resolution(r : Vector2) -> void:
	if r.x > 0.0 and r.y > 0.0 and not r.is_equal_approx(resolution):
		resolution = r
		value_changed.emit(&"resolution", resolution)
		changed.emit()

func set_scan_line_amount(sl : float) -> void:
	sl = clampf(sl, 0.0, 1.0)
	if not is_equal_approx(sl, scan_line_amount):
		scan_line_amount = sl
		value_changed.emit(&"scan_line_amount", scan_line_amount)
		changed.emit()

func set_warp_amount(w : float) -> void:
	w = clampf(w, 0.0, 150)
	if not is_equal_approx(w, warp_amount):
		warp_amount = w
		value_changed.emit(&"warp_amount", warp_amount)
		changed.emit()

func set_noise_amount(a : float) -> void:
	a = clampf(a, 0.0, 0.3)
	if not is_equal_approx(a, noise_amount):
		noise_amount = a
		value_changed.emit(&"noise_amount", noise_amount)
		changed.emit()

func set_interference_amount(a : float) -> void:
	a = clampf(a, 0.0, 1.0)
	if not is_equal_approx(a, interference_amount):
		interference_amount = a
		value_changed.emit(&"interference_amount", interference_amount)
		changed.emit()

func set_grille_amount(a : float) -> void:
	a = clampf(a, 0.0, 1.0)
	if not is_equal_approx(a, grille_amount):
		grille_amount = a
		value_changed.emit(&"grille_amount", grille_amount)
		changed.emit()

func set_grille_size(s : float) -> void:
	s = clampf(s, 1.0, 5.0)
	if not is_equal_approx(s, grille_size):
		grille_size = s
		value_changed.emit(&"grille_size", grille_size)
		changed.emit()

func set_vignette_amount(a : float) -> void:
	a = clampf(a, 0.0, 2.0)
	if not is_equal_approx(a, vignette_amount):
		vignette_amount = a
		value_changed.emit(&"vignette_amount", vignette_amount)
		changed.emit()

func set_vignette_intensity(i : float) -> void:
	i = clampf(i, 0.0, 1.0)
	if not is_equal_approx(i, vignette_intensity):
		vignette_intensity = i
		value_changed.emit(&"vignette_intensity", vignette_intensity)
		changed.emit()

func set_aberation_amount(a : float) -> void:
	a = clampf(a, 0.0, 1.0)
	if not is_equal_approx(a, aberation_amount):
		aberation_amount = a
		value_changed.emit(&"aberation_amount", aberation_amount)
		changed.emit()

func set_roll_line_amount(a : float) -> void:
	a = clampf(a, 0.0, 1.0)
	if not is_equal_approx(a, roll_line_amount):
		roll_line_amount = a
		value_changed.emit(&"roll_line_amount", roll_line_amount)
		changed.emit()

func set_roll_speed(s : float) -> void:
	s = clampf(s, -8.0, 8.0)
	if not is_equal_approx(s, roll_speed):
		roll_speed = s
		value_changed.emit(&"roll_speed", roll_speed)
		changed.emit()

func set_scan_line_strength(s : float) -> void:
	s = clampf(s, -12.0, -1.0)
	if not is_equal_approx(s, scan_line_strength):
		scan_line_strength = s
		value_changed.emit(&"scan_line_strength", scan_line_strength)
		changed.emit()

func set_pixel_strength(s : float) -> void:
	s = clampf(s, -8.0, 8.0)
	if not is_equal_approx(s, pixel_strength):
		pixel_strength = s
		value_changed.emit(&"pixel_strength", pixel_strength)
		changed.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_value_parameter(param_name : StringName) -> bool:
	return PARAM_NAMES.find(param_name) >= 0

func get_value(param_name : StringName) -> Variant:
	match param_name:
		&"resolution":
			return resolution
		&"scan_line_amount":
			return scan_line_amount
		&"warp_amount":
			return warp_amount
		&"noise_amount":
			return noise_amount
		&"interference_amount":
			return interference_amount
		&"grille_amount":
			return grille_amount
		&"grille_size":
			return grille_size
		&"vignette_amount":
			return vignette_amount
		&"vignette_intensity":
			return vignette_intensity
		&"aberation_amount":
			return aberation_amount
		&"roll_line_amount":
			return roll_line_amount
		&"roll_speed":
			return roll_speed
		&"scan_line_strength":
			return scan_line_strength
		&"pixel_strength":
			return pixel_strength
	return null

func set_value(param_name : StringName, value : Variant) -> void:
	match param_name:
		&"resolution":
			if typeof(value) == TYPE_VECTOR2:
				set_resolution(value)
		&"scan_line_amount":
			if typeof(value) == TYPE_FLOAT:
				set_scan_line_amount(value)
		&"warp_amount":
			if typeof(value) == TYPE_FLOAT:
				set_warp_amount(value)
		&"noise_amount":
			if typeof(value) == TYPE_FLOAT:
				set_noise_amount(value)
		&"interference_amount":
			if typeof(value) == TYPE_FLOAT:
				set_interference_amount(value)
		&"grille_amount":
			if typeof(value) == TYPE_FLOAT:
				set_grille_amount(value)
		&"grille_size":
			if typeof(value) == TYPE_FLOAT:
				set_grille_size(value)
		&"vignette_amount":
			if typeof(value) == TYPE_FLOAT:
				set_vignette_amount(value)
		&"vignette_intensity":
			if typeof(value) == TYPE_FLOAT:
				set_vignette_intensity(value)
		&"aberation_amount":
			if typeof(value) == TYPE_FLOAT:
				set_aberation_amount(value)
		&"roll_line_amount":
			if typeof(value) == TYPE_FLOAT:
				set_roll_line_amount(value)
		&"roll_speed":
			if typeof(value) == TYPE_FLOAT:
				set_roll_speed(value)
		&"scan_line_strength":
			if typeof(value) == TYPE_FLOAT:
				set_scan_line_strength(value)
		&"pixel_strength":
			if typeof(value) == TYPE_FLOAT:
				set_pixel_strength(value)
