@tool
extends Node2D
class_name PickupSpawner


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _DRAW_COLOR : Color = Color.CORNFLOWER_BLUE

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The [MapSegment] this [PickupSpawner] will listen to for player entery and
## exit.[br][br]
## NOTE: If no [MapSegment] is explicitly defined, will automatically check if
## the direct parent is a [MapSegment] and use the parent if true.
@export var segment : MapSegment = null:							set=set_segment
## A [WeightedPickupCollection] defining what pickups can be spawned.
@export var pickup_collection : WeightedPickupCollection = null
## If [code]true[/code] this [PickupSpawner] will only activate one time
## after the level loads. If [code]false[/code] [i](default)[/i] spawner will
## activate every time player enters the assigned [property segment].
@export var once_per_level : bool = false
## If [code]true[/code] a new pickup will be spawned some time after the
## previous pickup is collected. If [code]false[/code] [i](default)[/i] spawner
## only spawns once.
@export var continuous : bool = false:								set=set_continuous
## The amount of time, in seconds, after a previous pickup is spawned before a new
## pickup is spawned. If [property continuous] is [code]false[/code] this property
## has no effect.
@export var spawn_delay : float = 0.0:								set=set_spawn_delay


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _spawned_this_level : bool = false
var _spawn_delay : float = 0.0
var _current_pickup : PickupBody2D = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_segment(s : MapSegment) -> void:
	if s != segment:
		_DisconnectSegment()
		segment = s
		_ConnectSegment()

func set_continuous(c : bool) -> void:
	if c != continuous:
		continuous = c
		# TODO: Other things

func set_spawn_delay(sd : float) -> void:
	if sd >= 0.0:
		spawn_delay = sd

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint(): return
	if segment == null:
		var parent : Node = get_parent()
		if parent is MapSegment:
			segment = parent
		else: printerr("PickupSpawner not assigned to a MapSegment")
	if segment != null:
		_ConnectSegment()
		if segment.player_in_segment():
			set_process(true)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	draw_circle(Vector2.ZERO, 4, _DRAW_COLOR, true)

func _process(delta: float) -> void:
	if spawn_delay > 0.0:
		spawn_delay -= delta
	else:
		set_process(false)
		_Spawn()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSegment() -> void:
	if segment == null: return
	if not segment.entered.is_connected(_on_segment_entered):
		segment.entered.connect(_on_segment_entered)
	if not segment.exited.is_connected(_on_segment_exited):
		segment.exited.connect(_on_segment_exited)

func _DisconnectSegment() -> void:
	if segment == null: return
	if segment.entered.is_connected(_on_segment_entered):
		segment.entered.disconnect(_on_segment_entered)
	if segment.exited.is_connected(_on_segment_exited):
		segment.exited.disconnect(_on_segment_exited)

func _GetRandomPickup() -> PickupBody2D:
	if pickup_collection != null:
		var id : StringName = pickup_collection.rand_item()
		if not Game.PICKUP_LUT[id].is_empty():
			var scene : PackedScene = load(Game.PICKUP_LUT[id])
			if scene != null:
				var pickup : Node = scene.instantiate()
				if pickup is PickupBody2D:
					return pickup
	return null

func _Spawn() -> void:
	if once_per_level and _spawned_this_level: return
	if _current_pickup != null: return
	
	var pickup = _GetRandomPickup()
	if pickup == null: return
	add_child(pickup)
	pickup.lifetime = 0.0
	pickup.velocity.y = -100
	pickup.global_position = global_position
	pickup.tree_exited.connect(_on_pickup_exited_tree, CONNECT_ONE_SHOT)
	_current_pickup = pickup
	_spawned_this_level = true

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_segment_entered() -> void:
	if not (_spawned_this_level and once_per_level):
		_spawn_delay = 0.0
		set_process(true)

func _on_segment_exited() -> void:
	if _current_pickup != null:
		_current_pickup.queue_free()
	set_process(false)

func _on_pickup_exited_tree() -> void:
	_current_pickup = null
	if not once_per_level and continuous:
		set_process(true)
		_spawn_delay = spawn_delay
