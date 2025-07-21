@tool
extends Area2D
class_name MapSegment


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_CAMERA : StringName = &"LevelCamera"
const LOCK_DELAY : float = 0.15

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var layer : TileMapLayer = null:							set=set_layer
@export var axis : Game.ScrollAxis = Game.ScrollAxis.HORIZONTAL:	set=set_axis
@export var hide_collision : bool = false:							set=set_hide_collision
@export_tool_button("Refresh") var refresh_action = _UpdateBoundry


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _collision : CollisionShape2D = null
var _shape : RectangleShape2D = null
var _layer_rect : Rect2i = Rect2i(0,0,0,0)
var _locked : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_layer(l : TileMapLayer) -> void:
	if layer != l:
		_DisconnectLayer()
		layer = l
		_ConnectLayer()
		_UpdateBoundry.call_deferred()

func set_axis(a : Game.ScrollAxis) -> void:
	if axis != a:
		axis = a
		queue_redraw()

func set_hide_collision(c : bool) -> void:
	if hide_collision != c:
		hide_collision = c
		if _collision != null:
			_collision.visible = not hide_collision

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_UpdateBoundry()

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	if layer == null or layer.tile_set == null: return
	var crect : Rect2i = layer.get_used_rect()
	var rpos : Vector2 = crect.position * layer.tile_set.tile_size
	var rsize : Vector2 = crect.size * layer.tile_set.tile_size
	var act_size : Vector2 = _CalcAdjustedSize(rsize)
	
	var hw : float = act_size.x * 0.5
	var hh : float = act_size.y * 0.5
	var hcolor : Color = Game.Guide_Color_From_Axis(Game.ScrollAxis.HORIZONTAL, axis)
	var vcolor : Color = Game.Guide_Color_From_Axis(Game.ScrollAxis.VERTICAL, axis)
	
	var origin : Vector2 = rpos + Vector2(rsize.x * 0.5, rsize.y * 0.5)
	var tl : Vector2 = origin + Vector2(-hw, -hh)
	var tr : Vector2 = origin + Vector2(hw, -hh)
	var bl : Vector2 = origin + Vector2(-hw, hh)
	var br : Vector2 = origin + Vector2(hw, hh)
	
	draw_line(tl, tr, hcolor, 1.0, true)
	draw_line(bl, br, hcolor, 1.0, true)
	draw_line(tl, bl, vcolor, 1.0, true)
	draw_line(tr, br, vcolor, 1.0, true)

func _process(delta: float) -> void:
	if _locked > 0.0:
		_locked -= delta
	if layer == null: return
	var nrect : Rect2i = layer.get_used_rect()
	if nrect != _layer_rect:
		_layer_rect = nrect
		_UpdateBoundry.call_deferred()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectLayer() -> void:
	if layer == null: return
	if not layer.changed.is_connected(_on_layer_changed):
		layer.changed.connect(_on_layer_changed)

func _DisconnectLayer() -> void:
	if layer == null: return
	if layer.changed.is_connected(_on_layer_changed):
		layer.changed.disconnect(_on_layer_changed)

func _RemoveCollision() -> void:
	if _collision != null:
		remove_child(_collision)
		_collision.queue_free()
		_shape = null
		_collision = null

func _AddCollision() -> void:
	if _collision != null: return
	_shape = RectangleShape2D.new()
	_collision = CollisionShape2D.new()
	_collision.shape = _shape
	add_child(_collision)
	move_child(_collision, 0)
	_collision.visible = not hide_collision

func _CalcAdjustedSize(rsize : Vector2) -> Vector2:
	if axis == Game.ScrollAxis.HORIZONTAL:
		return Vector2(
			max(rsize.x, Game.SCREEN_RESOLUTION.x),
			Game.SCREEN_RESOLUTION.y
		)
	return Vector2(
		Game.SCREEN_RESOLUTION.x,
		max(rsize.y, Game.SCREEN_RESOLUTION.y)
	)

func _UpdateBoundry() -> void:
	if layer == null or layer.tile_set == null:
		_RemoveCollision()
		return
	
	_AddCollision()
	if _shape != null and _collision != null:
		var crect : Rect2i = layer.get_used_rect()
		var rpos : Vector2 = crect.position * layer.tile_set.tile_size
		var rsize : Vector2 = crect.size * layer.tile_set.tile_size
		_shape.size = _CalcAdjustedSize(rsize)
		_collision.position = rpos + Vector2(rsize.x * 0.5, rsize.y * 0.5)
	queue_redraw()

func _GrabCamera() -> void:
	if _shape == null or _collision == null: return
	var camera : ChaseCamera = ChaseCamera.Get_Camera()
	if camera == null: return
	camera.limit_left = _collision.global_position.x - (_shape.size.x * 0.5)
	camera.limit_right = _collision.global_position.x + (_shape.size.x * 0.5)
	camera.limit_top = _collision.global_position.y - (_shape.size.y * 0.5)
	camera.limit_bottom = _collision.global_position.y + (_shape.size.y * 0.5)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_layer_changed() -> void:
	_UpdateBoundry.call_deferred()

func _on_body_entered(body : Node2D) -> void:
	print("Body Entered: ", body.name, " | ", name)
	if body == null: return
	if _locked <= 0.0 and body.is_in_group(Game.GROUP_PLAYER):
		_GrabCamera()

func _on_body_exited(body : Node2D) -> void:
	if body == null: return
	if body.is_in_group(Game.GROUP_PLAYER):
		_locked = LOCK_DELAY
		print("Body Exited: ", body.name, " | ", name)
