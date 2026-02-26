@tool
extends Projectile

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const EXPLOSION : PackedScene = preload("uid://nj2tagnipopm")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var tile_coord : Vector2i = Vector2i.ZERO:			set=set_tile_coord


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite_tile: SpriteTile2D = %SpriteTile2D


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_tile_coord(c : Vector2i) -> void:
	if tile_coord != c:
		tile_coord = c
		if _sprite_tile != null:
			_sprite_tile.coord = tile_coord

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_sprite_tile.coord = tile_coord

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _projectile_exploded() -> void:
	if _sprite_tile != null:
		_sprite_tile.visible = false
	
	var parent : Node = get_parent()
	if parent is Node2D:
		var expl : Node = EXPLOSION.instantiate()
		if expl is GPUParticles2D:
			parent.add_child(expl)
			expl.global_position = global_position
			expl.emitting = true
		elif expl != null:
			expl.queue_free()
