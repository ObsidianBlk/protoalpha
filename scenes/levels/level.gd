extends Node2D
class_name Level


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal pause_requested()
signal completed()
signal defeated()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const PLAYER_SCENE : PackedScene = preload("res://objects/proto/proto.tscn")
const PLAYER_RESPAWN_TIMER : float = 1.0

const MUSIC_CROSSFADE_DURATION : float = 1.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var player_container : Node2D = null:		set=set_player_container
@export var boss_container : Node2D = null:			set=set_boss_container
@export var music_sheet : MusicSheet = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _can_spawn_player : bool = true
var _player_respawn_timer : float = 0.0
var _active_segments : Dictionary[StringName, MapSegment] = {}

var _boss_defeated : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_player_container(pc : Node2D) -> void:
	if player_container != pc:
		_DisconnectContainer(player_container)
		player_container = pc
		_ConnectContainer(player_container)

func set_boss_container(bc : Node2D) -> void:
	if boss_container != bc:
		_DisconnectContainer(boss_container)
		boss_container = bc
		_ConnectContainer(boss_container)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	for child : Node in get_children():
		if child is MapSegment:
			_ConnectSegment(child)

func _exit_tree() -> void:
	if music_sheet != null:
		music_sheet.stop_all()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		pause_requested.emit()

func _process(delta: float) -> void:
	if _player_respawn_timer > 0.0:
		_player_respawn_timer -= delta
		if _player_respawn_timer <= 0.0:
			_ClearBosses()
			spawn_player()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectContainer(container : Node2D) -> void:
	if container == null: return
	if not container.child_entered_tree.is_connected(_on_child_entered):
		container.child_entered_tree.connect(_on_child_entered)
	if not container.child_exiting_tree.is_connected(_on_child_exiting):
		container.child_exiting_tree.connect(_on_child_exiting)

func _DisconnectContainer(container : Node2D) -> void:
	if container == null: return
	if container.child_entered_tree.is_connected(_on_child_entered):
		container.child_entered_tree.disconnect(_on_child_entered)
	if container.child_exiting_tree.is_connected(_on_child_exiting):
		container.child_exiting_tree.disconnect(_on_child_exiting)

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

func _ClearBosses() -> void:
	for boss : Node in get_tree().get_nodes_in_group(Game.GROUP_BOSS):
		if boss is CharacterActor2D:
			boss.queue_free()

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
	player.position = checkpoint.global_position
	if player_container != null:
		player_container.add_child(player)
	else:
		print_debug("WARNING: No player container defined. Adding player directly under level tree.")
		add_child(player)
	if player.has_method("spawn_at"):
		player.spawn_at(checkpoint.global_position)
		Relay.health_changed.emit(100, 100)
	if level_start:
		camera.snap_to_target()
	_can_spawn_player = false


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered(child : Node) -> void:
	if child is CharacterActor2D and child.is_in_group(Game.GROUP_BOSS):
		if not child.dead.is_connected(_on_boss_dead):
			child.dead.connect(_on_boss_dead)
		_boss_defeated = false

func _on_child_exiting(child : Node) -> void:
	if not child is CharacterActor2D: return
	if child.is_in_group(Game.GROUP_PLAYER):
		if not _boss_defeated:
			Game.State.lives -= 1
		if Game.State.lives > 0:
			_player_respawn_timer = PLAYER_RESPAWN_TIMER
			_can_spawn_player = true
		else: defeated.emit()
	elif child.is_in_group(Game.GROUP_BOSS):
		if child.dead.is_connected(_on_boss_dead):
			child.dead.disconnect(_on_boss_dead)
		if _boss_defeated:
			# TODO: Call a Victory screen animation!
			completed.emit()

func _on_segment_entered(segment : MapSegment) -> void:
	if not segment.name in _active_segments:
		_active_segments[segment.name] = segment
		if music_sheet != null:
			music_sheet.stop_non_local()
			music_sheet.play(segment.music_name, MUSIC_CROSSFADE_DURATION)

func _on_segment_exited(segment : MapSegment) -> void:
	if segment.name in _active_segments:
		_active_segments.erase(segment.name)
	if _active_segments.size() == 1:
		_active_segments.values()[0].focus()

func _on_boss_dead() -> void:
	_boss_defeated = true
