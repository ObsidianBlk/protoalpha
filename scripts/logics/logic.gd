@tool
extends Node
class_name Logic


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal trigger_state_changed(triggered : bool)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const REQ_SIGNAL_NAME : StringName = &"trigger_state_changed"
const REQ_METHOD_NAME : StringName = &"is_triggered"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var connections : Array[Node] = []:				set=set_connections

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _triggered : bool = false:		set=_set_triggered

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_connections(conn : Array[Node]) -> void:
	_DisconnectConnections()
	connections = conn
	_ConnectConnections()
	if not Engine.is_editor_hint():
		_CheckTriggered()

func _set_triggered(t : bool) -> void:
	_triggered = t
	trigger_state_changed.emit(_triggered)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		_ConnectConnections()
		_CheckTriggered()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectConnections() -> void:
	if Engine.is_editor_hint(): return
	for c : Node in connections:
		if c.has_signal(REQ_SIGNAL_NAME):
			if c.is_connected(REQ_SIGNAL_NAME, _on_connection_trigger_changed):
				c.disconnect(REQ_SIGNAL_NAME, _on_connection_trigger_changed)

func _ConnectConnections() -> void:
	if Engine.is_editor_hint(): return
	for c : Node in connections:
		if c.has_signal(REQ_SIGNAL_NAME):
			if not c.is_connected(REQ_SIGNAL_NAME, _on_connection_trigger_changed):
				c.connect(REQ_SIGNAL_NAME, _on_connection_trigger_changed)

func _CheckTriggered() -> void:
	pass


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_triggered() -> bool:
	return _triggered

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_connection_trigger_changed(triggered : bool) -> void:
	_CheckTriggered()
