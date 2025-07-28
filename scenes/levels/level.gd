extends Node2D
class_name Level


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const PLAYER_SCENE : PackedScene = preload("res://objects/proto/proto.tscn")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var player_container : Node2D = null:		set=set_player_container

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _can_spawn_player : bool = true
var _active_segments : Dictionary[StringName, MapSegment] = {}


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_player_container(pc : Node2D) -> void:
	if player_container != pc:
		_DisconnectPlayerContainer()
		player_container = pc
		_ConnectPlayerContainer()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	for child : Node in get_children():
		if child is MapSegment:
			_ConnectSegment(child)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectPlayerContainer() -> void:
	if player_container == null: return
	if not player_container.child_exiting_tree.is_connected(_on_child_exiting):
		player_container.child_exiting_tree.connect(_on_child_exiting)

func _DisconnectPlayerContainer() -> void:
	if player_container == null: return
	if player_container.child_exiting_tree.is_connected(_on_child_exiting):
		player_container.child_exiting_tree.disconnect(_on_child_exiting)

func _ConnectSegment(segment : MapSegment) -> void:
	if segment == null: return
	if not segment.entered.is_connected(_on_segment_entered.bind(segment)):
		segment.entered.connect(_on_segment_entered.bind(segment))
	if not segment.exited.is_connected(_on_segment_exited.bind(segment)):
		segment.exited.connect(_on_segment_exited.bind(segment))

func _DisconnectSegment(segment : MapSegment) -> void:
	if segment == null: return
	if segment.entered.is_connected(_on_segment_entered.bind(segment)):
		segment.entered.disconnect(_on_segment_entered.bind(segment))
	if segment.exited.is_connected(_on_segment_exited.bind(segment)):
		segment.exited.disconnect(_on_segment_exited.bind(segment))


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func spawn_player(level_start : bool = false) -> void:
	var camera : ChaseCamera = ChaseCamera.Get_Camera()
	if player_container == null or camera == null or not _can_spawn_player: return
	
	var checkpoint : Checkpoint = Checkpoint.Get_Current_Checkpoint()
	if level_start or checkpoint == null:
		checkpoint = Checkpoint.Get_Spawn_Point()
	if checkpoint == null:
		printerr("Level missing main player spawn point.")
		return
	
	var player : Node2D = PLAYER_SCENE.instantiate()
	player.add_to_group(Game.GROUP_PLAYER)
	camera.target = player
	add_child(player)
	if player.has_method("spawn_at"):
		player.spawn_at(checkpoint.global_position)
		Relay.health_changed.emit(100, 100)
	_can_spawn_player = false


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_exiting(child : Node) -> void:
	if child == null: return
	if child.is_in_group(Game.GROUP_PLAYER):
		# TODO: Disconnect from signals as needed
		_can_spawn_player = true

func _on_segment_entered(segment : MapSegment) -> void:
	if not segment.name in _active_segments:
		_active_segments[segment.name] = segment

func _on_segment_exited(segment : MapSegment) -> void:
	if segment.name in _active_segments:
		_active_segments.erase(segment.name)
	if _active_segments.size() == 1:
		_active_segments.values()[0].focus()
