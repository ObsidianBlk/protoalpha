@tool
extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal trigger_state_changed(triggered : bool)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_INACTIVE : StringName = &"inactive"
const ANIM_ACTIVE : StringName = &"active"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var triggered : bool = false:						set=set_triggered
@export var locked : bool = false:							set=set_locked
@export var trigger_reset_timer : float = 0.0:				set=set_trigger_reset_timer
@export_flags_2d_physics var trigger_layer : int = 1:		set=set_trigger_layer

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _reset_timer : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _trigger_area: Area2D = %TriggerArea
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_triggered(t : bool) -> void:
	if t != triggered:
		triggered = t
		if _sprite != null:
			_sprite.play(ANIM_ACTIVE if triggered else ANIM_INACTIVE)
		if not triggered:
			_reset_timer = 0.0
		trigger_state_changed.emit(triggered)

func set_locked(l : bool) -> void:
	if l != locked:
		locked = l
		if locked and triggered:
			triggered = false

func set_trigger_reset_timer(t : float) -> void:
	if not is_equal_approx(trigger_reset_timer, t):
		trigger_reset_timer = t
		if trigger_reset_timer <= 0.0:
			_reset_timer = 0.0

func set_trigger_layer(tl : int) -> void:
	if tl != trigger_layer:
		trigger_layer = tl
		if _trigger_area != null:
			_trigger_area.collision_layer = trigger_layer

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_trigger_area.collision_layer = trigger_layer
	_sprite.play(ANIM_ACTIVE if triggered else ANIM_INACTIVE)
	if triggered:
		_reset_timer = trigger_reset_timer

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _reset_timer > 0.0:
		_reset_timer -= delta
		if _reset_timer <= 0.0:
			triggered = false

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_triggered() -> bool:
	return triggered

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_interactable_focus_entered() -> void:
	print("Interactable focus entered")

func _on_interactable_focus_exited() -> void:
	print("Interactable focus exited")

func _on_interactable_interacted() -> void:
	if not locked:
		triggered = not triggered
		if triggered:
			_reset_timer = trigger_reset_timer
