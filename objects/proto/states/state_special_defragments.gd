extends ProtoState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFRAGMENT_SPAWNER_SCENE : PackedScene = preload("uid://dtab04a5nwp4q")
const DEFRAGMENT_SPAWNER : GDScript = preload("uid://bclau2mbtwi7w")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var block_count : int = 5:			set=set_block_count
@export var pixel_radius : int = 24
@export var pixel_offset : Vector2i = Vector2i.ZERO
@export var spawn_delay : float = 0.2
@export_subgroup("Components")
@export var hitbox : HitBox = null
@export_subgroup("States")
@export var state_idle : StringName = &""
@export var state_move : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _spread_angle : float = 0.0
var _current_angle : float = 0.0
var _blocks_spawned : int = 0

var _delay : float = 0.0
var _tagged_enemies : Dictionary[StringName, bool] = {}


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_block_count(c : int) -> void:
	c = clampi(c, 1, 10)
	block_count = c
	_spread_angle = deg_to_rad(180.0 / float(block_count))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetRandomFromGroup(group_name : StringName, tag : bool) -> Node2D:
	var mobs : Array[Node] = get_tree().get_nodes_in_group(group_name)
	mobs = mobs.filter(
		func(item : Node):
			if item is Node2D:
				return not (tag and item.name in _tagged_enemies)
	)
	
	if mobs.size() > 0:
		var idx : int = 0
		if mobs.size() > 1:
			idx = randi_range(0, mobs.size() - 1)
		if tag:
			_tagged_enemies[mobs[idx].name] = true
		return mobs[idx]
	return null

func _GetTarget() -> Node2D:
	var target : Node2D = _GetRandomFromGroup(Game.GROUP_MOB, true)
	if target != null: return target
	return _GetRandomFromGroup(Game.GROUP_BOSS, false)


func _SpawnBlock() -> void:
	var parent : Node = actor.get_parent()
	var target : Node2D = _GetTarget()
	if target == null or not parent is Node2D:
		_EndSpecial.call_deferred()
		return
	
	var ds : DEFRAGMENT_SPAWNER = DEFRAGMENT_SPAWNER_SCENE.instantiate()
	
	var pos : Vector2i = Vector2i(actor.global_position) + pixel_offset
	pos += Vector2i((Vector2.RIGHT * pixel_radius).rotated(_current_angle))
	
	if ds != null:
		parent.add_child(ds)
		ds.global_position = Vector2(pos)
		ds.set_target(target)
		_blocks_spawned += 1
	_current_angle -= _spread_angle

func _EndSpecial() -> void:
	_blocks_spawned = block_count
	if is_equal_approx(actor.velocity.x, 0.0):
		swap_to(state_idle)
	else: swap_to(state_move)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(_payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	actor.set_tree_param(APARAM_TRANSITION, TRANS_DEFRAGMENT)
	
	_blocks_spawned = 0
	_current_angle = 0.0
	_delay = 0.001
	if _spread_angle <= 0.0:
		set_block_count(block_count)
	if hitbox != null:
		hitbox.disable_hitbox(true)
	# TODO: Special player animation??

func exit() -> void:
	actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
	if hitbox != null:
		hitbox.disable_hitbox(false)
	_tagged_enemies.clear()

func update(delta : float) -> void:
	if _delay > 0.0 and _blocks_spawned < block_count:
		_delay -= delta
		if _delay <= 0.0:
			_SpawnBlock()
			_delay = spawn_delay
			if _blocks_spawned == block_count:
				_EndSpecial()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
