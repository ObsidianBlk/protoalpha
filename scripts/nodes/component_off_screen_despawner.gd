extends Node
class_name ComponentOffScreenDespawner

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The [Node2D] object to watch.
@export var host : Node2D = null
## The offset from the host's origin from which to calculate on-screen region.
@export var offset : Vector2 = Vector2.ZERO
## The size (in pixels) of the on-screen region.
@export var size : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _on_screen : bool = false

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if host == null:
		var node : Node = get_parent()
		if node is Node2D:
			host = node

func _process(_delta : float) -> void:
	if host == null: return

	if _IsOnScreen():
		_on_screen = true
	elif _on_screen:
		host.queue_free()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsOnScreen() -> bool:
	if host == null and size.x > 0.0 and size.y > 0.0: return false
	
	var viewport : Viewport = get_viewport()
	if viewport != null:
		var cam : Camera2D = viewport.get_camera_2d()
		if cam != null:
			var camera_rect : Rect2 = Rect2(
				cam.get_screen_center_position() - (Game.SCREEN_RESOLUTION * 0.5),
				Game.SCREEN_RESOLUTION
			)
			var self_rect : Rect2 = Rect2(host.global_position - offset, size)
			return camera_rect.intersects(self_rect)
	return false
