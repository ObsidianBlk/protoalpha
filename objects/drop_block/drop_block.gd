@tool
extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal active()
signal inactive()
signal transitioning()
signal transitioning_active()
signal transitioning_inactive()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_ACTIVATED : StringName = &"activated"
const ANIM_INACTIVE : StringName = &"inactive"
const ANIM_ACTIVATING : StringName = &"activating"
const ANIM_DEACTIVATING : StringName = &"deactivating"


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var activated : bool = true:			set=set_activated
@export var active_time : float = 1.0
@export var activating_speed : float = 1.0
@export var inactive_time : float = 1.0
@export var deactivating_speed : float = 1.0
@export var verbose : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _fn : Callable = func(): pass
var _timer : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _anim_player: AnimSpritePlayer = %AnimPlayer


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_activated(a : bool) -> void:
	if a != activated:
		activated = a
		_UpdateIdleAnim()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	reset()
	if Engine.is_editor_hint():
		set_process(false)

func _process(delta: float) -> void:
	if _timer > 0.0:
		_timer -= delta
		if verbose:
			print("Timer: ", _timer)
		if _timer <= 0.0:
			_fn.call_deferred()
			_fn = func(): pass

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateIdleAnim() -> void:
	if _anim_player == null: return
	if _anim_player.current_animation == ANIM_ACTIVATED or _anim_player.current_animation == ANIM_INACTIVE:
		_anim_player.play(ANIM_ACTIVATED if activated else ANIM_INACTIVE)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func trigger_activate(delay : float = 0.0) -> void:
	if verbose:
		print("Trigger Activate")
	if delay > 0.0:
		get_tree().create_timer(delay).timeout.connect(trigger_activate)
		return
	
	if _anim_player == null: return
	if _anim_player.current_animation == ANIM_INACTIVE:
		var speed : float = activating_speed if activating_speed > 0.0 else 1.0
		_anim_player.play(ANIM_ACTIVATING, -1.0, speed)
		transitioning_active.emit()
		transitioning.emit()

func trigger_deactivate(delay : float = 0.0) -> void:
	if verbose:
		print("Trigger Deactivate")
	if delay > 0.0:
		get_tree().create_timer(delay).timeout.connect(trigger_deactivate)
		return
	
	if _anim_player == null: return
	if _anim_player.current_animation == ANIM_ACTIVATED:
		var speed : float = deactivating_speed if deactivating_speed > 0.0 else 1.0
		_anim_player.play(ANIM_DEACTIVATING, -1.0, speed)
		transitioning_inactive.emit()
		transitioning.emit()

func trigger_toggle(delay : float = 0.0) -> void:
	if _anim_player == null: return
	if delay > 0.0:
		get_tree().create_timer(delay).timeout.connect(trigger_toggle)
		return

	match _anim_player.current_animation:
		ANIM_ACTIVATED:
			trigger_deactivate()
		ANIM_INACTIVE:
			trigger_activate()

func trigger(trigger_active : bool, action : int) -> void:
	if not trigger_active: return
	match action:
		0: # Activate
			trigger_activate()
		1: # Deactivate
			trigger_deactivate()
		2: # Toggle
			trigger_toggle()

func reset() -> void:
	if _anim_player == null: return
	_anim_player.play(ANIM_ACTIVATED if activated else ANIM_INACTIVE)
	_timer = 0.0
	_fn = func(): pass
	if activated and active_time > 0.0:
		_timer = active_time
		_fn = trigger_deactivate
	elif not activated and inactive_time > 0.0:
		_timer = inactive_time
		_fn = trigger_activate

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		ANIM_ACTIVATING:
			_anim_player.play(ANIM_ACTIVATED)
			active.emit()
			if active_time > 0.0:
				_timer = active_time
				_fn = trigger_deactivate
			#if active_time > 0.0:
				#get_tree().create_timer(active_time).timeout.connect(
					#trigger_deactivate, CONNECT_ONE_SHOT
				#)
		ANIM_DEACTIVATING:
			_anim_player.play(ANIM_INACTIVE)
			inactive.emit()
			if inactive_time > 0.0:
				_timer = inactive_time
				_fn = trigger_activate
			#if inactive_time > 0.0:
				#get_tree().create_timer(inactive_time).timeout.connect(
					#trigger_activate, CONNECT_ONE_SHOT
				#)
