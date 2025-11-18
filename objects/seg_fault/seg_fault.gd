extends CharacterActor2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal area_entered()
signal area_exited()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const GROUP_POI : StringName = &"SEGFAULT_POI"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _player : WeakRef = weakref(null)
var _area : Area2D = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
#@onready var _sprite: AnimatedSprite2D = %ASprite

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
			var idx : int = randi_range(0, pois.size() - 1)
			return pois[idx].global_position
		
	return Vector2.ZERO

func is_in_area(group_name : StringName = &"") -> bool:
	if _area != null:
		if not group_name.is_empty():
			return _area.is_in_group(group_name)
		return true
	return false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if _area == null:
		_area = area
		area_entered.emit()

func _on_area_exited(area : Area2D) -> void:
	if area == _area:
		_area = null
		area_exited.emit()
