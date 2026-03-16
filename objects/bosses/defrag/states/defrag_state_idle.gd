extends ActorState


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const ACTION_NONE : StringName = &"NONE"
const ACTION_TRAVEL : StringName = &"TRAVEL"
const ACTION_ATTACK : StringName = &"ATTACK"
const ACTION_SHIFT : StringName = &"SHIFT"

const NO_ACTION_DELAY : float = 1.0

const COOLDOWN_ATTACK : float = 3.0
const COOLDOWN_SHIFT : float = 10.0

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
@export var state_travel : StringName = &""
@export var state_attack_block : StringName = &""
@export var state_shift : StringName = &""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _hold_duration : float = 0.0
var _actions : WeightedCollection = null

var _cooldown_attack : float = 0.0
var _cooldown_shift : float = 0.0

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_actions = WeightedCollection.new()
	_actions.insert(ACTION_TRAVEL, 2.0)
	_actions.insert(ACTION_ATTACK, 5.0)
	_actions.insert(ACTION_NONE, 1.0)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Virtual Methods
# -------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null: return
	_hold_duration = 0.0
	if typeof(payload) == TYPE_FLOAT and payload > 0.0:
		_hold_duration = payload
	
	if not actor.player_closeness_changed.is_connected(_on_player_closeness_changed):
		actor.player_closeness_changed.connect(_on_player_closeness_changed)
	actor.change_action(actor.CORE_ACTION_IDLE)

func exit() -> void:
	if actor != null:
		if actor.player_closeness_changed.is_connected(_on_player_closeness_changed):
			actor.player_closeness_changed.disconnect(_on_player_closeness_changed)

func update(delta : float) -> void:
	actor.face_player()
	
	if _cooldown_attack > 0.0:
		_cooldown_attack -= delta
	if _cooldown_shift > 0.0:
		_cooldown_shift -= delta
	
	if _hold_duration > 0.0:
		_hold_duration -= delta
	else:
		var action : StringName = _actions.rand_item()
		match action:
			ACTION_TRAVEL:
				if not state_travel.is_empty():
					swap_to(state_travel)
			ACTION_ATTACK:
				if not state_attack_block.is_empty() and _cooldown_attack <= 0.0:
					_cooldown_attack = COOLDOWN_ATTACK
					swap_to(state_attack_block)
			ACTION_SHIFT:
				if not state_shift.is_empty() and _cooldown_shift <= 0.0:
					_cooldown_shift = COOLDOWN_SHIFT
					swap_to(state_shift)
			ACTION_NONE:
				_hold_duration = NO_ACTION_DELAY

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_player_closeness_changed(close : bool) -> void:
	if close and not state_travel.is_empty():
		swap_to(state_travel)
