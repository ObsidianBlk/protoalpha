@tool
extends Node2D
class_name MobSpawner


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var mob : MobInfo = null:			set=set_mob
@export var segment : MapSegment = null
@export var mob_container : Node2D = null
@export var count : int = 1
@export var spawn_delay : float = 3.0
@export var continuous : bool = false
@export var active : bool = true:			set=set_active


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _segment_active : bool = false
var _spawned : int = 0
var _spawns : Array[Node2D] = []
var _delay : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_mob(m : MobInfo) -> void:
	_DisconnectMobInfo()
	mob = m
	_ConnectMobInfo()
	queue_redraw()

func set_active(a : bool) -> void:
	if a != active:
		active = a
		if active:
			if is_physics_processing():
				_SpawnMob()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
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
	if mob == null or mob.sprite_reference == null: return
	var size : Vector2i = mob.sprite_reference.get_size()
	var pos : Vector2 = Vector2(-(size.x * 0.5), -size.y)
	draw_texture(mob.sprite_reference, pos)
	mob.draw_editor_display(self)

func _physics_process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay <= 0.0:
			_SpawnMob()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectMobInfo() -> void:
	if mob == null: return
	if not mob.changed.is_connected(_on_mob_info_changed):
		mob.changed.connect(_on_mob_info_changed)

func _DisconnectMobInfo() -> void:
	if mob == null: return
	if mob.changed.is_connected(_on_mob_info_changed):
		mob.changed.disconnect(_on_mob_info_changed)

func _GetContainer() -> Node2D:
	if mob_container != null:
		return mob_container
	var parent : Node = get_parent()
	if parent is Node2D:
		return parent
	return null

func _SpawnMob() -> void:
	if not active or mob == null or mob.mob_scene == null: return
	var container : Node2D = _GetContainer()
	if container == null: return
	
	if (_spawned < count and not continuous) or (continuous and _spawns.size() < count):
		var mob_instance : Node2D = mob.get_scene_instance()
		if mob_instance != null:
			if not continuous:
				_spawned += 1
			mob_instance.tree_exiting.connect(_on_spawn_exiting_tree.bind(mob_instance))
			container.add_child(mob_instance)
			mob_instance.global_position = global_position
			_spawns.append(mob_instance)
			_delay = spawn_delay

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
		_spawns.remove_at(idx)
		if continuous:
			_delay = spawn_delay
