@tool
extends TileMapLayer
class_name LevelSection

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum ScrollAxis {HORIZONTAL=0, VERTICAL=1}

const GUIDE_LINE_LENGTH : float = 256.0
const GUIDE_LINE_COLOR : Color = Color.DEEP_SKY_BLUE

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var scroll : ScrollAxis = ScrollAxis.HORIZONTAL:	set=set_scroll
@export var size : int = 240:								set=set_size


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _guide_origin : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_scroll(s : ScrollAxis) -> void:
	if scroll != s:
		scroll = s
		_on_changed()
		queue_redraw()

func set_size(s : int) -> void:
	if s > 0 and size != s:
		size = s
		_on_changed()
		queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	changed.connect(_on_changed)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var hsize : float = float(size) * 0.5
	var hguide_len : float = GUIDE_LINE_LENGTH * 0.5
	var from : Vector2 = Vector2(-hguide_len, -hsize)
	var to : Vector2 = Vector2(hguide_len, -hsize)
	if scroll == ScrollAxis.VERTICAL:
		from = Vector2(-hsize, -hguide_len)
		to = Vector2(-hsize, hguide_len)
	
	draw_line(
		_guide_origin + from,
		_guide_origin + to,
		GUIDE_LINE_COLOR,
		1.0
	)
	
	from = Vector2(-hguide_len, hsize)
	to = Vector2(hguide_len, hsize)
	if scroll == ScrollAxis.VERTICAL:
		from = Vector2(hsize, -hguide_len)
		to = Vector2(hsize, hguide_len)
	
	draw_line(
		_guide_origin + from,
		_guide_origin + to,
		GUIDE_LINE_COLOR,
		1.0
	)
	

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _RemoveOutOfBounds(tile_size : float) -> void:
	var hsize : float = float(size) * 0.5
	var cells : Array[Vector2i] = get_used_cells()
	for cell : Vector2i in cells:
		var pos : Vector2 = Vector2(cell) * tile_size
		var in_bounds : bool = pos.y >= -hsize and pos.y <= hsize
		if scroll == ScrollAxis.VERTICAL:
			in_bounds = pos.x >= -hsize and pos.x <= hsize
		print("Cell: ", cell, " | Pos: ", pos, " | lbound: ", -hsize, " | rbound: ", hsize)
		if not in_bounds:
			set_cell(cell, -1)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_changed() -> void:
	if tile_set == null: return
	print("Changed")
	_RemoveOutOfBounds(tile_set.tile_size.x if scroll == ScrollAxis.VERTICAL else tile_set.tile_size.y)
