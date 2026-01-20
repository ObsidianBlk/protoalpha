@tool
extends Node2D
class_name ShiftManager


# TODO:
#	1) Finish for One-Tile-to-Slot shifts.
#   2) Define a sub-region from which to pull the shiftables tiles
#   3) Figure out a method to triggering this as a "weapon"

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const INVALID_ATLAS_COORD : Vector2i = Vector2i(-1, -1)

const SHIFTABLE_DATA_LAYER_NAME : String = "Shiftable"
const SLOT_DATA_LAYER_NAME : String = "ShiftableSlot"
const CUSTOM_DATA_LAYER_TYPE : int = TYPE_BOOL

# ------------------------------------------------------------------------------
# Classes
# ------------------------------------------------------------------------------
class ShiftableData extends RefCounted:
	var tile_set : TileSet:									set=set_tile_set, get=get_tile_set
	var source_id : int = -1:								set=set_source_id
	var atlas_coord : Vector2i = INVALID_ATLAS_COORD:		set=set_atlas_coord
	
	var _tile_set : WeakRef = weakref(null)
	
	func set_source_id(id : int) -> void:
		if id < 0: id = -1
		if id != source_id:
			source_id = id
	
	func set_atlas_coord(a : Vector2i) -> void:
		if a.x < 0 or a.y < 0:
			a = INVALID_ATLAS_COORD
		if a != atlas_coord:
			atlas_coord = a
	
	func set_tile_set(ts : TileSet) -> void:
		_tile_set = weakref(ts)
	
	func get_tile_set() -> TileSet:
		return _tile_set.get_ref()
	
	func _init(tileset : TileSet = null, id : int = -1, coord : Vector2i = INVALID_ATLAS_COORD) -> void:
		_tile_set = weakref(tileset)
		source_id = id
		atlas_coord = coord
	
	func is_valid() -> bool:
		return tile_set != null and source_id >= 0 and atlas_coord != INVALID_ATLAS_COORD
	
	func get_data_layer_id() -> int:
		if is_valid():
			var ts : TileSet = tile_set
			var source : TileSetSource = ts.get_source(source_id)
			if source is TileSetAtlasSource:
				var tdata : TileData = source.get_tile_data(atlas_coord, 0)
				if tdata != null:
					var val : Variant = tdata.get_custom_data(SHIFTABLE_DATA_LAYER_NAME)
					if typeof(val) == TYPE_BOOL and val == true:
						return ts.get_custom_data_layer_by_name(SHIFTABLE_DATA_LAYER_NAME)
					
					val = tdata.get_custom_data(SLOT_DATA_LAYER_NAME)
					if typeof(val) == TYPE_BOOL and val == true:
						return ts.get_custom_data_layer_by_name(SLOT_DATA_LAYER_NAME)
		return -1
	
	func clone() -> ShiftableData:
		return ShiftableData.new(tile_set, source_id, atlas_coord)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## [TileMapLayer] in which to find shiftable tiles.
@export var tilemap : TileMapLayer = null:			set=set_tilemap

@export_subgroup("Sub Region", "subregion_")
@export var subregion_whole_tilemap : bool = false:			set=set_subregion_whole_tilemap
@export var subregion_region : Rect2i = Rect2i(0,0,0,0):	set=set_subregion_region

@export_subgroup("Spawn Rate", "spawn_")
## The maximum number of shiftable tiles that can be active at any time.
@export var spawn_maximum : int = 1
## The number of shiftable tiles to be spawned per heartbeat.[br]
## NOTE: May not always spawn this number depending on current number of already
## spawned shiftable tiles.
@export var spawn_count_per_heartbeat : int = 1
## The amount of time (in seconds) between each shiftable tile spawn
@export var spawn_heartbeat : float = 1.0
## The variance in time for each heartbeat.[br]
## Example:
## [codeblock]
## variance = heartbeat * hearbeat_variance
## actual_heartbeat = heartbeat + randf_range(-variance, variance)
## [/codeblock]
@export_range(0.0, 1.0) var spawn_heartbeat_variance : float = 0.2
## The amount of time (in seconds) before the first heartbeat
@export var spawn_delay_from_start : float = 0.0
@export var spawn_speed_pps : int = 20
@export var spawn_speed_variance : float = 0.25


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
# Shiftable Tile Data Layer ID
var _shiftable_dlid : int = -1
# Slot Tile Data Layer ID
var _slot_dlid : int = -1

var _slot_tile : ShiftableData = null

var _original : Dictionary[Vector2i, ShiftableData] = {}
var _available : Dictionary[Vector2i, ShiftableData] = {}
var _active : Array[ShiftingTile] = []

var _heartbeat : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_tilemap(map : TileMapLayer) -> void:
	if map != tilemap:
		if map != null:
			if map.tile_set == null:
				printerr("Failed to set TileMapLayer, missing TileSet")
				return
			
			var shiftableid : int = _GetTileSetDataLayerID(map.tile_set, SHIFTABLE_DATA_LAYER_NAME, CUSTOM_DATA_LAYER_TYPE)
			if  shiftableid < 0:
				printerr("TileMapLayer TileSet missing required custom data layer or data layer type invalid.")
				return
			
			var slotid : int = _GetTileSetDataLayerID(map.tile_set, SLOT_DATA_LAYER_NAME, CUSTOM_DATA_LAYER_TYPE)
			if slotid < 0:
				printerr("TileMapLayer TileSet missing required custom data layer or data layer type invalid.")
				return
			
			_shiftable_dlid = shiftableid
			_slot_dlid = slotid
		if tilemap != null:
			_ResetTilemap()
		
		tilemap = map
		
		if tilemap != null:
			if subregion_whole_tilemap or not subregion_region.has_area():
				var whole : bool = subregion_whole_tilemap
				subregion_whole_tilemap = false
				subregion_region = tilemap.get_used_rect()
				subregion_whole_tilemap = whole
			queue_redraw()
		
		_slot_tile = _GetSlotShiftableData(map.tile_set, _slot_dlid)
		#_ScanTiles()

func set_subregion_whole_tilemap(w : bool) -> void:
	if w != subregion_whole_tilemap:
		if w and tilemap != null:
			subregion_region = tilemap.get_used_rect()
		subregion_whole_tilemap = w

func set_subregion_region(r : Rect2) -> void:
	if subregion_whole_tilemap: return
	if r.has_area():
		subregion_region = r
		if tilemap != null:
			queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if tilemap == null:
		var tm : TileMapLayer = _GetTileMapParent()
		if tm != null:
			tilemap = tm
	set_process(false)

func _draw() -> void:
	if not Engine.is_editor_hint() or tilemap == null: return
	
	var tile_size : Vector2 = Vector2(tilemap.tile_set.tile_size)
	var hts : Vector2 = tile_size * 0.5
	var region_position : Vector2 = tilemap.map_to_local(subregion_region.position) - hts
	var region_size : Vector2 = (Vector2(subregion_region.size) * tile_size)
	var region : Rect2 = Rect2(
		region_position,
		region_size
	)
	
	var color : Color = Color.AQUA
	color.a = 0.5
	draw_rect(region, color, true)
	draw_rect(region, Color.AQUA, false, 1.0)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_heartbeat -= delta
	if _heartbeat <= 0.0:
		var variance : float = spawn_heartbeat * spawn_heartbeat_variance
		_heartbeat = spawn_heartbeat + randf_range(-variance, variance)
		
		_Spawn.call_deferred(spawn_count_per_heartbeat)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetTileMapParent() -> TileMapLayer:
	var parent : Node = get_parent()
	if parent is TileMapLayer:
		return parent
	return null

func _GetTileSetDataLayerID(tile_set : TileSet, layer_name : String, layer_data_type : int) -> int:
	if tile_set != null:
		var id : int = tile_set.get_custom_data_layer_by_name(layer_name)
		if id >= 0 and tile_set.get_custom_data_layer_type(id) == layer_data_type:
			return id
	return -1

func _GetSlotShiftableData(tile_set : TileSet, data_layer_id : int) -> ShiftableData:
	if tile_set != null:
		for source_idx : int in range(tile_set.get_source_count()):
			var source_id : int = tile_set.get_source_id(source_idx)
			if source_id < 0: continue
			var source : TileSetSource = tile_set.get_source(source_id)
			if source is TileSetAtlasSource:
				var atlas_grid : Vector2i = source.get_atlas_grid_size()
				for y : int in range(atlas_grid.y):
					for x : int in range(atlas_grid.x):
						var acoord : Vector2i = Vector2i(x,y)
						if not source.has_tile(acoord): continue
						
						var tdata : TileData = source.get_tile_data(acoord, 0)
						if tdata == null: continue
						
						if tdata.get_custom_data_by_layer_id(data_layer_id) == true:
							return ShiftableData.new(tile_set, source_id, acoord)
	return null

func _GetAvailableSlots() -> Array[Vector2i]:
	return _available.keys().filter(
		func(coord : Vector2i):
			return _available[coord].get_data_layer_id() == _slot_dlid
	)

func _GetAvailableShiftables() -> Array[Vector2i]:
	return _available.keys().filter(
		func(coord : Vector2i):
			return _available[coord].get_data_layer_id() == _shiftable_dlid
	)

func _DropActive() -> void:
	for active : ShiftingTile in _active:
		for sig_info : Dictionary in active.travel_completed.get_connections():
			active.travel_completed.disconnect(sig_info.callable)
		active.queue_free()
	_active.clear()

func _ResetTilemap(ignore_set_cell : bool = false) -> void:
	if tilemap == null: return
	_available.clear()
	_DropActive()
	for coord : Vector2i in _original.keys():
		var data : ShiftableData = _original[coord]
		if data.is_valid() and not ignore_set_cell:
			tilemap.set_cell(coord, data.source_id, data.atlas_coord)
		_available[coord] = _original[coord].clone()
	_heartbeat = spawn_delay_from_start

func _ScanTiles() -> void:
	if tilemap == null: return
	_available.clear()
	_original.clear()
	
	#_shiftables.clear()
	var used : Array[Vector2i] = tilemap.get_used_cells()
	for coord : Vector2i in used:
		if not subregion_region.has_point(coord): continue
		var tdata : TileData = tilemap.get_cell_tile_data(coord)
		if tdata.has_custom_data(SHIFTABLE_DATA_LAYER_NAME) or tdata.has_custom_data(SLOT_DATA_LAYER_NAME):
			if tdata.get_custom_data(SHIFTABLE_DATA_LAYER_NAME) or tdata.get_custom_data(SLOT_DATA_LAYER_NAME):
				var source_id : int = tilemap.get_cell_source_id(coord)
				var atlas_coord : Vector2i = tilemap.get_cell_atlas_coords(coord)
				_original[coord] = ShiftableData.new(tilemap.tile_set, source_id, atlas_coord)
	_ResetTilemap(true)

func _GenerateShiftableSpeed() -> int:
	var variance : int = floor(float(spawn_speed_pps) * spawn_speed_variance)
	return spawn_speed_pps + randi_range(-variance, variance)

func _SpawnShiftable(from_coord : Vector2i, to_coord : Vector2i) -> void:
	if tilemap == null or tilemap.tile_set == null: return
	var atlas_coord : Vector2i = tilemap.get_cell_atlas_coords(from_coord)
	var source_id : int = tilemap.get_cell_source_id(from_coord)
	var source : TileSetSource = tilemap.tile_set.get_source(source_id)
	if source is TileSetAtlasSource:
		var texture : Texture2D = source.get_runtime_texture()
		#var region : Rect2i = source.get_tile_texture_region(atlas_coord)
		var region : Rect2i = source.get_runtime_tile_texture_region(atlas_coord, 0)
		var st : ShiftingTile = ShiftingTile.new()
		st.texture = texture
		st.region = region
		st.speed_pps = _GenerateShiftableSpeed()
		tilemap.add_child(st)
		st.travel_completed.connect(
			_on_shifting_tile_travel_complete.bind(st, to_coord, source_id, atlas_coord)
		)
		st.travel.call_deferred(
			tilemap.map_to_local(from_coord),
			tilemap.map_to_local(to_coord)
		)
		_active.append(st)

func _Spawn(count : int) -> void:
	var total_space : int = spawn_maximum - _active.size()
	if total_space <= 0: return
	
	var shiftables : Array[Vector2i] = _GetAvailableShiftables()
	var slots : Array[Vector2i] = _GetAvailableSlots()
	
	while count > 0:
		if slots.size() <= 0:
			if count >= 2 and total_space >= 2 and shiftables.size() >= 2:
				var idx_a : int = randi_range(0, shiftables.size() - 1)
				var coord_a : Vector2i = shiftables[idx_a]
				shiftables.remove_at(idx_a)
				_available.erase(coord_a)
				
				var idx_b : int = randi_range(0, shiftables.size() - 1)
				var coord_b : Vector2i = shiftables[idx_b]
				shiftables.remove_at(idx_b)
				_available.erase(coord_b)
				
				_SpawnShiftable(coord_a, coord_b)
				_SpawnShiftable(coord_b, coord_a)
				
				# NOTE: We do NOT add an "available" slot to the list
				#  as the Shiftables are swapping with each other
				if _slot_tile != null:
					tilemap.set_cell(coord_a, _slot_tile.source_id, _slot_tile.atlas_coord)
					tilemap.set_cell(coord_b, _slot_tile.source_id, _slot_tile.atlas_coord)
				
				count -= 2
				total_space -= 2
			else: count = 0 # Kicks out of the while loop
		elif shiftables.size() > 0:
			var shift_idx : int = randi_range(0, shiftables.size() - 1)
			var from_coord : Vector2i = shiftables[shift_idx]
			shiftables.remove_at(shift_idx)
			_available.erase(from_coord)
			
			var slot_idx : int = randi_range(0, slots.size() - 1)
			var to_coord : Vector2i = slots[slot_idx]
			slots.remove_at(slot_idx)
			_available.erase(to_coord)
			
			_SpawnShiftable(from_coord, to_coord)
			_available[from_coord] = ShiftableData.new(tilemap.tile_set, _slot_tile.source_id, _slot_tile.atlas_coord)
			tilemap.set_cell(from_coord, _slot_tile.source_id, _slot_tile.atlas_coord)
		else: count = 0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func start() -> void:
	if Engine.is_editor_hint(): return
	_ScanTiles()
	_heartbeat = spawn_delay_from_start
	set_process(true)

func stop() -> void:
	if Engine.is_editor_hint(): return
	set_process(false)
	_ResetTilemap()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_shifting_tile_travel_complete(st : ShiftingTile, dst_coord : Vector2i, dst_source_id : int, dst_atlas_coords : Vector2i) -> void:
	if st == null or tilemap == null: return
	tilemap.set_cell(dst_coord, dst_source_id, dst_atlas_coords)
	_available[dst_coord] = ShiftableData.new(tilemap.tile_set, dst_source_id, dst_atlas_coords)
	var idx : int = _active.find(st)
	if idx >= 0:
		_active.remove_at(idx)
	st.queue_free()
