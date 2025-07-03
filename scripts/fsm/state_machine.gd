extends Node
class_name StateMachine


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _default : State = null
var _stack : Array[State] = []

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	await owner.ready
	var possible_default : State = null
	for child : Node in get_children():
		if child is State:
			_ConnectChildState(child)
			if possible_default == null:
				possible_default = child
			if child.default:
				if _default == null:
					_default = child
				else:
					child.default = false
	if _default == null:
		_default = possible_default
	if _default == null: return # Yes, we need to check for no default state

	_stack.append(_default)
	_stack[-1].enter()


func _unhandled_input(event: InputEvent) -> void:
	var current : State = _GetCurrentState()
	if current == null: return
	current.handle_input(event)

func _process(delta: float) -> void:
	var current : State = _GetCurrentState()
	if current == null: return
	current.update(delta)

func _physics_process(delta: float) -> void:
	var current : State = _GetCurrentState()
	if current == null: return
	current.physics_update(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectChildState(child : State) -> void:
	if child == null: return
	if not child.default_state_changed.is_connected(_on_state_default_changed.bind(child.name)):
		child.default_state_changed.connect(_on_state_default_changed.bind(child.name))
	if not child.action_requested.is_connected(_on_state_action_requested):
		child.action_requested.connect(_on_state_action_requested)

func _DisconnectChildState(child : State) -> void:
	if child == null: return
	if child.default_state_changed.is_connected(_on_state_default_changed.bind(child.name)):
		child.default_state_changed.disconnect(_on_state_default_changed.bind(child.name))
	if child.action_requested.is_connected(_on_state_action_requested):
		child.action_requested.disconnect(_on_state_action_requested)

func _GetCurrentState() -> State:
	if _stack.size() > 0:
		return _stack[-1]
	return null

func _GetState(state_name : StringName) -> State:
	for child : Node in get_children():
		if child is State and child.name == state_name:
			return child
	return null

func _GetStackIndex(state_name : StringName) -> int:
	for i : int in range(_stack.size()):
		if _stack[i].name == state_name:
			return i
	return -1

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func transition_state(state_name : StringName, payload : Variant = null) -> int:
	var state : State = _GetState(state_name)
	if state == null: return ERR_DOES_NOT_EXIST
	
	if _stack.size() > 0:
		_stack[-1].exit()
	_stack.append(state)
	_stack[-1].enter(payload)
	return OK

func swap_state(state_name : StringName, payload : Variant = null) -> int:
	var state : State = _GetState(state_name)
	if state == null: return ERR_DOES_NOT_EXIST
	
	if _stack.size() > 0:
		if _stack[-1] != state:
			var ostate : State = _stack.pop_back()
			ostate.exit()
			
		var idx : int = _GetStackIndex(state_name)
		if idx >= 0:
			_stack.remove_at(idx)
	
	_stack.append(state)
	_stack[-1].enter(payload)
	return OK

func pop_state(ignore_default : bool = false, payload : Variant = null) -> int:
	if _stack.size() > 0:
		var state : State = _stack.pop_back()
		if state != null: state.exit()
		if _stack.size() > 0:
			_stack[-1].enter()
	if _stack.size() <= 0 and not (ignore_default or _default == null):
		_stack.append(_default)
		_stack[-1].enter(payload)
	return OK

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_state_action_requested(action : StringName, args : Array = []) -> void:
	match  action:
		State.STATE_ACTION_TRANSITION:
			transition_state.callv(args)
		State.STATE_ACTION_SWAP:
			swap_state.callv(args)
		State.STATE_ACTION_POP:
			pop_state.callv(args)

func _on_state_default_changed(state_name : StringName) -> void:
	for child : Node in get_children():
		if child is State:
			if child.name != state_name:
				child.default = false
			else:
				_default = child
