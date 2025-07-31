@tool
extends Area2D
class_name TransitionZone


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var scroll_axis : Game.ScrollAxis = Game.ScrollAxis.HORIZONTAL:		set=set_scroll_axis
@export var pixels_per_second : float = 10.0:								set=set_pixels_per_second
@export var offset : int = 0:												set=set_offset
@export var segment_a : MapSegment = null:									set=set_segment_a
@export var segment_b : MapSegment = null:									set=set_segment_b

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_scroll_axis(sa : Game.ScrollAxis) -> void:
	if sa != scroll_axis:
		scroll_axis = sa
		queue_redraw()

func set_pixels_per_second(pps : float) -> void:
	if pps > 0.0 and not is_equal_approx(pixels_per_second, pps):
		pixels_per_second = pps

func set_offset(o : float) -> void:
	if o >= 0 and offset != o:
		offset = o
		queue_redraw()

func set_segment_a(s : MapSegment) -> void:
	if s == null or (s != segment_a and s != segment_b):
		segment_a = s

func set_segment_b(s : MapSegment) -> void:
	if s == null or (s != segment_b and s != segment_a):
		segment_b = s

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var lt_to : Vector2 = Vector2(-offset, 0.0)
	var rb_to : Vector2 = Vector2(offset, 0.0)
	if scroll_axis == Game.ScrollAxis.VERTICAL:
		lt_to = Vector2(0.0, -offset)
		rb_to = Vector2(0.0, offset)
	
	draw_line(lt_to, rb_to, Game.GUIDE_COLOR_MATCHING_AXIS, 1.0, true)
	draw_circle(lt_to, 3.0, Game.GUIDE_COLOR_MATCHING_AXIS, true, -1.0, true)
	draw_circle(rb_to, 3.0, Game.GUIDE_COLOR_MATCHING_AXIS, true, -1.0, true)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ReleaseCamera(camera : ChaseCamera) -> void:
	if camera == null: return
	camera.limit_left = -10000
	camera.limit_right = 10000
	camera.limit_top = -10000
	camera.limit_bottom = 10000

func _GetDestinationSegment() -> MapSegment:
	if segment_a == null and segment_b == null: return null
	if segment_a.in_focus():
		return segment_b
	return segment_a

func _Transition(player : CharacterActor2D) -> void:
	if Engine.is_editor_hint() or _tween != null: return
	
	var segment : MapSegment = _GetDestinationSegment()
	if segment == null:
		print_debug("No segment to transition to.")
		return
	var bounds : Dictionary[StringName, float] = segment.get_bounds()
	if bounds.is_empty():
		print_debug("Segment boundries empty.")
		return
	var seg_center : Vector2 = segment.get_center()
	
	var camera : ChaseCamera = ChaseCamera.Get_Camera()
	if camera == null:
		print_debug("No camera. Snapping transition.")
		# TODO: Move player up to offset
		segment.focus()
		return
	
	var cam_target : Node2D = camera.target
	camera.target = null
	_ReleaseCamera(camera)
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_parallel(false)
	
	var tween_to : Callable = func(n : Node2D, prop : String, from : float, to : float, parallel : bool = false, force_duration : float = 0.0):
		if not is_equal_approx(from, to):
			var duration : float = abs(to - from) / pixels_per_second
			if force_duration > 0.0:
				duration = force_duration
			if parallel:
				_tween.parallel().tween_property(n, prop, to, duration)
			else: _tween.tween_property(n, prop, to, duration)
			return duration
		return 0.0
	
	segment.lock(3.0)
	match scroll_axis:
		Game.ScrollAxis.HORIZONTAL:
			var bound : StringName = MapSegment.BOUNDS_RIGHT
			if camera.global_position.x < seg_center.x:
				bound = MapSegment.BOUNDS_LEFT
			
			var last_duration : float = 0.0
			if segment.axis == Game.ScrollAxis.HORIZONTAL:
				var res : float = Game.SCREEN_RESOLUTION.x * 0.5
				if bound == MapSegment.BOUNDS_LEFT:
					res *= -1.0
			
				tween_to.call(camera, "global_position:y", camera.global_position.y, seg_center.y)
				last_duration = tween_to.call(camera, "global_position:x", camera.global_position.x, bounds[bound] - res)
			else:
				var res : float = Game.SCREEN_RESOLUTION.y * 0.5
				var tedge : float = bounds[MapSegment.BOUNDS_TOP] + res
				var bedge : float = bounds[MapSegment.BOUNDS_BOTTOM] - res
				if not (camera.global_position.y >= tedge and camera.global_position.y <= bedge):
					var edge : float = tedge
					if camera.global_position.y > bedge:
						edge = bedge
					tween_to.call(camera, "global_position:y", camera.global_position.y, edge)
				last_duration = tween_to.call(camera, "global_position:x", camera.global_position.x, seg_center.x)
				
			var sn : float = -1.0 if bound == MapSegment.BOUNDS_RIGHT else 1.0
			tween_to.call(
				player, "global_position:x",
				player.global_position.x, bounds[bound] + (sn * float(offset)),
				true,
				last_duration
			)
		Game.ScrollAxis.VERTICAL:
			var bound : StringName = MapSegment.BOUNDS_BOTTOM
			if camera.global_position.y < seg_center.y:
				bound = MapSegment.BOUNDS_TOP
			
			var last_duration : float = 0.0
			if segment.axis == Game.ScrollAxis.VERTICAL:
				var res : float = Game.SCREEN_RESOLUTION.y * 0.5
				if bound == MapSegment.BOUNDS_TOP:
					res *= -1
				
				tween_to.call(camera, "global_position:x", camera.global_position.x, seg_center.x)
				last_duration = tween_to.call(camera, "global_position:y", camera.global_position.y, bounds[bound] - res)
			else:
				var res : float = Game.SCREEN_RESOLUTION.x * 0.5
				var ledge : float = bounds[MapSegment.BOUNDS_LEFT] + res
				var redge : float = bounds[MapSegment.BOUNDS_RIGHT] - res
				if not (camera.global_position.x >= ledge and camera.global_position.x <= redge):
					var edge = ledge
					if camera.global_position.x > redge:
						edge = redge
					tween_to.call(camera, "global_position:x", camera.global_position.x, edge)
				last_duration = tween_to.call(camera, "global_position:y", camera.global_position.y, seg_center.y)
			
			var sn : float = -1.0 if bound == MapSegment.BOUNDS_BOTTOM else 1.0
			tween_to.call(
				player, "global_position:y",
				player.global_position.y, bounds[bound] + (sn * float(offset)),
				true,
				last_duration
			)
	
	_tween.finished.connect(_on_transition_complete.bind(segment, camera, cam_target), CONNECT_ONE_SHOT)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		_Transition(body)

func _on_transition_complete(segment : MapSegment, camera : ChaseCamera, target : Node2D) -> void:
	_tween = null
	if camera != null and target != null:
		camera.target = target
	if segment != null:
		segment.focus()
