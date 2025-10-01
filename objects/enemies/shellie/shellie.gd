@tool
extends CharacterBody2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
enum ActionState {WALK=0, COVER=1, REVEAL=2}
enum MobFacing {LEFT=-1, RIGHT=1}

const ANIM_REVEAL : String = "reveal"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(1, 16) var speed : int = 8
@export_enum("TOP:1", "BOTTOM:-1") var orientation : int = 1:	set=set_orientation
@export var facing : MobFacing = MobFacing.RIGHT:				set=set_facing

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : ActionState = ActionState.WALK

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ground_rays: Node2D = %GroundRays
@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _ray_ground_l: RayCast2D = %RayGroundL
@onready var _ray_ground_r: RayCast2D = %RayGroundR


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_orientation(o : int) -> void:
	if o in [-1,1] and o != orientation:
		orientation = o
		if _ground_rays != null:
			_ground_rays.scale.y = orientation
		if _sprite != null:
			_sprite.flip_v = orientation == -1

func set_facing(f : MobFacing) -> void:
	if f != facing:
		facing = f
		if _sprite != null:
			_sprite.flip_h = facing == MobFacing.LEFT

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ground_rays.scale.y = orientation
	_sprite.flip_v = orientation == -1
	_sprite.flip_h = facing == MobFacing.LEFT

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	match _state:
		ActionState.WALK:
			velocity = Vector2(float(speed) * facing, 0.0)
			move_and_slide()
			
			var coll_count : int = get_slide_collision_count()
			var eop : bool = _EdgeOfPlatform()
			if coll_count > 1 or eop:
				if facing == MobFacing.LEFT:
					facing = MobFacing.RIGHT
				else: facing = MobFacing.LEFT

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _EdgeOfPlatform() -> bool:
	if _sprite != null:
		if _sprite.flip_h:
			if _ray_ground_l != null:
				return not _ray_ground_l.is_colliding()
		else:
			if _ray_ground_r != null:
				return not _ray_ground_r.is_colliding()
	return false
