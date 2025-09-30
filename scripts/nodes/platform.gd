extends CharacterBody2D


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const TILE_CUSTOM_DATA_NAME : String = "Platform"
enum Rail {
	NONE=0,
	HORIZONTAL=1,
	VERTICAL=2,
	BOTTOM_RIGHT=3,
	BOTTOM_LEFT=4,
	TOP_LEFT=5,
	TOP_RIGHT=6,
	CROSS=7
}
enum Travel {UP_LEFT=-1, DOWN_RIGHT=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var map_layer : TileMapLayer = null
@export var initial_direction : Travel = Travel.DOWN_RIGHT
@export_range(0.0, 4.0) var speed_scale : float = 1.0
@export var enabled : bool = true:								set=set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _cur_coord : Vector2i = Vector2i.ZERO
var _prev_coord : Vector2i = Vector2i.ZERO
var _dir : Travel = Travel.DOWN_RIGHT
var _progress : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	if e != enabled:
		enabled = e
		set_physics_process(enabled)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_physics_process(enabled)
	_dir = initial_direction
	_Process(0.0, true)

func _physics_process(delta: float) -> void:
	_Process(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FlipDefaultDirection() -> void:
	if _dir == Travel.UP_LEFT:
		_dir = Travel.DOWN_RIGHT
	else: _dir = Travel.UP_LEFT

func _FlipDirection(dir : Travel) -> Travel:
	if dir == Travel.UP_LEFT:
		return Travel.DOWN_RIGHT
	return Travel.UP_LEFT

func _GetDirection(from : Vector2i, to : Vector2i) -> Travel:
	if to.x < from.x or to.y < from.y:
		return Travel.UP_LEFT
	elif to.x > from.x or to.y > from.y:
		return Travel.DOWN_RIGHT
	return _dir

func _UpdateCoords(initial : bool, skips : int) -> Rail:
	var coord : Vector2i = map_layer.local_to_map(position)
	var rail : Rail = _GetRailAtCoord(coord)
	if not (rail == Rail.NONE or rail == Rail.CROSS):
		if initial:
			_cur_coord = coord
			_prev_coord = coord
		if coord != _cur_coord:
			_prev_coord = _cur_coord
			_cur_coord = coord
		
		if skips > 0:
			var direction : Travel = _GetDirection(_prev_coord, _cur_coord)
			for _i : int in range(skips):
				var ncoord : Vector2i = _NextCellFromRail(_cur_coord, direction, rail)
				var nrail : Rail = _GetRailAtCoord(ncoord)
				if nrail == Rail.NONE:
					_prev_coord = _cur_coord
					_dir = _FlipDirection(direction)
				else:
					_prev_coord = _cur_coord
					_cur_coord = ncoord
					rail = nrail
		
	return rail

func _Process(delta : float, initial : bool = false) -> void:
	if map_layer == null: return
	
	_progress += delta * speed_scale
	var skips : int = abs(floor(_progress))
	_progress = _progress - floor(_progress)
	
	var rail : Rail = _UpdateCoords(initial, skips)
	if rail == Rail.NONE or rail == Rail.CROSS: return
	var direction : Travel = _GetDirection(_prev_coord, _cur_coord)

	match rail:
		Rail.HORIZONTAL:
			_PositionAlongHorizontal(direction)
		Rail.VERTICAL:
			_PositionAlongVertical(direction)
		Rail.BOTTOM_RIGHT:
			_PositionCorner(direction, false, false)
		Rail.BOTTOM_LEFT:
			_PositionCorner(direction, true, false)
		Rail.TOP_LEFT:
			_PositionCorner(direction, true, true)
		Rail.TOP_RIGHT:
			_PositionCorner(direction, false, true)

func _PositionCorner(direction : Travel, h_left : bool, v_up : bool) -> void:
	if _progress <= 0.5:
		if h_left:
			_PositionAlongHorizontal(direction)
		else:
			var flip : bool = v_up and direction == Travel.UP_LEFT
			_PositionAlongVertical(_FlipDirection(direction) if flip else direction)
	else:
		if not h_left:
			_PositionAlongHorizontal(direction)
		else:
			var flip : bool = v_up and direction == Travel.DOWN_RIGHT
			_PositionAlongVertical(_FlipDirection(direction) if flip else direction)

func _PositionAlongHorizontal(direction : Travel) -> void:
	if map_layer == null or map_layer.tile_set == null: return
	var progress : float = _progress if direction == Travel.DOWN_RIGHT else 1.0 - _progress
	var tile_size : Vector2i = map_layer.tile_set.tile_size
	var pos : Vector2 = map_layer.map_to_local(_cur_coord) - (tile_size * 0.5)
	var dist : float = float(tile_size.x - 1) * progress
	var npos = pos + Vector2(dist, floor(float(tile_size.y) * 0.5))
	position = npos

func _PositionAlongVertical(direction : Travel) -> void:
	if map_layer == null or map_layer.tile_set == null: return
	var progress : float = _progress if direction == Travel.DOWN_RIGHT else 1.0 - _progress
	var tile_size : Vector2i = map_layer.tile_set.tile_size
	var pos : Vector2 = map_layer.map_to_local(_cur_coord) - (tile_size * 0.5)
	var dist : float = float(tile_size.y - 1) * progress
	var npos = pos + Vector2(floor(float(tile_size.x) * 0.5), dist)
	position = npos

#func _Process(delta : float, initial : bool = false) -> void:
	#if map_layer == null: return
	#
	#var coord : Vector2i = map_layer.local_to_map(position)
	#var rail : Rail = _GetRailAtCoord(coord)
	#print("Coord: ", coord, " | Cur: ", _cur_coord, " | Prev: ", _prev_coord)
	#if rail == Rail.NONE or rail == Rail.CROSS:
		##print("No Rail")
		#return
	#print("Rail: ", rail)
	#if initial: _cur_coord = coord
	#if coord != _cur_coord:
		#_prev_coord = _cur_coord
		#_cur_coord = coord
	#
	#var nprog : float = _progress + (delta * speed_scale * _dir)
	#var skips : int = abs(floor(nprog))
	#for _i : int in range(skips):
		## TODO: Shit'll get weird if rail is Rail.CROSS
		#var ncoord : Vector2i = _NextCellFromRail(_cur_coord, _dir, rail)
		#var nrail : Rail = _GetRailAtCoord(ncoord)
		#if nrail == Rail.NONE:
			#_prev_coord = _cur_coord
			#_FlipDirection()
		#else:
			#_prev_coord = _cur_coord
			#_cur_coord = ncoord
			#rail = nrail
	#
	#_progress = nprog - floor(nprog)
	#if _progress >= 0.98 and _progress <= 1.0:
		#print("Blah")
	#var progress : float = _progress
	#if _cur_coord.x < _prev_coord.x or _cur_coord.y < _prev_coord.y:
		#progress = 1.0 - _progress
	#
	#match rail:
		#Rail.HORIZONTAL:
			#_ProcessHorizontal(_cur_coord, progress)
		#Rail.VERTICAL:
			#_ProcessVertical(_cur_coord, progress)
		#Rail.BOTTOM_RIGHT:
			#if _progress <= 0.5:
				#_ProcessVertical(_cur_coord, 1.0 - progress)
			#else:
				#_ProcessHorizontal(_cur_coord, progress)
		#Rail.BOTTOM_LEFT:
			#if _progress <= 0.5:
				#_ProcessHorizontal(_cur_coord, progress)
			#else:
				#_ProcessVertical(_cur_coord, progress)
		#Rail.TOP_LEFT:
			#if _progress <= 0.5:
				#_ProcessHorizontal(_cur_coord, progress)
			#else:
				#_ProcessVertical(_cur_coord, 1.0 - progress)
		#Rail.TOP_RIGHT:
			#if _progress <= 0.5:
				#_ProcessVertical(_cur_coord, progress)
			#else:
				#_ProcessHorizontal(_cur_coord, progress)


#func _ProcessHorizontal(coord : Vector2i, progress : float) -> void:
	#if map_layer == null or map_layer.tile_set == null: return
	#var tile_size : Vector2i = map_layer.tile_set.tile_size
	#var pos : Vector2 = map_layer.map_to_local(coord) - (tile_size * 0.5)
	#var dist : float = float(tile_size.x - 1) * progress
	#var npos = pos + Vector2(dist, floor(float(tile_size.y) * 0.5))
	#position = npos
#
#func _ProcessVertical(coord : Vector2i, progress : float) -> void:
	#if map_layer == null or map_layer.tile_set == null: return
	#var tile_size : Vector2i = map_layer.tile_set.tile_size
	#var pos : Vector2 = map_layer.map_to_local(coord) - (tile_size * 0.5)
	#var dist : float = float(tile_size.y - 1) * progress
	#var npos = pos + Vector2(floor(float(tile_size.x) * 0.5), dist)
	#position = npos


func _GetRailAtCoord(coord : Vector2i) -> Rail:
	if map_layer != null:
		var data : TileData = map_layer.get_cell_tile_data(coord)
		if data != null and data.has_custom_data(TILE_CUSTOM_DATA_NAME):
			var val : Variant = data.get_custom_data(TILE_CUSTOM_DATA_NAME)
			if typeof(val) == TYPE_INT:
				if val > 0 and val <= 7: return val
	return Rail.NONE

func _NextCellFromRail(cell : Vector2i, direction : Travel, rail : Rail, prev_rail : Rail = Rail.NONE) -> Vector2i:
	match rail:
		Rail.HORIZONTAL:
			cell.x += direction
		Rail.VERTICAL:
			cell.y += direction
		Rail.BOTTOM_RIGHT:
			if direction == Travel.DOWN_RIGHT:
				cell.x += 1
			else: cell.y += 1
		Rail.BOTTOM_LEFT:
			if direction == Travel.DOWN_RIGHT:
				cell.y += 1
			else: cell.x -= 1
		Rail.TOP_LEFT:
			if direction == Travel.DOWN_RIGHT:
				cell.y -= 1
			else: cell.x -= 1
		Rail.TOP_RIGHT:
			if direction == Travel.DOWN_RIGHT:
				cell.x += 1
			else: cell.y -= 1
		Rail.CROSS:
			return _NextCellFromRail(cell, direction, prev_rail)
	return cell
