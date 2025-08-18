extends CharacterActor2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const GROUP_POI : StringName = &"SEGFAULT_POI"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _player : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_player() -> CharacterActor2D:
	var player : CharacterActor2D = _player.get_ref()
	if player == null:
		var nodes : Array[Node] = get_tree().get_nodes_in_group(Game.GROUP_PLAYER)
		for n : Node in nodes:
			if n is CharacterActor2D:
				player = n
				_player = weakref(player)
				break
	return player

func get_teleport_position() -> Vector2:
	var pois : Array[Node] = get_tree().get_nodes_in_group(GROUP_POI)
	pois = pois.filter(func(item : Node): return item is Node2D)
	match pois.size():
		0,1:
			if pois.size() == 1:
				return pois[0].global_position
		_:
			var idx : int = randi_range(0, pois.size())
			return pois[idx].global_position
		
	return Vector2.ZERO
