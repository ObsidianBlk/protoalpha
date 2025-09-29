extends CharacterBody2D


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const TILE_CUSTOM_DATA_NAME : String = "Platform"
enum Rail {
	NONE=0,
	VERTICAL=1,
	HORIZONTAL=2,
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
@export var pixels_per_second : int = 10

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _coord : Vector2i = Vector2i.ZERO
var _cur_rail : Rail = Rail.NONE

var _dir : Travel = Travel.DOWN_RIGHT

var _last_position : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_dir = initial_direction
	_UpdateRail()
	if _cur_rail == Rail.NONE:
		printerr("Platform failed to find a rail.")
	else:
		_Process(0.0)

func _physics_process(delta: float) -> void:
	if _cur_rail == Rail.NONE: return
	_Process(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Process(delta : float) -> void:
	if map_layer == null or map_layer.tile_set == null: return
	
	var nprog : float = 0.0#_progress + (delta * speed_scale)
	
	match _cur_rail:
		Rail.HORIZONTAL:
			_ProcessHorizontal(nprog)
		Rail.VERTICAL:
			_ProcessVertical(nprog)

func _ProcessHorizontal(progress : float) -> void:
	if map_layer == null or map_layer.tile_set == null: return
	var pos : Vector2 = map_layer.map_to_local(_coord) 
	var tile_size : int = map_layer.tile_set.tile_size.x
	var dist : float = float(tile_size) * progress
	if _dir == Travel.DOWN_RIGHT:
		global_position = pos + Vector2(dist, 0.0)
	else:
		global_position = pos + Vector2(float(tile_size) - dist, 0.0)

func _ProcessVertical(progress : float) -> void:
	if map_layer == null or map_layer.tile_set == null: return
	var pos : Vector2 = map_layer.map_to_local(_coord)
	var tile_size : int = map_layer.tile_set.tile_size.y
	var dist : float = float(tile_size) * progress
	if _dir == Travel.DOWN_RIGHT:
		global_position = pos + Vector2(0.0, dist)
	else:
		global_position = pos + Vector2(0.0, float(tile_size) - dist)


func _GetRailAtCoord(coord : Vector2i) -> Rail:
	if map_layer != null:
		var data : TileData = map_layer.get_cell_tile_data(coord)
		if data != null and data.has_custom_data(TILE_CUSTOM_DATA_NAME):
			var val : Variant = data.get_custom_data(TILE_CUSTOM_DATA_NAME)
			if typeof(val) == TYPE_INT:
				if val > 0 and val <= 7: return val
	return Rail.NONE

func _GetRailAtPosition(pos : Vector2) -> Rail:
	if map_layer != null:
		var coord : Vector2i = map_layer.local_to_map(pos)
		return _GetRailAtCoord(coord)
	return Rail.NONE

func _UpdateRail() -> void:
	var nrail : Rail = Rail.NONE
	if map_layer != null:
		var coord : Vector2i = map_layer.local_to_map(global_position)
		if coord != _coord or _cur_rail == Rail.NONE:
			_coord = coord
			nrail = _GetRailAtCoord(_coord)
	_cur_rail = nrail

#func _NextCellFromRail(cell : Vector2i, direction : Travel, rail : Rail, prev_rail : Rail = Rail.NONE) -> Vector2i:
	#match rail:
		#Rail.HORIZONTAL:
			#cell.x += direction
		#Rail.VERTICAL:
			#cell.y += direction
		#Rail.BOTTOM_RIGHT:
			#if direction == Travel.DOWN_RIGHT:
				#cell.y += 1
			#else: cell.x -= 1
		#Rail.BOTTOM_LEFT:
			#if direction == Travel.DOWN_RIGHT:
				#cell.y += 1
			#else: cell.x -= 1
		#Rail.TOP_LEFT:
			#if direction == Travel.DOWN_RIGHT:
				#cell.y -= 1
			#else: cell.x -= 1
		#Rail.TOP_RIGHT:
			#if direction == Travel.DOWN_RIGHT:
				#cell.x += 1
			#else: cell.y -= 1
		#Rail.CROSS:
			#return _NextCellFromRail(cell, direction, prev_rail)
	#return cell
#
#
#func _BuildRails() -> void:
	#if map_layer == null or map_layer.tile_set == null:
		#printerr("Platform missing valid TileMapLayer.")
		#return
	#
	#var cell : Vector2i = map_layer.local_to_map(global_position)
	#var buffer : Array[Vector2i] = [cell]
	#
	#while buffer.size() > 0:
		#cell = buffer.pop_front()
		#var rail : Rail = _GetRailAt(cell)
		#if rail == Rail.NONE: continue
		#
		#var ncell : Vector2 = _NextCellFromRail(cell, Travel.UP_LEFT, rail)
		#if not (ncell in buffer or ncell in _rails):
			#buffer.append(ncell)
		#
		#ncell = _NextCellFromRail(cell, Travel.DOWN_RIGHT, rail)
		#if not (ncell in buffer or ncell in _rails):
			#buffer.append(ncell)
		#
		#if not cell in _rails:
			#_rails[cell] = rail
