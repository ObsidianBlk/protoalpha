extends Area2D
class_name Interactor2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal interactables_changed()

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _interactables : Array[Node2D] = []
var _focused : int = -1

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsInteractable(o : Node2D) -> bool:
	for sig_name : StringName in [Interactable.USIG_INTERACTED, Interactable.USIG_FOCUS_ENTERED, Interactable.USIG_FOCUS_EXITED]:
		if not o.has_user_signal(sig_name):
			return false
	return true

func _AddInteractable(o : Node2D) -> void:
	if _interactables.find(o) < 0:
		_interactables.append(o)
		# If not currently focused on any interactable, focus this new one!
		if _focused < 0:
			o.emit_signal(Interactable.USIG_FOCUS_ENTERED)
			_focused = _interactables.size() - 1
		interactables_changed.emit()

func _RemoveInteractable(o : Node2D) -> void:
	var idx : int = _interactables.find(o)
	if idx >= 0:
		# If we're removing the currently focused interactable, tell it to exit focus
		if idx == _focused:
			_interactables[idx].emit_signal(Interactable.USIG_FOCUS_EXITED)
			_focused = -1
		
		# Removing the interactable
		_interactables.remove_at(idx)
		
		# If we don't, currently, have a focused interactable, but there's at least one in the list
		# focus the last interactable in the list.
		if _focused < 0 and _interactables.size() > 0:
			_focused = _interactables.size() - 1
			_interactables[_focused].emit_signal(Interactable.USIG_FOCUS_ENTERED)
		
		interactables_changed.emit()


func _SignalInteractable(sig_name : StringName, idx : int = -1) -> void:
	if _interactables.size() <= 0: return
	if idx < 0:
		idx = _interactables.size() - 1
	if idx >= 0 and idx < _interactables.size():
		var o : Node2D = _interactables[idx]
		o.emit_signal(sig_name)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interactable_count() -> int:
	return _interactables.size()

func get_focused_interactable_index() -> int:
	return _focused

func interact() -> void:
	_SignalInteractable(Interactable.USIG_INTERACTED, _focused)

func focus_interactable(idx : int) -> void:
	if _interactables.size() <= 0 or _focused == idx: return
	if idx >= 0 and idx < _interactables.size():
		if _focused >= 0:
			_interactables[_focused].emit_signal(Interactable.USIG_FOCUS_EXITED)
		_focused = idx
		_interactables[_focused].emit_signal(Interactable.USIG_FOCUS_ENTERED)

func next_interactable() -> void:
	if _focused >= 0:
		focus_interactable(
			wrapi(_focused + 1, 0, _interactables.size() - 1)
		)

func prev_interactable() -> void:
	if _focused >= 0:
		focus_interactable(
			wrapi(_focused - 1, 0, _interactables.size() - 1)
		)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if _IsInteractable(body):
		_AddInteractable(body)

func _on_body_exited(body : Node2D) -> void:
	_RemoveInteractable(body)

func _on_area_entered(area : Area2D) -> void:
	if _IsInteractable(area):
		_AddInteractable(area)

func _on_area_exited(area : Area2D) -> void:
	_RemoveInteractable(area)
