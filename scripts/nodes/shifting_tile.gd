extends CharacterBody2D
class_name ShiftingTile


# TODO:
#   Assign tilemap for better X/Y axis determinations when travel() is called.

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal travel_completed()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var texture : Texture2D = null:			set=set_texture
@export var region : Rect2 = Rect2(0,0,0,0):	set=set_region
## Speed in pixels per second
@export var speed_pps : int = 20:				set=set_speed_pps
@export var flash_color : Color = Color.RED
@export var flash_duration : float = 1.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _sprite : Sprite2D = null
var _collision : CollisionShape2D = null

var _tween : Tween = null


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_texture(t : Texture2D) -> void:
	if _sprite == null:
		texture = t
		_Build()

func set_region(r : Rect2) -> void:
	if _sprite == null:
		region = r
		_Build()

func set_speed_pps(s : int) -> void:
	if s > 0 and speed_pps != s:
		speed_pps = s

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	_Build()

func _exit_tree() -> void:
	if _sprite != null:
		remove_child(_sprite)
		_sprite.queue_free()
	if _collision != null:
		remove_child(_collision)
		_collision.queue_free()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Build() -> void:
	if _sprite != null: return
	if texture == null: return
	if not region.has_area(): return
	if region.position.x < 0.0 or region.position.y < 0.0: return
	
	_sprite = Sprite2D.new()
	_sprite.texture = texture
	_sprite.region_rect = region
	_sprite.region_enabled = true
	add_child(_sprite)
	
	var coll_shape : RectangleShape2D = RectangleShape2D.new()
	coll_shape.size = region.size
	_collision = CollisionShape2D.new()
	_collision.shape = coll_shape
	add_child(_collision)
	
	
	

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

func travel(from : Vector2, to : Vector2) -> void:
	if _tween != null: return
	
	global_position = from
	_tween = create_tween()
	var posA : Vector2 = Vector2.ZERO
	
	if abs(from.x - to.x) >= abs(from.y - to.y):
		posA = Vector2(from.x, to.y)
	else:
		posA = Vector2(to.x, from.y)
	
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_parallel(false)
	
	var duration : float = flash_duration / 3.0
	_sprite.modulate = flash_color
	_tween.tween_property(_sprite, "modulate", Color.WHITE, duration)
	_tween.tween_property(_sprite, "modulate", flash_color, 0.0)
	_tween.tween_property(_sprite, "modulate", Color.WHITE, duration)
	_tween.tween_property(_sprite, "modulate", flash_color, 0.0)
	_tween.tween_property(_sprite, "modulate", Color.WHITE, duration)
	
	var dist : float = global_position.distance_to(posA)
	duration = dist / float(speed_pps)
	_tween.tween_property(self, "global_position", posA, duration)
	
	dist = posA.distance_to(to)
	duration = dist / float(speed_pps)
	_tween.tween_property(self, "global_position", to, duration)
	
	await _tween.finished
	_tween = null
	travel_completed.emit()
