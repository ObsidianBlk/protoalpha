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

func set_host(host : Node) -> void:
	pass

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
# sigs : Array of Dictionary where each dictionary has keys...
#	"signal" : StringName,
#	"callable" : Callable 
func connect_host_signals(host : Node, sigs : Array[Dictionary]) -> void:
	for sig : Dictionary in sigs:
		if Game.Dict_Key_Of_Type(sig, "signal", TYPE_STRING_NAME) and Game.Dict_Key_Of_Type(sig, "callable", TYPE_CALLABLE):
			var signal_name : StringName = sig["signal"]
			var cb : Callable = sig["callable"]
			if host.has_signal(signal_name) or host.has_user_signal(signal_name):
				if not host.is_connected(signal_name, cb):
					host.connect(signal_name, cb)

func disconnect_host_signals(host : Node, sigs : Array[Dictionary]) -> void:
	for sig : Dictionary in sigs:
		if Game.Dict_Key_Of_Type(sig, "signal", TYPE_STRING_NAME) and Game.Dict_Key_Of_Type(sig, "callable", TYPE_CALLABLE):
			var signal_name : StringName = sig["signal"]
			var cb : Callable = sig["callable"]
			if host.has_signal(signal_name) or host.has_user_signal(signal_name):
				if host.is_connected(signal_name, cb):
					host.disconnect(signal_name, cb)

func transition_to(state_name : StringName, payload : Variant = null) -> void:
	if state_name.is_empty(): return
	action_requested.emit(STATE_ACTION_TRANSITION, [state_name, payload])

func swap_to(state_name : StringName, payload : Variant = null) -> void:
	if state_name.is_empty(): return
	action_requested.emit(STATE_ACTION_SWAP, [state_name, payload])

func pop(ignore_default : bool = false, payload : Variant = null) -> void:
	action_requested.emit(STATE_ACTION_POP, [ignore_default, payload])
