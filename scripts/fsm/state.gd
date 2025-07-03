extends Node
class_name State


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal default_state_changed()
signal action_requested(action : StringName, args : Array)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const STATE_ACTION_TRANSITION : StringName = &"state_transition"
const STATE_ACTION_SWAP : StringName = &"state_swap"
const STATE_ACTION_POP : StringName = &"state_pop"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var default : bool = false:			set=set_default


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_default(d : bool) -> void:
	if d != default:
		default = d
		if default:
			default_state_changed.emit()

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	pass

func exit() -> void:
	pass

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	pass

func handle_input(event : InputEvent) -> void:
	pass

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_host() -> Node:
	var parent : Node = get_parent()
	if parent is StateMachine:
		return parent.get_parent()
	return null

func transition_to(state_name : StringName, payload : Variant = null) -> void:
	if state_name.is_empty(): return
	action_requested.emit(STATE_ACTION_TRANSITION, [state_name, payload])

func swap_to(state_name : StringName, payload : Variant = null) -> void:
	if state_name.is_empty(): return
	action_requested.emit(STATE_ACTION_SWAP, [state_name, payload])

func pop(ignore_default : bool = false, payload : Variant = null) -> void:
	action_requested.emit(STATE_ACTION_POP, [ignore_default, payload])
