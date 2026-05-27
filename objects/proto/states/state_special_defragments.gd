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
@export_subgroup("States")
@export var state_idle : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _spread_angle : float = 0.0
var _current_angle : float = 0.0
var _blocks_spawned : int = 0

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
func _GetTarget() -> Node2D:
	var mobs : Array[Node] = get_tree().get_nodes_in_group(Game.GROUP_MOB)
	mobs = mobs.filter(
		func(item : Node):
			return item is Node2D and not item.name in _tagged_enemies
	)
	if mobs.size() > 0:
		var idx : int = 0
		if mobs.size() > 1:
			idx = randi_range(0, mobs.size() - 1)
		_tagged_enemies[mobs[idx].name] = true
		return mobs[idx]
	return null


func _SpawnBlock() -> void:
	var target : Node2D = _GetTarget()
	if target == null:
		_EndSpecial.call_deferred()
		return
	
	var ds : DEFRAGMENT_SPAWNER = DEFRAGMENT_SPAWNER_SCENE.instantiate()
	
	var pos : Vector2i = Vector2i(actor.global_position) + pixel_offset
	pos += Vector2i((Vector2.RIGHT * pixel_radius).rotated(_current_angle))
	
	if ds != null:
		var parent : Node = actor.get_parent()
		if not parent is Node2D: return
		parent.add_child(ds)
		ds.global_position = Vector2(pos)
		ds.spawn_completed.connect(_on_spawn_completed)
		_blocks_spawned += 1
	_current_angle += _spread_angle

func _EndSpecial() -> void:
	_blocks_spawned = block_count
	if not state_idle.is_empty():
		swap_to(state_idle)
	else: printerr("Proto State Special Defragments missing idle state name")

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(_payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	
	_blocks_spawned = 0
	_current_angle = 0.0
	if _spread_angle <= 0.0:
		set_block_count(block_count)
	# TODO: Instead of _SpawnBlock(), maybe run a special player animation and have
	#   _SpawnBlock() get called when that animation finishes.
	_SpawnBlock()

func exit() -> void:
	_tagged_enemies.clear()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_spawn_completed() -> void:
	if _blocks_spawned < block_count:
		_SpawnBlock.call_deferred()
	else: _EndSpecial()
