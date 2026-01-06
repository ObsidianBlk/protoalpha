extends Node
class_name ShiftManager


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const INVALID_ATLAS_COORD : Vector2i = Vector2i(-1, -1)

const CUSTOM_DATA_LAYER_NAME : String = "Shiftable"
const CUSTOM_DATA_LAYER_TYPE : int = TYPE_BOOL

# ------------------------------------------------------------------------------
# Classes
# ------------------------------------------------------------------------------
class ShiftableData extends RefCounted:
	var source_id : int = -1:								set=set_source_id
	var atlas_coord : Vector2i = INVALID_ATLAS_COORD:		set=set_atlas_coord
	var node : ShiftingTile = null
	
	func set_source_id(id : int) -> void:
		if node != null: return
		if id < 0: id = -1
		if id != source_id:
			source_id = id
	
	func set_atlas_coord(a : Vector2i) -> void:
		if node != null: return
		if a.x < 0 or a.y < 0:
			a = INVALID_ATLAS_COORD
		if a != atlas_coord:
			atlas_coord = a
	
	func _init(id : int = -1, coord : Vector2i = INVALID_ATLAS_COORD) -> void:
		source_id = id
		atlas_coord = coord
	
	func is_valid() -> bool:
		return source_id >= 0 and atlas_coord != INVALID_ATLAS_COORD

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var tilemap : TileMapLayer = null:			set=set_tilemap

@export_subgroup("Blank Tile", "blank_")
@export var blank_source_id : int = -1
@export var blank_atlas_coord : Vector2i = INVALID_ATLAS_COORD


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
# Custom Data Layer ID
var _cdlid : int = -1

var _shiftables : Dictionary[Vector2i, ShiftableData] = {}

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_tilemap(map : TileMapLayer) -> void:
	if map != tilemap:
		if map != null:
			if map.tile_set == null:
				printerr("Failed to set TileMapLayer, missing TileSet")
				return
			var cdlid : int = map.tile_set.get_custom_data_layer_by_name(CUSTOM_DATA_LAYER_NAME)
			if  cdlid < 0:
				printerr("TileMapLayer TileSet missing required custom data layer.")
				return
			if map.tile_set.get_custom_data_layer_type(cdlid) != CUSTOM_DATA_LAYER_TYPE:
				printerr("TileMapLayer TileSet expected custom data layer of invalid data type.")
				return
			_cdlid = cdlid
		if tilemap != null:
			_ResetTilemap()
		
		tilemap = map
		_ScanShiftableTiles()


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ResetTilemap() -> void:
	if tilemap == null: return
	for coord : Vector2i in _shiftables.keys():
		var data : ShiftableData = _shiftables[coord]
		if data.node != null:
			# TODO: Disconnect the travel_completed signal
			data.node.queue_free()
			data.node = null
		if data.is_valid():
			tilemap.set_cell(coord, data.source_id, data.atlas_coord)

func _ScanShiftableTiles() -> void:
	if tilemap == null: return
	_shiftables.clear()
	var used : Array[Vector2i] = tilemap.get_used_cells()
	for coord : Vector2i in used:
		var tdata : TileData = tilemap.get_cell_tile_data(coord)
		if tdata.has_custom_data(CUSTOM_DATA_LAYER_NAME):
			var source_id : int = tilemap.get_cell_source_id(coord)
			var atlas_coord : Vector2i = tilemap.get_cell_atlas_coords(coord)
			_shiftables[coord] = ShiftableData.new(source_id, atlas_coord)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
