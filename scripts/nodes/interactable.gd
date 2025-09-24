extends Node
class_name Interactable

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal interacted()
signal focus_entered()
signal focus_exited()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const USIG_INTERACTED : StringName = &"interacted"
const USIG_FOCUS_ENTERED : StringName = &"focus_entered"
const USIG_FOCUS_EXITED : StringName = &"focus_exited"

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	_ConnectToHost()

func _exit_tree() -> void:
	_DisconnectFromHost()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectToHost() -> void:
	var parent : Node = get_parent()
	if parent == null:
		printerr("Interactable node failed to find parent host.")
		return
	
	if not parent.has_user_signal(USIG_INTERACTED):
		parent.add_user_signal(USIG_INTERACTED)
	if not parent.is_connected(USIG_INTERACTED, _on_host_interacted):
		parent.connect(USIG_INTERACTED, _on_host_interacted)
	
	if not parent.has_user_signal(USIG_FOCUS_ENTERED):
		parent.add_user_signal(USIG_FOCUS_ENTERED)
	if not parent.is_connected(USIG_FOCUS_ENTERED, _on_host_focus_entered):
		parent.connect(USIG_FOCUS_ENTERED, _on_host_focus_entered)
	
	if not parent.has_user_signal(USIG_FOCUS_EXITED):
		parent.add_user_signal(USIG_FOCUS_EXITED)
	if not parent.is_connected(USIG_FOCUS_EXITED, _on_host_focus_exited):
		parent.connect(USIG_FOCUS_EXITED, _on_host_focus_exited)


func _DisconnectFromHost() -> void:
	var parent : Node = get_parent()
	if parent == null: return
	
	for sig_name : StringName in [USIG_INTERACTED, USIG_FOCUS_ENTERED, USIG_FOCUS_EXITED]:
		if parent.has_user_signal(sig_name):
			var siglist : Array[Dictionary] = parent.get_signal_connection_list(sig_name)
			for sig : Dictionary in siglist:
				parent.disconnect(sig_name, sig.callable)
			parent.remove_user_signal(sig_name)

# ------------------------------------------------------------------------------
# Handler
# ------------------------------------------------------------------------------
func _on_host_interacted() -> void:
	interacted.emit()

func _on_host_focus_entered() -> void:
	focus_entered.emit()

func _on_host_focus_exited() -> void:
	focus_exited.emit()
