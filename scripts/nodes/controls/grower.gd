extends Control
class_name Grower

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal finished()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ref_control : Control = null
@export var duration : float = 0.5

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _parent : Container = null
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetParent() -> Container:
	if _parent == null:
		var parent : Node = get_parent()
		if parent is Container:
			_parent = parent
	return _parent

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func open(instant : bool = false) -> void:
	if ref_control == null or _tween != null: return
	
	var container : Container = _GetParent()
	if container == null: return
	
	if instant:
		visible = false
		container.visible = true
		ref_control.visible = true
	else:
		container.visible = true
		ref_control.visible = false
		custom_minimum_size = Vector2.ZERO
		visible = true
		
		var target : Vector2 = ref_control.custom_minimum_size
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.set_trans(Tween.TRANS_SINE)
		_tween.tween_property(self, "custom_minimum_size", target, duration)
		await _tween.finished
		_tween = null
		ref_control.visible = true
		visible = false
		finished.emit()

func close(instant : bool = false) -> void:
	if ref_control == null or _tween != null: return
	
	var container : Container = _GetParent()
	if container == null: return
	
	if instant:
		visible = false
		container.visible = false
		ref_control.visible = false
	else:
		container.visible = true
		ref_control.visible = false
		visible = true
		
		custom_minimum_size = ref_control.custom_minimum_size
		
		var target : Vector2 = Vector2.ZERO
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_IN_OUT)
		_tween.set_trans(Tween.TRANS_SINE)
		_tween.tween_property(self, "custom_minimum_size", target, duration)
		await _tween.finished
		_tween = null
		visible = false
		container.visible = false
		finished.emit()

func toggle(instant : bool = false) -> void:
	if ref_control == null or _tween != null: return
	if ref_control.visible:
		await close(instant)
	else:
		await open(instant)
