@tool
extends SubViewportContainer
class_name RatioSubViewportContainer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ratio : Vector2i = Vector2i(4,3):		set=set_ratio
@export var relative_screen_scale : float = 0.5:	set=set_relative_screen_scale


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

func set_relative_screen_scale(rss : float) -> void:
	rss = clampf(rss, 0.0, 1.0)
	if not is_equal_approx(rss, relative_screen_scale):
		relative_screen_scale = rss
		_CalculateMinimumSize.call_deferred()
		

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateMinimumSize() -> void:
	var min_size : Vector2 = Vector2.ZERO
	var target_ratio : float = float(ratio.x) / float(ratio.y)
	var screen_size : Vector2 = _screen_size * relative_screen_scale
	
	var w : float = screen_size.y * target_ratio
	var h : float = screen_size.y
	var rscale : float = min(screen_size.x / w, screen_size.y / h)
	
	min_size = Vector2(w * rscale, h * rscale)
	custom_minimum_size = min_size

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_viewport_size_changed() -> void:
	var vrect : Rect2 = get_viewport_rect()
	_screen_size = vrect.size
	_CalculateMinimumSize.call_deferred()
