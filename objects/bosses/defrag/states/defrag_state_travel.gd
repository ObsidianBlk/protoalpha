extends ActorState


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const MIN_TRAVEL_DISTANCE : float = 25.0

const POST_TRAVEL_HOLD_DURATION : float = 0.5

enum TravelAxis {NONE=0, XAXIS=1, YAXIS=2}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
@export var hitbox_primary : HitBox = null
@export var hitbox_travel : HitBox = null
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
func enter(invulerable : Variant = null) -> void:
	if actor == null or actor.travel_target_group.is_empty():
		pop()
		return
	
	if typeof(invulerable) == TYPE_BOOL and invulerable == true:
		if hitbox_primary != null:
			hitbox_primary.disable_hitbox(true)
		if hitbox_travel != null:
			hitbox_travel.disable_hitbox(false)
	
	_travel_axis = TravelAxis.NONE
	if not actor.animation_finished.is_connected(_on_actor_animation_finished):
		actor.animation_finished.connect(_on_actor_animation_finished)
	
	actor.change_action(actor.CORE_ACTION_BRICK)

func exit() -> void:
	_target = null
	
	if hitbox_primary != null:
		hitbox_primary.disable_hitbox(false)
	if hitbox_travel != null:
		hitbox_travel.disable_hitbox(true)
		
	if actor != null:
		if actor.animation_finished.is_connected(_on_actor_animation_finished):
			actor.animation_finished.disconnect(_on_actor_animation_finished)

func update(_delta : float) -> void:
	pass

func physics_update(delta : float) -> void:
	if _target == null: return
	actor.face_player()
	
	if actor.global_position.is_equal_approx(_target.global_position):
		_target = null
		_travel_axis = TravelAxis.NONE
		if actor.is_player_close():
			_FindTarget()
		else:
			actor.end_brick_mode()
		return
	
	var dx : float = _target.global_position.x - actor.global_position.x
	var dy : float = _target.global_position.y - actor.global_position.y
	var pix : float = actor.travel_speed * delta
	
	if _travel_axis == TravelAxis.NONE:
		if dx >= dy:
			_travel_axis = TravelAxis.XAXIS
		else: _travel_axis = TravelAxis.YAXIS
	
	match _travel_axis:
		TravelAxis.XAXIS:
			if abs(dx) > pix:
				actor.global_position.x += sign(dx) * pix
			else:
				actor.global_position.x += dx
			
			if is_equal_approx(actor.global_position.x, _target.global_position.x):
				_travel_axis = TravelAxis.YAXIS
		TravelAxis.YAXIS:
			if abs(dy) > pix:
				actor.global_position.y += sign(dy) * pix
			else:
				actor.global_position.y += dy
			
			if is_equal_approx(actor.global_position.y, _target.global_position.y):
				_travel_axis = TravelAxis.XAXIS
		#TravelAxis.NONE:
			#if abs(dx) >= abs(dy):
				#_travel_axis = TravelAxis.XAXIS
			#else: _travel_axis = TravelAxis.YAXIS


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_actor_animation_finished(anim_name : StringName) -> void:
	match anim_name:
		actor.ANIM_TO_BRICK:
			if hitbox_primary != null:
				hitbox_primary.disable_hitbox(true)
			if hitbox_travel != null:
				hitbox_travel.disable_hitbox(false)
			_FindTarget()
		actor.ANIM_FROM_BRICK:
			if not state_idle.is_empty():
				swap_to(state_idle, POST_TRAVEL_HOLD_DURATION)
