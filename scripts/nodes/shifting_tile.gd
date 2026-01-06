extends CharacterBody2D
class_name ShiftingTile


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal travel_completed()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var texture : Texture2D = null:			set=set_texture
@export var region : Rect2 = Rect2(0,0,0,0):	set=set_region

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _sprite : Sprite2D = null
var _collision : CollisionShape2D = null

var _tween : Tween = null
#var _cell_start_coord : Vector2i = Vector2i.ZERO
#var _cell_start_position : Vector2 = Vector2.ZERO
#var _cell_end_coord : Vector2i = Vector2i.ZERO
#var _cell_end_position : Vector2i = Vector2.ZERO
#var _cell_source_id : int = -1
#var _cell_atlas_coord : Vector2i = INVALID_COORD

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_texture(t : Texture2D) -> void:
	if _sprite == null:
		texture = t
		_Build()

func set_region(r : Rect2) -> void:
	if _sprite == null:
		region = r
		_Build()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	_Build()

func _exit_tree() -> void:
	if _sprite != null:
		remove_child(_sprite)
		_sprite.queue_free()
	if _collision != null:
		remove_child(_collision)
		_collision.queue_free()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Build() -> void:
	if _sprite != null: return
	if texture == null: return
	if not region.has_area(): return
	if region.position.x < 0.0 or region.position.y < 0.0: return
	
	_sprite = Sprite2D.new()
	_sprite.texture = texture
	_sprite.region_enabled = true
	_sprite.region_rect = region
	_sprite.centered = false
	add_child(_sprite)
	
	var coll_shape : RectangleShape2D = RectangleShape2D.new()
	coll_shape.size = region.size
	_collision = CollisionShape2D.new()
	_collision.shape = coll_shape
	add_child(_collision)
	_collision.position = region.size * 0.5
	

#func _GetParent() -> TileMapLayer:
	#var parent : Node = get_parent()
	#if parent is TileMapLayer:
		#return parent
	#return null
#
#func _Build() -> void:
	#if _sprite != null: return
	#
	#var parent : TileMapLayer = _GetParent()
	#if parent == null:
		#printerr("Failed to find TileMapLayer parent.")
		#return
	#
	#if parent.tile_set == null:
		#printerr("Parent TileMapLayer missing TileSet.")
		#return
	#
	#_cell_source_id = parent.get_cell_source_id(_cell_start_coord)
	#if _cell_source_id < 0:
		#printerr("No cell found at coords: ", _cell_start_coord)
		#return
	#_cell_start_position = parent.map_to_local(_cell_start_coord)
	#_cell_end_position = parent.map_to_local(_cell_end_coord)
	#
	#var tile_source : TileSetSource = parent.tile_set.get_source(_cell_source_id)
	#if not tile_source is TileSetAtlasSource:
		#printerr("Tile at ", _cell_start_coord, " not a valid atlas texture tile.")
		#return
	#
	#_cell_atlas_coord = parent.get_cell_atlas_coords(_cell_start_coord)
	#if _cell_atlas_coord == INVALID_COORD:
		#printerr("Failed to find tile atlas coords.")
		#return
	#
	#_sprite = Sprite2D.new()
	#add_child(_sprite)
	#_sprite.texture = tile_source.get_runtime_texture()
	#_sprite.region_enabled = true
	#_sprite.region_rect = tile_source.get_tile_texture_region(_cell_atlas_coord)
	#_sprite.centered = false
	#
	#var coll_shape : RectangleShape2D = RectangleShape2D.new()
	#coll_shape.size = Vector2(parent.tile_set.tile_size)
	#var coll : CollisionShape2D = CollisionShape2D.new()
	#coll.shape = coll_shape
	#add_child(coll)
	#coll.position = coll_shape.size * 0.5
	
	

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
#func initialize(from_coord : Vector2i, to_coord : Vector2i) -> void:
	#if _sprite != null or from_coord == to_coord: return
	#_cell_start_coord = from_coord
	#_cell_end_coord = to_coord
	#_Build()

func travel(from : Vector2, to : Vector2) -> void:
	if _tween != null: return
	
	# TODO:
	#   * Calculate the travel tweens
	#   * Upon tween completion, emit completion
	#   * Free self
