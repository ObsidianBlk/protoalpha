extends CharacterBody2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
## Emitted when platform reaches a dead-end
## [br]NOTE: Signal will not emit if platform path is circularly connected.
signal path_completed()
## Emitted when platform reaches a dead-end while traveling RIGHT or DOWN
## [br]NOTE: Signal will not emit if platform path is circularly connected.
signal path_completed_high()
## Emitted when platform reaches a dead-end while traveling LEFT or UP
## [br]NOTE: Signal will not emit if platform path is circularly connected.
signal path_completed_low()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const TILE_CUSTOM_DATA_NAME : String = "Platform"
enum Rail {
	NONE=0,
	HORIZONTAL=1,
	VERTICAL=2,
	# NOTE: Corner names are based on the Vertical and Horizontal directions,
	#  not their position in a square.
	BOTTOM_RIGHT=3,
	BOTTOM_LEFT=4,
	TOP_LEFT=5,
	TOP_RIGHT=6,
	CROSS=7
}
enum Travel { ## Platform travel direction.
	LOW=-1, ## Platform traveling LEFT or UP (depending on the track)
	HIGH=1  ## Platform traveling RIGHT or DOWN (depending on the track)
}
enum Axis {HORIZONTAL=0, VERTICAL=1}


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The [MapSegment] the platform node will listen to in order to detect it's
## default enable state.
@export var segment : MapSegment = null:						set=set_segment
## The [TileMapLayer] this platform will read to detect it's track.
## [br][b]NOTE:[/b] Platform node [i]must[/i] have it's origin inside of a track
## tile in order to work.
@export var map_layer : TileMapLayer = null
## The initial travel direction of the platform.
@export var initial_direction : Travel = Travel.HIGH
## A scale multiplier adjusting platform speed across the tracks.
## at a [property speed_scale] of [code]1.0[/code] (default) the platform
## travels at a speed of one tile per second.
@export_range(0.0, 4.0) var speed_scale : float = 1.0
## If [code]true[/code] platform will travel across it's track while the
## assigned [property segment] is active.
@export var enabled : bool = true:								set=set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _cur_coord : Vector2i = Vector2i.ZERO
var _direction : Travel = Travel.HIGH
var _axis : Axis = Axis.HORIZONTAL
var _progress : float = 0.0
var _corner_handled : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_segment(s : MapSegment) -> void:
	if s != segment:
		_DisconnectSegment()
		segment = s
		_ConnectSegment()
		_UpdateProcessState()

func set_enabled(e : bool) -> void:
	if e != enabled:
		enabled = e
		_UpdateProcessState()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	var res : int = _initialize()
	if res != OK:
		set_physics_process(false)
		match res:
			ERR_CANT_RESOLVE:
				printerr("Platform missing TileMapLayer")
			ERR_DOES_NOT_EXIST:
				printerr("Platform not placed on a rail.")
			
	else: _UpdateProcessState()

func _physics_process(delta: float) -> void:
	if map_layer == null: return
	
	_progress += delta * speed_scale * _direction
	var skips : int = abs(floor(_progress))
	_progress -= float(skips) * sign(_progress)
	_UpdateCoords(skips)
	var rail : Rail = _GetRailAtCoord(_cur_coord)

	# These are just to make logic easier to read.
	var dhigh : bool = _direction == Travel.HIGH
	var dlow : bool = not dhigh
	# ---
	
	var check_flip : bool = (dhigh and _progress >= 0.5) or (dlow and _progress <= 0.5)
	if check_flip and not _corner_handled:
		_corner_handled = true
		_ProcessCornerFlip(rail)

	if _axis == Axis.HORIZONTAL:
		_PositionHorizontal()
	else:
		_PositionVertical()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateProcessState() -> void:
	var active : bool = true
	if segment != null:
		active = segment.player_in_segment()
	else: print_debug("Platform ", get_path(), " not assigned a MapSegment.")
	set_physics_process(enabled and active)

func _ConnectSegment() -> void:
	if segment == null: return
	if not segment.entered.is_connected(_UpdateProcessState):
		segment.entered.connect(_UpdateProcessState)
	if not segment.exited.is_connected(_UpdateProcessState):
		segment.exited.connect(_UpdateProcessState)

func _DisconnectSegment() -> void:
	if segment == null: return
	if segment.entered.is_connected(_UpdateProcessState):
		segment.entered.disconnect(_UpdateProcessState)
	if segment.exited.is_connected(_UpdateProcessState):
		segment.exited.disconnect(_UpdateProcessState)

func _FlipDirection(d : Travel) -> Travel:
	if d == Travel.HIGH:
		return Travel.LOW
	return Travel.HIGH

func _FlipAxis(a : Axis) -> Axis:
	if a == Axis.HORIZONTAL:
		return Axis.VERTICAL
	return Axis.HORIZONTAL

func _GetRailAtCoord(coord : Vector2i) -> Rail:
	if map_layer != null:
		var data : TileData = map_layer.get_cell_tile_data(coord)
		if data != null and data.has_custom_data(TILE_CUSTOM_DATA_NAME):
			var val : Variant = data.get_custom_data(TILE_CUSTOM_DATA_NAME)
			if typeof(val) == TYPE_INT:
				if val > 0 and val <= 7: return val
	return Rail.NONE

func _initialize() -> int:
	if map_layer == null: return ERR_CANT_RESOLVE
	
	_direction = initial_direction
	_cur_coord = map_layer.local_to_map(position)
	var rail : Rail = _GetRailAtCoord(_cur_coord)
	if rail == Rail.NONE: return ERR_DOES_NOT_EXIST

	match rail:
		Rail.HORIZONTAL:
			_axis = Axis.HORIZONTAL
		Rail.VERTICAL:
			_axis = Axis.VERTICAL
		Rail.BOTTOM_RIGHT, Rail.TOP_LEFT:
			_axis = Axis.VERTICAL if _direction == Travel.HIGH else Axis.HORIZONTAL
		Rail.BOTTOM_LEFT, Rail.TOP_RIGHT:
			_axis = Axis.HORIZONTAL if _direction == Travel.HIGH else Axis.VERTICAL

	return OK

func _ProcessCornerFlip(rail : Rail) -> void:
	var ahoriz : bool = _axis == Axis.HORIZONTAL
	var flip_axis : bool = true
	match rail:
		Rail.BOTTOM_RIGHT:
			_direction = Travel.HIGH
		Rail.BOTTOM_LEFT:
			if ahoriz:
				_direction = Travel.HIGH
			else: _direction = Travel.LOW
		Rail.TOP_LEFT:
			_direction = Travel.LOW
		Rail.TOP_RIGHT:
			if ahoriz:
				_direction = Travel.LOW
			else: _direction = Travel.HIGH
		_: flip_axis = false
	if flip_axis: _axis = _FlipAxis(_axis)

func _RailNeighborValid(from : Rail, to: Rail) -> bool:
	match from:
		Rail.HORIZONTAL:
			if _direction == Travel.HIGH:
				return to in [Rail.HORIZONTAL, Rail.BOTTOM_LEFT, Rail.TOP_LEFT, Rail.CROSS]
			return to in [Rail.HORIZONTAL, Rail.BOTTOM_RIGHT, Rail.TOP_RIGHT, Rail.CROSS]
		Rail.VERTICAL:
			if _direction == Travel.HIGH:
				return to in [Rail.VERTICAL, Rail.CROSS, Rail.TOP_LEFT, Rail.TOP_RIGHT]
			return to in [Rail.VERTICAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.BOTTOM_LEFT]
		Rail.BOTTOM_RIGHT:
			if _direction == Travel.HIGH:
				if _axis == Axis.HORIZONTAL:
					return to in [Rail.HORIZONTAL, Rail.CROSS, Rail.BOTTOM_LEFT, Rail.TOP_LEFT]
				else:
					return to in [Rail.VERTICAL, Rail.CROSS, Rail.TOP_LEFT, Rail.TOP_RIGHT]
		Rail.BOTTOM_LEFT:
			if _direction == Travel.HIGH and _axis == Axis.VERTICAL:
				return to in [Rail.VERTICAL, Rail.CROSS, Rail.TOP_LEFT, Rail.TOP_RIGHT]
			elif _direction == Travel.LOW and _axis == Axis.HORIZONTAL:
				return to in [Rail.HORIZONTAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.TOP_RIGHT]
		Rail.TOP_LEFT:
			if _direction == Travel.LOW:
				if _axis == Axis.HORIZONTAL:
					return to in [Rail.HORIZONTAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.TOP_LEFT]
				else:
					return to in [Rail.VERTICAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.BOTTOM_LEFT]
		Rail.TOP_RIGHT:
			if _direction == Travel.HIGH and _axis == Axis.HORIZONTAL:
				return to in [Rail.HORIZONTAL, Rail.CROSS, Rail.BOTTOM_LEFT, Rail.TOP_LEFT]
			elif _direction == Travel.LOW and _axis == Axis.VERTICAL:
				return to in [Rail.VERTICAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.BOTTOM_LEFT]
		Rail.CROSS:
			if _direction == Travel.HIGH:
				if _axis == Axis.HORIZONTAL:
					return to in [Rail.HORIZONTAL, Rail.CROSS, Rail.BOTTOM_LEFT, Rail.TOP_LEFT]
				return to in [Rail.VERTICAL, Rail.CROSS, Rail.TOP_RIGHT, Rail.TOP_LEFT]
			else:
				if _axis == Axis.HORIZONTAL:
					return to in [Rail.HORIZONTAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.TOP_RIGHT]
				return to in [Rail.VERTICAL, Rail.CROSS, Rail.BOTTOM_RIGHT, Rail.BOTTOM_LEFT]
	return false

func _UpdateCoords(skips : int) -> void:
	if skips < 1: return
	_corner_handled = false
	for i : int in range(skips):
		var from_rail : Rail = _GetRailAtCoord(_cur_coord)
		var ncoord = _cur_coord
		if _axis == Axis.HORIZONTAL:
			ncoord.x += _direction
		else: ncoord.y += _direction
		var rail : Rail = _GetRailAtCoord(ncoord)
		if not _RailNeighborValid(from_rail, rail):
			rail = Rail.NONE
		
		if rail == Rail.NONE:
			if _direction == Travel.LOW:
				path_completed_low.emit()
			else: path_completed_high.emit()
			path_completed.emit()
			
			_direction = _FlipDirection(_direction)
			_progress = 1.0 - _progress
		else:
			_cur_coord = ncoord
			if (i+1) < skips:
				_ProcessCornerFlip(rail)

func _PositionHorizontal() -> void:
	if map_layer == null or map_layer.tile_set == null: return
	var tile_size : Vector2i = map_layer.tile_set.tile_size
	var pos : Vector2 = map_layer.map_to_local(_cur_coord) - (tile_size * 0.5)
	var dist : float = float(tile_size.x) * _progress
	var npos = pos + Vector2(dist, floor(float(tile_size.y) * 0.5))
	position = npos

func _PositionVertical() -> void:
	if map_layer == null or map_layer.tile_set == null: return
	var tile_size : Vector2i = map_layer.tile_set.tile_size
	var pos : Vector2 = map_layer.map_to_local(_cur_coord) - (tile_size * 0.5)
	var dist : float = float(tile_size.y) * _progress
	var npos = pos + Vector2(floor(float(tile_size.x) * 0.5), dist)
	position = npos
