@tool
extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _BLOCK_VISIBLE : float = 0.0
const _BLOCK_HIDDEN : float = 1.0
const _TRANSITION_DURATION : float = 0.5

const _PROJECTILE_BLOCK : PackedScene = preload("uid://d3t1ehcfyebug")


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var projectile_container : Node2D = null
@export var tile_coord : Vector2i = Vector2i.ZERO:		set=set_tile_coord
@export_flags_2d_physics var collision_mask : int = 1

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _progress : float = _BLOCK_HIDDEN:			set=_set_progress
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _block_sprite: SpriteTile2D = %BlockSprite


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_tile_coord(c : Vector2i) -> void:
	if tile_coord != c:
		tile_coord = c
		if _block_sprite != null:
			_block_sprite.coord = tile_coord

func _set_progress(p : float) -> void:
	p = clampf(p, 0.0, 1.0)
	if not is_equal_approx(_progress, p):
		_progress = p
		_UpdateBlockProgress()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	add_to_group(Game.GROUP_BOSS_MAP_WEAPON)
	_block_sprite.coord = tile_coord
	if Engine.is_editor_hint():
		_progress = _BLOCK_VISIBLE
	else:
		_UpdateBlockProgress()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _PreFire() -> void:
	if _tween != null: return
	print("Prefire Tweening")
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "_progress", _BLOCK_VISIBLE, _TRANSITION_DURATION)
	await _tween.finished
	_tween = null
	_progress = _BLOCK_HIDDEN

func _SpawnProjectile(direction : Vector2) -> void:
	print("Spawning Block Projectile")
	var pb : Projectile = _PROJECTILE_BLOCK.instantiate()
	if pb == null: return
	projectile_container.add_child(pb)
	pb.global_position = global_position
	pb.collision_mask = collision_mask
	pb.angle = rad_to_deg(direction.angle())
	pb.tile_coord = tile_coord

func _UpdateBlockProgress() -> void:
	if _block_sprite == null: return
	if _block_sprite.material is ShaderMaterial:
		var mat : ShaderMaterial = _block_sprite.material
		mat.set_shader_parameter(&"progress", _progress)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func fire_at(direction : Vector2) -> void:
	if Engine.is_editor_hint(): return
	if _tween != null or projectile_container == null: return
	direction = direction.normalized()
	print("Shooting in direction: ", direction)
	if direction.length_squared() >= 1.0:
		await _PreFire()
		_SpawnProjectile(direction)

func shoot_target(target : Node2D) -> void:
	if _tween == null and target != null:
		print("Shooting Target: ", target.name)
		var direction : Vector2 = global_position.direction_to(target.global_position)
		fire_at(direction)
