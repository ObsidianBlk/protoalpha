extends SegFaultState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 50.0
@export_group("States")
@export var state_idle : StringName = &""
@export var state_teleport : StringName = &""
@export var state_fall : StringName = &""

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

func exit() -> void:
	if actor != null:
		_DisconnectPlayer(actor.get_player())

func update(delta : float) -> void:
	pass


func physics_update(_delta : float) -> void:
	if actor == null: return
	var player : CharacterActor2D = actor.get_player()
	if player == null:
		swap_to(state_idle)
		return
	
	var dir : float = get_player_direction(player)
	actor.velocity.x = speed * dir
	if not actor.is_on_surface():
		actor.velocity.y = actor.get_gravity().y
	else: actor.velocity.y = 0.0
	
	actor.move_and_slide()
	if player.global_position.distance_to(actor.global_position) < 4.0:
		swap_to(state_teleport)
		return
	if not actor.is_on_surface():
		swap_to(state_fall)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_weapon_fired() -> void:
	swap_to(state_teleport)
