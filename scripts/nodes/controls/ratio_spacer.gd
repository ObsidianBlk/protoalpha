@tool
extends Control
class_name RatioSpacer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ratio : Vector2i = Vector2i(4,3):		set=set_ratio

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _screen_size : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ratio(r : Vector2i) -> void:
	if r.x > 0 and r.y > 0 and r != ratio:
		ratio = r
		_CalculateMinimumSize.call_deferred()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

func _enter_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		if not vp.size_changed.is_connected(_on_viewport_size_changed):
			vp.size_changed.connect(_on_viewport_size_changed)
		_on_viewport_size_changed()

func _exit_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp != null:
		if vp.size_changed.is_connected(_on_viewport_size_changed):
			vp.size_changed.disconnect(_on_viewport_size_changed)

#func _get_minimum_size() -> Vector2:
	#var min_size : Vector2 = Vector2.ZERO
	#if _screen_size.x < _screen_size.y:
		#var r : float = float(ratio.x) / float(ratio.y)
		#min_size.x = _screen_size.x
		#min_size.y = _screen_size.x * r
	#else:
		#var r : float = float(ratio.y) / float(ratio.x)
		#min_size.y = _screen_size.y
		#min_size.x = _screen_size.y * r
	#print("Minimum Size: ", min_size)
	#return min_size

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateMinimumSize() -> void:
	var min_size : Vector2 = Vector2.ZERO
	var target_ratio : float = float(ratio.x) / float(ratio.y)
	
	var w : float = _screen_size.y * target_ratio
	var h : float = _screen_size.y
	var rscale : float = min(_screen_size.x / w, _screen_size.y / h)
	
	min_size = Vector2(w * rscale, h * rscale)
	print("Minimum Size: ", min_size)
	custom_minimum_size = min_size

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_viewport_size_changed() -> void:
	var vrect : Rect2 = get_viewport_rect()
	_screen_size = vrect.size
	_CalculateMinimumSize.call_deferred()
