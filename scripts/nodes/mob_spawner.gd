@tool
extends Node2D
class_name MobSpawner

# TODO: Update pick-up spawns so they only spawn when a monster is killed by the
#  player... HA! Easy! (that's a lie)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _LUTKEY_WEIGHT : String = "weight"
const _LUTKEY_SCENE : String = "scene"


const _PICKUP_LUT : Dictionary[StringName, Dictionary] = {
	Game.PICKUP_NONE : {
		_LUTKEY_WEIGHT: 20.0,
		_LUTKEY_SCENE: null
	},
	Game.PICKUP_LIFE : {
		_LUTKEY_WEIGHT: 1.0,
		_LUTKEY_SCENE: preload("uid://bv3pmtfjy40p8")
	},
	Game.PICKUP_HEALTH : {
		_LUTKEY_WEIGHT:20.0,
		_LUTKEY_SCENE: preload("uid://ddd6ucx7yhx1u")
	},
	Game.PICKUP_HEALTH_LARGE : {
		_LUTKEY_WEIGHT:15.0,
		_LUTKEY_SCENE: preload("uid://baw6apsyn4rpx")
	},
}

const _MIN_DELAY : float = 0.0001

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The [MobInfo] resource defining what mob type to spawn from this [MobSpawner]
@export var mob_info : MobInfo = null:		set=set_mob_info
## The [MapSegment] node to listen for player to enter or exit.[br]
## Spawner will not spawn mobs until the player has entered the assigned [MapSegment].
## When a player leaves the assigned [MapSegment], all spawned mobs are freed.
@export var segment : MapSegment = null
## The [Node2D] in which to add the spawned mob(s)
@export var mob_container : Node2D = null
## Number of mobs spawned by the spawner.[br]
## If [property continuous] is [code]true[/code] spawner will wait to spawn
## additional mobs until one or more of it's existing mobs are killed.
@export var count : int = 1
## If [property continuous] is [code]true[/code], the time (in seconds) to wait
## between mob spawns.
@export var spawn_delay : float = 3.0
## The time (in seconds) after [MobSpawner] is active in which to start spawning.
@export var first_spawn_delay : float = 0.0
## Spawner always spawns up to [property count] number of mobs. If [code]true[/code]
## will continue to spawn more mobs up to [property count] as previous mobs are
## killed.
@export var continuous : bool = false
## If [code]true[/code] [MobSpawner] will actively spawn mobs even if not visible
## in the camera view.[br][br]
## [b]NOTE:[/b] Existing mobs will [i]not[/i] despawn when [MobSpawner] is out of view.
@export var active_outside_camera : bool = false
## If [code]true[/code] spawner is actively spawning.[br]
## [b]NOTE:[/b] Even if active is [code]false[/code] spawner will continue to track
## already spawned mobs.
@export var active : bool = true:			set=set_active
@export var verbose : bool = false


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
#var _segment_active : bool = false
var _spawned : int = 0
var _spawns : Array[Node2D] = []
var _delay : float = 0.0

var _pickup_collection : WeightedRandomCollection = WeightedRandomCollection.new()

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_mob_info(m : MobInfo) -> void:
	_DisconnectMobInfo()
	mob_info = m
	_ConnectMobInfo()
	queue_redraw()

func set_active(a : bool) -> void:
	if a != active:
		active = a
		if active:
			if is_physics_processing():
				## TODO: This first_spawn_delay code is kinda a hack
				##   and almost duplicated in the _on_segment_entered() code.
				##   Come up with a better solution? Maybe?
				if _spawned > 0 or first_spawn_delay <= 0.0:
					_SpawnMob()
				elif first_spawn_delay > 0.0:
					_delay = first_spawn_delay

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_BuildPickupCollection()
	set_physics_process(false)
	if segment == null:
		var parent : Node = get_parent()
		if parent is MapSegment:
			segment = parent
	if segment != null:
		segment.entered.connect(_on_segment_entered)
		segment.exited.connect(_on_segment_exited)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	if mob_info == null or mob_info.sprite_reference == null: return
	_draw_sprite_ref()
	_draw_editor_display()

func _physics_process(delta: float) -> void:
	if not _IsInCamera(): return
	if _delay > 0.0:
		_delay -= delta
		if _delay <= 0.0:
			_SpawnMob()


# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _draw_sprite_ref() -> void:
	var size : Vector2i = mob_info.sprite_reference.get_size()
	var pos : Vector2 = Vector2(-(size.x * 0.5), -size.y) + mob_info.sprite_offset
	draw_texture(mob_info.sprite_reference, pos)

func _draw_editor_display() -> void:
	pass

func _verify_mob(_mob : Node2D) -> bool:
	return true

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectMobInfo() -> void:
	if mob_info == null: return
	if not mob_info.changed.is_connected(_on_mob_info_changed):
		mob_info.changed.connect(_on_mob_info_changed)

func _DisconnectMobInfo() -> void:
	if mob_info == null: return
	if mob_info.changed.is_connected(_on_mob_info_changed):
		mob_info.changed.disconnect(_on_mob_info_changed)

func _BuildPickupCollection() -> void:
	_pickup_collection.clear()
	for key : StringName in _PICKUP_LUT.keys():
		_pickup_collection.add_entry(key, _PICKUP_LUT[key][_LUTKEY_WEIGHT])

func _GetRandomPickup() -> PickupBody2D:
	var id : Variant = _pickup_collection.get_random()
	if id in _PICKUP_LUT and _PICKUP_LUT[id][_LUTKEY_SCENE] is PackedScene:
		var scene : PackedScene = _PICKUP_LUT[id][_LUTKEY_SCENE]
		var pickup : Node = scene.instantiate()
		if pickup is PickupBody2D:
			return pickup
	return null

func _GetContainer() -> Node2D:
	if mob_container != null:
		return mob_container
	var parent : Node = get_parent()
	if parent is Node2D:
		return parent
	return null

func _SpawnMob() -> void:
	var has_mob : bool = mob_info != null and mob_info.mob_scene != null
	var true_active : bool = active and _IsInCamera()
	var container : Node2D = _GetContainer()
	if not (true_active and has_mob and container != null):
		_delay = _MIN_DELAY
		return
	
	if (_spawned < count and not continuous) or (continuous and _spawns.size() < count):
		var mob_instance : Node2D = mob_info.get_scene_instance()
		if mob_instance != null:
			if not _verify_mob(mob_instance):
				mob_instance.queue_free()
				return
			
			if not continuous:
				_spawned += 1
			mob_instance.tree_exiting.connect(_on_spawn_exiting_tree.bind(mob_instance))
			container.add_child(mob_instance)
			mob_instance.global_position = global_position
			_spawns.append(mob_instance)
			_delay = spawn_delay

func _SpawnPickup(pickup_position : Vector2) -> void:
	var container : Node2D = _GetContainer()
	if container == null: return
	
	var pickup = _GetRandomPickup()
	if pickup == null: return
	container.add_child(pickup)
	pickup.velocity.y = -100
	pickup.global_position = pickup_position

func _IsInCamera() -> bool:
	if active_outside_camera: return true
	return Game.Node_In_Camera_View(self)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_mob_info_changed() -> void:
	queue_redraw()

func _on_segment_entered() -> void:
	set_physics_process(true)
	if first_spawn_delay > 0.0:
		_delay = first_spawn_delay
	else:
		_SpawnMob.call_deferred()

func _on_segment_exited() -> void:
	set_physics_process(false)
	for spawn : Node2D in _spawns:
		if spawn.tree_exiting.is_connected(_on_spawn_exiting_tree.bind(spawn)):
			spawn.tree_exiting.disconnect(_on_spawn_exiting_tree.bind(spawn))
		spawn.queue_free()
	_spawns.clear()
	_spawned = 0

func _on_spawn_exiting_tree(spawn : Node2D) -> void:
	var idx : int = _spawns.find(spawn)
	if idx >= 0:
		_SpawnPickup.call_deferred(spawn.global_position)
		_spawns.remove_at(idx)
		if continuous:
			_delay = spawn_delay
