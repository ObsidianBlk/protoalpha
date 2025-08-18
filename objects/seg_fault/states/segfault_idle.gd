extends ActorState

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var min_idle_time : float = 0.0:	set=set_min_idle_time
@export var max_idle_time : float = 1.0:	set=set_max_idle_time
@export_group("States")
@export var state_move : StringName = &""
@export var state_teleport : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _idle_time : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_min_idle_time(t : float) -> void:
	if t >= 0.0 and not is_equal_approx(min_idle_time, t):
		min_idle_time = t
		if min_idle_time > max_idle_time:
			max_idle_time = min_idle_time

func set_max_idle_time(t : float) -> void:
	if t >= 0.0 and not is_equal_approx(max_idle_time, t):
		max_idle_time = t
		if max_idle_time < min_idle_time:
			min_idle_time = max_idle_time

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectPlayer(player : CharacterActor2D) -> void:
	if player == null: return
	if not player.weapon_fired.is_connected(_on_player_weapon_fired):
		player.weapon_fired.connect(_on_player_weapon_fired)

func _DisconnectPlayer(player : CharacterActor2D) -> void:
	if player == null: return
	if player.weapon_fired.is_connected(_on_player_weapon_fired):
		player.weapon_fired.disconnect(_on_player_weapon_fired)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null:
		pop()
		return
	actor.velocity = Vector2.ZERO
	_ConnectPlayer(actor.get_player())
	_idle_time = randf_range(min_idle_time, max_idle_time)

func exit() -> void:
	if actor != null:
		_DisconnectPlayer(actor.get_player())

func update(delta : float) -> void:
	if _idle_time > 0.0:
		_idle_time -= delta
	if _idle_time <= 0.0:
		swap_to(state_move)


func physics_update(_delta : float) -> void:
	if actor == null: return
	if not actor.is_on_ladder():
		actor.velocity.y = actor.get_gravity().y
	else: actor.velocity.y = 0.0
	
	actor.move_and_slide()
	if not actor.is_on_surface(): pass
		#if not state_fall.is_empty():
			#swap_to(state_fall)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_weapon_fired() -> void:
	swap_to(state_teleport)
