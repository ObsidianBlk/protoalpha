extends CharacterActor2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const WALL_COLLISION_X_THRESHOLD : float = 0.001
const COLL_STATE_NORMAL : int = 0
const COLL_STATE_AIR : int = 1
const COLL_STATE_LEAP : int = 2

const COLL_VALUES : Dictionary[int, Array] = {
	COLL_STATE_NORMAL: [Vector2(-2, -5), 0.5 * PI],
	COLL_STATE_AIR: [Vector2(0, -13), 0.0],
	COLL_STATE_LEAP : [Vector2(-2, -10), 0.5 * PI]
}

const ANIM_DEATH : StringName = &"death"

const ONCE_FIRE : int = 1

const INTERRUPT_LEAP : String = "leap"
const INTERRUPT_LAND : String = "land"
const INTERRUPT_HURT : String = "hurt"
const INTERRUPT_DIE : String = "die"

const APARAM_ONCE_INTERRUPT : String = "parameters/interrupt/request"
const APARAM_TRANS_INTERRUPTS : String = "parameters/interrupts/transition_request"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 48.0
@export var jump : float = 40.0
@export var hunt_distance : float = 40.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _dead : bool = false
var _direction : Vector2 = Vector2.RIGHT

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _coll_shape: CollisionShape2D = %CollisionShape2D


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if is_on_surface():
		var player : CharacterActor2D = _GetPlayer()
		if player == null:
			_ProcessSearch(delta)
		else: _ProcessHunt(delta, player)
	else: _ProcessAir(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ProcessAir(_delta : float) -> void:
	var vec : Vector2 = Vector2(velocity.x, 0.0) + get_gravity()
	velocity = vec 
	move_and_slide()
	if _SlideWallCollisionOccured():
		_direction.x *= -1
		velocity.x *= -1

func _ProcessHunt(delta : float, player : CharacterActor2D) -> void:
	velocity = Vector2.ZERO

func _ProcessSearch(_delta : float) -> void:
	velocity = (_direction * speed) + get_gravity() 
	move_and_slide()
	if _SlideWallCollisionOccured():
		_direction.x *= -1

func _SlideWallCollisionOccured() -> bool:
	for idx : int in range(get_slide_collision_count()):
		var c : KinematicCollision2D = get_slide_collision(idx)
		if abs(c.get_normal().x) > WALL_COLLISION_X_THRESHOLD:
			return true
	return false

func _CastRay(to : Vector2) -> Dictionary:
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position, to
	)
	query.exclude = [self]
	return space_state.intersect_ray(query)


func _GetPlayer() -> CharacterActor2D:
	var player : CharacterActor2D = null
	var narr : Array[Node] = get_tree().get_nodes_in_group(Game.GROUP_PLAYER)
	for n : Node in narr:
		if n is CharacterActor2D:
			player = n
			break
	
	if player != null:
		var player_position_offset : Vector2 = Vector2.UP * 10
		var ray_result : Dictionary = _CastRay(player.global_position + player_position_offset)
		if not ray_result.is_empty() and ray_result.collider == player:
			var distance : float = global_position.distance_to(player.global_position)
			if distance <= hunt_distance:
				return player
	
	return null


func _Die() -> void:
	if not _dead:
		_dead = true
		set_physics_process(false)
		set_tree_param(APARAM_TRANS_INTERRUPTS, INTERRUPT_DIE)
		set_tree_param(APARAM_ONCE_INTERRUPT, ONCE_FIRE)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func flip(enable : bool) -> void:
	super.flip(enable)
	if _coll_shape != null:
		_coll_shape.position.x *= -1.0

func set_collision_state(state : int) -> void:
	match state:
		COLL_STATE_NORMAL, COLL_STATE_AIR, COLL_STATE_LEAP:
			_coll_shape.position = COLL_VALUES[state][0]
			_coll_shape.rotation = COLL_VALUES[state][1]

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_anim_tree_animation_finished(anim_name : StringName) -> void:
	super._on_anim_tree_animation_finished(anim_name)
	if anim_name == ANIM_DEATH:
		queue_free.call_deferred()

func _on_health_changed(health: int, max_health: int) -> void:
	if health <= 0:
		_Die()
