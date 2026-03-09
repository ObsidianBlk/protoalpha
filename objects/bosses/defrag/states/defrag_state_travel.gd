extends ActorState


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const MIN_TRAVEL_DISTANCE : float = 25.0

enum TravelAxis {NONE=0, XAXIS=1, YAXIS=2}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
@export var state_idle : StringName = &""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _target : Node2D = null
var _travel_axis : TravelAxis = TravelAxis.NONE

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _FindTarget() -> void:
	var ttg : Array[Node] = get_tree().get_nodes_in_group(actor.travel_target_group)
	ttg = ttg.filter(
		func(item : Node):
			if item is Node2D:
				return item.global_position.distance_to(actor.global_position) > MIN_TRAVEL_DISTANCE
			return false
	)
	if ttg.size() > 0:
		var idx : int = randi_range(0, ttg.size() - 1)
		_target = ttg[idx]
	else:
		_target = null
		actor.end_brick_mode()

# -------------------------------------------------------------------------
# Virtual Methods
# -------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null or actor.travel_target_group.is_empty():
		pop()
		return
	_travel_axis = TravelAxis.NONE
	if not actor.animation_finished.is_connected(_on_actor_animation_finished):
		actor.animation_finished.connect(_on_actor_animation_finished)
	
	actor.change_action(actor.CORE_ACTION_BRICK)

func exit() -> void:
	_target = null
	if actor != null:
		if actor.animation_finished.is_connected(_on_actor_animation_finished):
			actor.animation_finished.disconnect(_on_actor_animation_finished)

func update(_delta : float) -> void:
	pass

func physics_update(delta : float) -> void:
	if _target == null: return
	
	var dx : float = _target.global_position.x - actor.global_position.x
	var dy : float = _target.global_position.y - actor.global_position.y
	var pix : float = actor.travel_speed * delta
	
	match _travel_axis:
		TravelAxis.XAXIS:
			if abs(dx) > pix:
				actor.global_position.x += sign(dx) * pix
			else:
				actor.global_position.x += dx
			
			if is_equal_approx(actor.global_position.x, _target.global_position.x):
				pass
		TravelAxis.YAXIS:
			pass
		TravelAxis.NONE:
			if abs(dx) >= abs(dy):
				_travel_axis = TravelAxis.XAXIS
			else: _travel_axis = TravelAxis.YAXIS


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_actor_animation_finished(anim_name : StringName) -> void:
	match anim_name:
		actor.ANIM_TO_BRICK:
			_FindTarget()
		actor.ANIM_FROM_BRICK:
			if not state_idle.is_empty():
				swap_to(state_idle)
