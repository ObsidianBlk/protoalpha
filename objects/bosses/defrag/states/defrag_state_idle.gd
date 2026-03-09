extends ActorState


# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const ACTION_NONE : StringName = &"NONE"
const ACTION_TRAVEL : StringName = &"TRAVEL"
const ACTION_ATTACK : StringName = &"ATTACK"
const ACTION_SHIFT : StringName = &"SHIFT"

const NO_ACTION_DELAY : float = 0.25

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

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_actions = WeightedCollection.new()
	_actions.insert(ACTION_TRAVEL, 5.0)
	_actions.insert(ACTION_ATTACK, 5.0)
	_actions.insert(ACTION_NONE, 2.0)
	_actions.insert(ACTION_SHIFT, 2.0)

# -------------------------------------------------------------------------
# Virtual Methods
# -------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if actor == null: return
	_hold_duration = 0.0
	if typeof(payload) == TYPE_FLOAT and payload > 0.0:
		_hold_duration = payload
	actor.change_action(actor.CORE_ACTION_IDLE)

func update(delta : float) -> void:
	if _hold_duration > 0.0:
		_hold_duration -= delta
	else:
		var action : StringName = _actions.rand_item()
		match action:
			ACTION_ATTACK:
				if not state_attack_block.is_empty():
					swap_to(state_attack_block)
			ACTION_SHIFT:
				if not state_shift.is_empty():
					swap_to(state_shift)
			ACTION_NONE:
				_hold_duration = NO_ACTION_DELAY
