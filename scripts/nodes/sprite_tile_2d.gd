@tool
extends Sprite2D
class_name SpriteTile2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The coordiant within the [property texture] to display.
@export var coord : Vector2i = Vector2i.ZERO:				set=set_coord
@export_subgroup("Tile", "tile_")
## The size (in pixels) of a single tile
@export var tile_size : Vector2i = Vector2i(16,16):			set=set_tile_size
## The number of pixels between each tile
@export var tile_gap : Vector2i = Vector2i.ZERO:			set=set_tile_gap
## The number of pixels from the Left-Top of the [property texture] to start reading
## tiles.
@export var tile_offset : Vector2i = Vector2i.ZERO:			set=set_tile_offset


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _grid_size : Vector2i = Vector2i.ZERO

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_coord(c : Vector2i) -> void:
	if c.x >= 0 and c.y >= 0:
		if texture != null and _grid_size != Vector2i.ZERO:
			c.x = clampi(c.x, 0, _grid_size.x - 1)
			c.y = clampi(c.y, 0, _grid_size.y - 1)
		if coord != c:
			coord = c
			_UpdateRegion()

func set_tile_size(s : Vector2i) -> void:
	if s.x > 0 and s.y > 0 and s != tile_size:
		tile_size = s
		_UpdateGridSize()

func set_tile_gap(g : Vector2i) -> void:
	if g.x >= 0 and g.y >= 0 and tile_gap != g:
		tile_gap = g
		_UpdateGridSize()

func set_tile_offset(o : Vector2i) -> void:
	if o.x >= 0 and o.y >= 0 and tile_offset != o:
		tile_offset = o
		_UpdateGridSize()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	texture_changed.connect(_on_texture_changed)
	region_enabled = true
	region_rect = Rect2(Vector2.ZERO, tile_size)
	_UpdateGridSize()
	_UpdateRegion()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateGridSize() -> void:
	if texture == null:
		_grid_size = Vector2i.ZERO
		return
	
	var tex_size : Vector2i = Vector2i(texture.get_size())
	if tile_offset.x >= tex_size.x or tile_offset.y >= tex_size.y:
		_grid_size = Vector2i.ZERO
		return
	
	var tile_area : Vector2i = tex_size - tile_offset
	var tg_size : Vector2i = tile_size + tile_gap
	
	var grid : Vector2i = tile_area / tg_size
	if grid.x > 0 and grid.y > 0:
		_grid_size = grid
		var ncoord : Vector2i = Vector2i(
			clampi(coord.x, 0, _grid_size.x),
			clampi(coord.y, 0, _grid_size.y)
		)
		if ncoord != coord:
			coord = ncoord

func _UpdateRegion() -> void:
	if texture == null or _grid_size == Vector2i.ZERO: return
	var tg_size : Vector2i = tile_size + tile_gap
	var tile_position : Vector2 = tile_offset + (tg_size * coord)
	region_rect = Rect2(tile_position, Vector2(tile_size))
	region_enabled = true

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_grid_width() -> int:
	return _grid_size.x

func get_grid_height() -> int:
	return _grid_size.y

func get_grid_size() -> Vector2i:
	return _grid_size

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_texture_changed() -> void:
	_UpdateGridSize()
