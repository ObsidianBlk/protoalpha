extends Node
class_name ComponentRelay


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var relay_screen_rect : bool = false:		set=set_relay_screen_rect

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _parent : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_relay_screen_rect(r : bool) -> void:
	if relay_screen_rect != r:
		relay_screen_rect = r
		set_physics_process(relay_screen_rect)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_physics_process(relay_screen_rect)

func _physics_process(_delta: float) -> void:
	var parent : CharacterActor2D = _GetParent()
	if parent == null: return
	Relay.player_rect_changed.emit(Rect2(parent.get_screen_position(), parent.get_size()))
	#var parent : Node = get_parent()
	#if parent is CharacterActor2D:
		#var stransform : Transform2D = parent.get_screen_transform()
		#Relay.player_rect_changed.emit(Rect2(stransform.origin, Vector2.ONE))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetParent() -> CharacterActor2D:
	var parent : Node = _parent.get_ref()
	if not parent is CharacterActor2D:
		parent = get_parent()
		if parent is CharacterActor2D:
			_parent = weakref(parent)
		else : parent = null
	return parent

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func health_changed(health : int, max_health : int, is_boss : bool = false) -> void:
	if is_boss:
		Relay.boss_health_changed.emit(health, max_health)
	else:
		Relay.health_changed.emit(health, max_health)

func energy_changed(special : GameState.Special) -> void:
	Relay.energy_changed.emit(special)

func boss_dead() -> void:
	Relay.boss_dead.emit()

func boss_removed() -> void:
	Relay.boss_removed.emit()
