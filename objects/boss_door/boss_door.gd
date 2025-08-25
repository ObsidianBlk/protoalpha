@tool
extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal opened()
signal closed()
signal closed_boss()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SEGMENT_BASE_NAME : String = "Segment_"
const INITIAL_SEGMENT : int = 1
const MAX_SEGMENTS : int = 8

enum BossSide {LEFT=0, RIGHT=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var boss_side : BossSide = BossSide.LEFT:	set=set_boss_side
@export var open : bool = false:					set=set_open
@export var locked : bool = false
@export var segment_delay : float = 0.1

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _transition : int = 0
var _boss_side_exit : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _left_detector: Area2D = %LeftDetector
@onready var _right_detector: Area2D = %RightDetector

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_boss_side(b : BossSide) -> void:
	if boss_side != b:
		boss_side = b
		queue_redraw()

func set_open(o : bool) -> void:
	if o != open:
		open = o
		_transition = 0
		_VisibleState(not open)
		if open:
			opened.emit()
		else:
			closed.emit()
			if _boss_side_exit:
				_boss_side_exit = false
				closed_boss.emit()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		_left_detector.body_entered.connect(_on_body_entered.bind(BossSide.LEFT, _left_detector))
		_left_detector.body_exited.connect(_on_body_exited.bind(BossSide.LEFT, _left_detector))
		_right_detector.body_entered.connect(_on_body_entered.bind(BossSide.RIGHT, _right_detector))
		_right_detector.body_exited.connect(_on_body_exited.bind(BossSide.RIGHT, _right_detector))
	_VisibleState(not open)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	# Treating these as psedo-constants
	var w : float = 16.0
	var h : float = 32.0
	var offset : float = 8.0
	# ---
	_DrawArrow(
		Vector2(
			offset if boss_side == BossSide.LEFT else -offset,
			-(h * 0.5)
		),
		w, h
	)
	_DrawX(
		Vector2(
			offset if boss_side == BossSide.RIGHT else -offset,
			-(h * 0.5)
		),
		w, h
	)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DrawX(origin : Vector2, w : float, h : float) -> void:
	var dw : float = w if boss_side == BossSide.RIGHT else -w
	draw_line(
		origin + Vector2(0.0, h * 0.5),
		origin + Vector2(dw, -(h*0.5)),
		Color.RED, 1.0, true
	)
	draw_line(
		origin + Vector2(0.0, -(h*0.5)),
		origin + Vector2(dw, h*0.5),
		Color.RED, 1.0, true
	)

func _DrawArrow(origin : Vector2, w : float, h : float) -> void:
	var dw : float = w if boss_side == BossSide.LEFT else -w
	draw_line(origin, Vector2(origin.x + dw, origin.y), Color.SPRING_GREEN, 1.0, true)
	draw_line(
		origin,
		Vector2(origin.x + (dw * 0.5), origin.y + (h * 0.25)),
		Color.SPRING_GREEN,
		1.0, true
	)
	draw_line(
		origin,
		Vector2(origin.x + (dw * 0.5), origin.y - (h * 0.25)),
		Color.SPRING_GREEN,
		1.0, true
	)

func _EnableStaticCollision(body : StaticBody2D, enable : bool) -> void:
	if body == null: return
	for child : Node in body.get_children():
		if child is CollisionShape2D:
			child.disabled = not enable

func _VisibleState(vis : bool) -> void:
	for child : Node in get_children():
		if child is StaticBody2D and child.name.begins_with(SEGMENT_BASE_NAME):
			child.visible = vis
			_EnableStaticCollision(child, vis)

func _ChangeSegment(vis : bool) -> void:
	if _transition < INITIAL_SEGMENT or _transition > MAX_SEGMENTS: return
	var target_name = &"%s%d"%[SEGMENT_BASE_NAME, _transition]
	for child : Node in get_children():
		if child is StaticBody2D and child.name == target_name:
			child.visible = vis
			_EnableStaticCollision(child, vis)
			break
	
	_transition += -1 if vis else 1
	if _transition >= INITIAL_SEGMENT and _transition <= MAX_SEGMENTS:
		get_tree().create_timer(segment_delay).timeout.connect(
			_ChangeSegment.bind(vis),
			CONNECT_ONE_SHOT
		)
	else:
		open = _transition > MAX_SEGMENTS

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_transitioning() -> bool:
	return _transition != 0

func open_door() -> void:
	if is_transitioning() or open: return
	_transition = INITIAL_SEGMENT
	_ChangeSegment(false)

func close_door() -> void:
	if is_transitioning() or not open: return
	_transition = MAX_SEGMENTS
	_ChangeSegment(true)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D, side_id : int, detector : Area2D) -> void:
	if side_id == boss_side or open or locked: return
	var triggered : bool = false
	match side_id:
		BossSide.LEFT:
			triggered = body.global_position.x < detector.global_position.x
		BossSide.RIGHT:
			triggered = body.global_position.x > detector.global_position.x
	if triggered:
		open_door.call_deferred()

func _on_body_exited(body : Node2D, side_id : int, detector : Area2D) -> void:
	if not open or locked: return
	var triggered : bool = false
	_boss_side_exit = boss_side == side_id
	match side_id:
		BossSide.LEFT:
			triggered = body.global_position.x < detector.global_position.x
		BossSide.RIGHT:
			triggered = body.global_position.x > detector.global_position.x
	if triggered:
		close_door.call_deferred()
